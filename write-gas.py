#!/usr/bin/env python3

import json
import sys
import pyk

from pyk import KApply, KVariable, KToken

input_file = sys.argv[1]

definition = pyk.readKastTerm('deps/evm-semantics/.build/defn/java/driver-kompiled/compiled.json')

ite_label     = '#if_#then_#else_#fi_K-EQUAL-SYNTAX'
inf_gas_label = 'infGas'

symbolTable = pyk.buildSymbolTable(definition)
symbolTable[inf_gas_label] = pyk.appliedLabelStr('#gas')
symbolTable['notBool_']    = pyk.paren(pyk.underbarUnparsing('notBool_'))
symbolTable['#And']        = lambda x, y: x + '\n #And ' + y
symbolTable[ite_label]     = lambda c, b1, b2: '#if ' + c + '\n  #then ' + pyk.indent(b1) + '\n  #else ' + pyk.indent(b2) + '\n#fi'
for label in ['+Int', '-Int', '*Int', '/Int', 'andBool', 'orBool']:
    symbolTable['_' + label + '_'] = pyk.paren(pyk.binOpStr(label))

def pykPrint(k):
    return pyk.prettyPrintKast(k, symbolTable)

def printTerm(k):
    return pykPrint(k['args'][0])

def printConstraint(k):
    return pykPrint(k['args'][1])

with open(input_file) as f:
    input_json = json.load(f)

def buildAssoc(base, join, l):
    if len(l) == 0:
        return base
    if len(l) == 1:
        return l[0]
    return KApply(join, [l[0], buildAssoc(base, join, l[1:])])

def buildAnd(l):
    return buildAssoc(pyk.KConstant('#Top'), '#And', l)

def buildPlusInt(l):
    return buildAssoc(pyk.KToken('0', 'Int'), '_+Int_', l)

def findCommonItems(l1, l2):
    common = []
    for i in l1:
        if i in l2:
            common.append(i)
    newL1 = []
    newL2 = []
    for i in l1:
        if not i in common:
            newL1.append(i)
    for i in l2:
        if not i in common:
            newL2.append(i)
    return (common, newL1, newL2)

def collectLabels(k):
    labels = set([])
    def _collectLabels(_k):
        if pyk.isKApply(_k):
            labels.add(_k['label'])
        return _k
    pyk.traverseTopDown(k, _collectLabels)
    return labels

def containsLabel(k, label):
    return label in collectLabels(k)

def termSize(k):
    return len(collectLabels(k))

def separateTermAndConstraints(k):
    allTerms = pyk.flattenLabel('#And', k)
    return (allTerms[0], allTerms[1:])

def sortConstraints(k):
    def _sortConstraints(_k):
        if not (pyk.isKApply(_k) and _k['label'] == '#And'):
            return _k
        (term, _constraints) = separateTermAndConstraints(_k)
        constraints = []
        for c in _constraints:
            if pyk.isKApply(c) and c['label'] in ['_==K_', '_==Int_']:
                rule = (c['args'][0], c['args'][1])
                if (pyk.isKVariable(rule[0]) or pyk.isKToken(rule[0])) and not pyk.isKToken(rule[1]):
                    rule = (rule[1], rule[0])
                constraints.append(KApply(c['label'], [rule[0], rule[1]]))
        return buildAnd([term] + sorted(constraints, key = termSize))
    return pyk.traverseTopDown(k, _sortConstraints)

def propogateUpConstraints(k):
    def _propogateUpConstraints(_k):
        pattern = KApply(ite_label, [KVariable('COND'), KApply('#And', [KVariable('G1'), KVariable('C1')]), KApply('#And', [KVariable('G2'), KVariable('C2')])])
        match = pyk.match(pattern, _k)
        if match is None:
            return _k
        (common, b1, b2) = findCommonItems(pyk.flattenLabel('#And', match['C1']), pyk.flattenLabel('#And', match['C2']))
        if len(common) == 0:
            return _k
        g1 = match['G1']
        if len(b1) > 0:
            g1 = buildAnd([g1] + b1)
        g2 = match['G2']
        if len(b2) > 0:
            g2 = buildAnd([g2] + b2)
        return KApply('#And', [KApply(ite_label, [match['COND'], g1, g2]), buildAnd(common)])
    return pyk.traverseBottomUp(k, _propogateUpConstraints)

