#!/usr/bin/env python3

import json
import sys
import pyk

from pyk import KApply, KVariable, KToken

input_file = sys.argv[1]

definition = pyk.readKastTerm('deps/evm-semantics/.build/defn/java/driver-kompiled/compiled.json')

with open(input_file) as f:
    input_json = json.load(f)

ite_label = '#if_#then_#else_#fi_K-EQUAL-SYNTAX'

symbolTable = pyk.buildSymbolTable(definition)
symbolTable['infGas']   = pyk.appliedLabelStr('#gas')
for label in ['+Int', '-Int', '*Int', '/Int', 'andBool', 'orBool']:
    symbolTable['_' + label + '_'] = pyk.paren(pyk.binOpStr(label))
symbolTable['notBool_'] = pyk.paren(pyk.underbarUnparsing('notBool_'))

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

simplified_json = pyk.simplifyBool(input_json)
simplified_json = simplifyPlusInt(simplified_json)

rewrites = [ (KApply('_==K_', [KVariable('I1'), KVariable('I2')]),  KApply('_==Int_', [KVariable('I1'), KVariable('I2')]))
           , (KApply('_=/=K_', [KVariable('I1'), KVariable('I2')]), KApply('_=/=Int_', [KVariable('I1'), KVariable('I2')]))
           #, ( KApply('_+Int_', [KApply('_+Int_', [KVariable('I1'), KVariable('I2')]), KVariable('I3')])
           #  , KApply('_+Int_', [KVariable('I1'), KApply('_+Int_', [KVariable('I2'), KVariable('I3')])])
           #  )
           , ( KApply(ite_label, [KVariable('C'), KApply('_+Int_', [KVariable('I'), KVariable('I1')]), KApply('_+Int_', [KVariable('I'), KVariable('I2')])])
             , KApply('_+Int_', [KVariable('I'), KApply(ite_label, [KVariable('C'), KVariable('I1'), KVariable('I2')])])
             )
           , ( KApply(ite_label, [KVariable('C'), KApply('_+Int_', [KVariable('I1'), KVariable('I')]), KApply('_+Int_', [KVariable('I2'), KVariable('I')])])
             , KApply('_+Int_', [KVariable('I'), KApply(ite_label, [KVariable('C'), KVariable('I1'), KVariable('I2')])])
             )
           ]

for r in rewrites:
    simplified_json = pyk.rewriteAnywhereWith(r, simplified_json)

print(pyk.prettyPrintKast(simplified_json, symbolTable))
