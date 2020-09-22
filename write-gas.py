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
        if input['label'] in [ '_+Int_' , '_-Int_' , '_/Int_' , '_*Int_' ]:
            return '(' + argStrs[0] + ' ' + input['label'][1:-1] + ' ' + argStrs[1] + ')'
        else:
            return input['label'] + '(' + ', '.join(argStrs) + ')'

print(printIt(input_json))
