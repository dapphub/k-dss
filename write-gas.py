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
symbolTable[ite_label]     = lambda c, b1, b2: '#if ' + c + '\n  #then ' + pyk.indent(b1) + '\n  #else ' + pyk.indent(b2) + '\n#fi'
for label in ['+Int', '-Int', '*Int', '/Int', 'andBool', 'orBool']:
    symbolTable['_' + label + '_'] = pyk.paren(pyk.binOpStr(label))

with open(input_file) as f:
    input_json = json.load(f)

def applySubstitutions(k):
    def _applySubstitutions(_k, _substs):
        if pyk.isKApply(_substs) and _substs['label'] == '#And':
            return _applySubstitutions(_applySubstitutions(_k, _substs['args'][0]), _substs['args'][1])
        elif pyk.isKApply(_substs) and _substs['label'] in ['_==Int_', '_==K_']:
            rule = (_substs['args'][0], _substs['args'][1])
            if pyk.isKVariable(rule[0]):
                rule = (rule[1], rule[0])
            return pyk.replaceAnywhereWith(rule, _k)
        return _k
    def _applySubstitutionsToGas(_k):
        match = pyk.match(KApply('#And', [KApply(inf_gas_label, [KVariable('G')]), KVariable('SUBSTS')]), _k)
        if match is not None:
            return KApply(inf_gas_label, [_applySubstitutions(match['G'], match['SUBSTS'])])
        return _k
    return pyk.traverseTopDown(k, _applySubstitutionsToGas)

def gatherConstInts(input, constants = [], non_constants = []):
    if pyk.isKApply(input) and input['label'] == '_+Int_':
        (c0, v0s) = gatherConstInts(input['args'][0])
        (c1, v1s) = gatherConstInts(input['args'][1])
        return (c0 + c1, v0s + v1s)
    elif pyk.isKToken(input) and input['sort'] == 'Int':
        return (int(input['token']), [])
    else:
        return (0, [input])

def buildPlusInt(vs):
    if len(vs) == 0:
        return KToken('0', 'Int')
    elif len(vs) == 1:
        return vs[0]
    else:
        return KApply('_+Int_', [vs[0], buildPlusInt(vs[1:])])

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

simplified_json = input_json
simplified_json = applySubstitutions(simplified_json)
simplified_json = pyk.simplifyBool(simplified_json)
simplified_json = simplifyPlusInt(simplified_json)
simplified_json = replaceSimplifications(simplified_json)
simplified_json = rewriteSimplifications(simplified_json)

print(pyk.prettyPrintKast(simplified_json, symbolTable))
sys.stdout.flush()