def applySubstitutions(k):
    def _applySubstitution(_k, _constraint):
        _newK = _k
        if pyk.isKApply(_constraint) and _constraint['label'] in ['_==Int_', '_==K_']:
            rule = (_constraint['args'][0], _constraint['args'][1])
            if pyk.isKVariable(rule[1]) or pyk.isKToken(rule[1]):
                _newK = pyk.replaceAnywhereWith(rule, _newK)
        return _newK
    def _applySubstitutions(_k):
        if not (pyk.isKApply(_k) and _k['label'] == '#And'):
            return _k
        allTerms    = pyk.flattenLabel('#And', _k)
        term        = allTerms[0]
        constraints = allTerms[1:]
        newConstraints = []
        for c in constraints:
            newC = c
            for nc in newConstraints:
                newC = _applySubstitution(newC, nc)
            newConstraints.append(newC)
        for nc in newConstraints:
            term = _applySubstitution(term, nc)
        return buildAnd([term] + newConstraints)
    return pyk.traverseTopDown(k, _applySubstitutions)

def extractTerm(k):
    def _extractTerm(_k):
        if pyk.isKApply(_k) and _k['label'] == '#And' and pyk.isKApply(_k['args'][0]) and _k['args'][0]['label'] in [inf_gas_label, ite_label]:
            return _k['args'][0]
        return _k
    return pyk.traverseTopDown(k, _extractTerm)

def gatherConstInts(input, constants = [], non_constants = []):
    int_exps = pyk.flattenLabel('_+Int_', input)
    c  = 0
    vs = []
    for i in int_exps:
        if pyk.isKToken(i) and i['sort'] == 'Int':
            c += int(i['token'])
        else:
            vs.append(i)
    return (c, vs)

def simplifyPlusInt(k):
    if pyk.isKApply(k):
        if not (k['label'] == '_+Int_'):
            return pyk.onChildren(k, lambda x: simplifyPlusInt(x))
        (c, vs) = gatherConstInts(k)
        if not (c == 0):
            vs.append(KToken(str(c), 'Int'))
        return buildPlusInt(vs)
    return k

def replaceSimplifications(k):
    replacements = [ ( KToken('115792089237316195423570985008687907853269984665640564039457584007913129639936' , 'Int') , KToken('pow256'          , 'Int') )
                   , ( KToken('57896044618658097711785492504343953926634992332820282019728792003956564819968'  , 'Int') , KToken('pow255'          , 'Int') )
                   , ( KToken('411376139330301510538742295639337626245683966408394965837152256'                , 'Int') , KToken('pow208'          , 'Int') )
                   , ( KToken('374144419156711147060143317175368453031918731001856'                            , 'Int') , KToken('pow168'          , 'Int') )
                   , ( KToken('1461501637330902918203684832716283019655932542976'                              , 'Int') , KToken('pow160'          , 'Int') )
                   , ( KToken('340282366920938463463374607431768211456'                                        , 'Int') , KToken('pow128'          , 'Int') )
                   , ( KToken('79228162514264337593543950336'                                                  , 'Int') , KToken('pow96'           , 'Int') )
                   , ( KToken('281474976710656'                                                                , 'Int') , KToken('pow48'           , 'Int') )
                   , ( KToken('65536'                                                                          , 'Int') , KToken('pow16'           , 'Int') )
                   , ( KToken('-170141183460469231731687303715884105728'                                       , 'Int') , KToken('minSInt128'      , 'Int') )
                   , ( KToken('170141183460469231731687303715884105727'                                        , 'Int') , KToken('maxSInt128'      , 'Int') )
                   , ( KToken('-1701411834604692317316873037158841057280000000000'                             , 'Int') , KToken('minSFixed128x10' , 'Int') )
                   , ( KToken('1701411834604692317316873037158841057270000000000'                              , 'Int') , KToken('maxSFixed128x10' , 'Int') )
                   , ( KToken('-57896044618658097711785492504343953926634992332820282019728792003956564819968' , 'Int') , KToken('minSInt256'      , 'Int') )
                   , ( KToken('57896044618658097711785492504343953926634992332820282019728792003956564819967'  , 'Int') , KToken('maxSInt256'      , 'Int') )
                   , ( KToken('255'                                                                            , 'Int') , KToken('maxUInt8'        , 'Int') )
                   , ( KToken('65535'                                                                          , 'Int') , KToken('maxUInt16'       , 'Int') )
                   , ( KToken('281474976710655'                                                                , 'Int') , KToken('maxUInt48'       , 'Int') )
                   , ( KToken('79228162514264337593543950335'                                                  , 'Int') , KToken('maxUInt96'       , 'Int') )
                   , ( KToken('340282366920938463463374607431768211455'                                        , 'Int') , KToken('maxUInt128'      , 'Int') )
                   , ( KToken('3402823669209384634633746074317682114550000000000'                              , 'Int') , KToken('maxUFixed128x10' , 'Int') )
                   , ( KToken('1461501637330902918203684832716283019655932542975'                              , 'Int') , KToken('maxUInt160'      , 'Int') )
                   , ( KToken('374144419156711147060143317175368453031918731001855'                            , 'Int') , KToken('maxUInt168'      , 'Int') )
                   , ( KToken('411376139330301510538742295639337626245683966408394965837152255'                , 'Int') , KToken('maxUInt208'      , 'Int') )
                   , ( KToken('115792089237316195423570985008687907853269984665640564039457584007913129639935' , 'Int') , KToken('maxUInt256'      , 'Int') )
                   ]
    newK = k
    for r in replacements:
        newK = pyk.replaceAnywhereWith(r, newK)
    return newK

