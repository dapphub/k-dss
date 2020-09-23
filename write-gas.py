#!/usr/bin/env python3

import json
import sys
import pyk

input_file = sys.argv[1]

with open(input_file) as f:
    input_json = json.load(f)

definition  = pyk.readKastTerm('deps/evm-semantics/.build/defn/java/driver-kompiled/compiled.json')
symbolTable = pyk.buildSymbolTable(definition)
symbolTable['#gas'] = appliedLabelStr('#gas')

print(pyk.prettyPrintKast(input_json, symbolTable))
