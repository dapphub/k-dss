#!/usr/bin/env python3

import json
import sys

input_file = sys.argv[1]

with open(input_file) as f:
    input_json = json.load(f)['term']

def printIt(input):
    if input['node'] == 'KToken':
        return input['token']
    if input['node'] == 'KVariable':
        return input['originalName']
    if input['node'] == 'KApply':
        argStrs = [ printIt(arg) for arg in input['args'] ]
        if input['label'] in [ '_+Int_' , '_-Int_' , '_/Int_' , '_*Int_' , '_orBool_' , '_andBool_' ]:
            return '(' + argStrs[0] + ' ' + input['label'][1:-1] + ' ' + argStrs[1] + ')'
        elif input['label'] == '_==K_':
            return '(' + argStrs[0] + ' ==Int ' + argStrs[1] + ')'
        elif input['label'] == '_=/=K_':
            return '(' + argStrs[0] + ' =/=Int ' + argStrs[1] + ')'
        elif input['label'] == 'notBool_':
            return '(notBool ' + argStrs[0] + ')'
        elif input['label'] == '#if_#then_#else_#fi_K-EQUAL-SYNTAX':
            return '#if ' + argStrs[0] + ' #then ' + argStrs[1] + ' #else ' + argStrs[2] + ' #fi'
        else:
            return input['label'] + '(' + ', '.join(argStrs) + ')'

print(printIt(input_json))