def rewriteSimplifications(k):
    rewrites = [ ( KApply('_==K_', [KVariable('I1'), KVariable('I2')])  , KApply('_==Int_', [KVariable('I1'), KVariable('I2')])  )
               , ( KApply('_=/=K_', [KVariable('I1'), KVariable('I2')]) , KApply('_=/=Int_', [KVariable('I1'), KVariable('I2')]) )
               , ( KApply(ite_label, [KVariable('COND'), KApply(inf_gas_label, [KVariable('G1')]), KApply(inf_gas_label, [KVariable('G2')])])
                 , KApply(inf_gas_label, [KApply(ite_label, [KVariable('COND'), KVariable('G1'), KVariable('G2')])])
                 )
               , ( KApply(ite_label, [KVariable('C'), KApply('_+Int_', [KVariable('I'), KVariable('I1')]), KApply('_+Int_', [KVariable('I'), KVariable('I2')])])
                 , KApply('_+Int_', [KVariable('I'), KApply(ite_label, [KVariable('C'), KVariable('I1'), KVariable('I2')])])
                 )
               , ( KApply(ite_label, [KVariable('C'), KApply('_+Int_', [KVariable('I1'), KVariable('I')]), KApply('_+Int_', [KVariable('I2'), KVariable('I')])])
                 , KApply('_+Int_', [KVariable('I'), KApply(ite_label, [KVariable('C'), KVariable('I1'), KVariable('I2')])])
                 )
               , ( KApply(ite_label, [KVariable('C'), KApply('_+Int_', [KVariable('I'), KVariable('I1')]), KApply('_+Int_', [KVariable('I2'), KApply('_+Int_', [KVariable('I'), KVariable('I3')])])])
                 , KApply('_+Int_', [KVariable('I'), KApply(ite_label, [KVariable('C'), KVariable('I1'), KApply('_+Int_', [KVariable('I2'), KVariable('I3')])])])
                 )
               ]

    newK = k
    for r in rewrites + rewrites + rewrites:
        newK = pyk.rewriteAnywhereWith(r, newK)
    return newK

steps = [ ( 'sortConstraints'        , sortConstraints         )
        , ( 'propogateUpConstraints' , propogateUpConstraints  )
        , ( 'applySubstitutions'     , applySubstitutions      )
        , ( 'extractTerm'            , extractTerm             )
        , ( 'simplifyBool'           , pyk.simplifyBool        )
        , ( 'simplifyPlusInt'        , simplifyPlusInt         )
        , ( 'replaceSimplifications' , replaceSimplifications  )
        , ( 'rewriteSimplifications' , rewriteSimplifications  )
        ]

simplified_json = input_json

for (name, s) in steps:
    simplified_json = s(simplified_json)

print(pykPrint(simplified_json))
sys.stdout.flush()
