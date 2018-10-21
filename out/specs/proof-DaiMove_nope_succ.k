requires "../rules.k"

module PROOF-DAIMOVE_NOPE_SUCC
  imports ETHEREUM-SIMULATION
  imports EVM
  imports RULES

// DaiMove_nope
rule
  <k> #execute ~> CONTINUATION => #halt ~> CONTINUATION </k>
  <exit-code> 1 </exit-code>
  <mode> NORMAL </mode>
  <schedule> BYZANTIUM </schedule>
  <analysis> .Map </analysis>
  <ethereum>
    <evm>
      <output> .WordStack </output>
      <statusCode> _ => EVMC_SUCCESS </statusCode>
      <callStack> VCallStack </callStack>
      <interimStates> _ </interimStates>
      <touchedAccounts> _ => _ </touchedAccounts>
      <callState>
        <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack("0x60806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806336569e77146100725780634538c4eb146100c9578063a3b22fc414610140578063bb35783b14610183578063dc4d20fa146101f0575b600080fd5b34801561007e57600080fd5b50610087610233565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3480156100d557600080fd5b5061012a600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610258565b6040518082815260200191505060405180910390f35b34801561014c57600080fd5b50610181600480360381019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061027d565b005b34801561018f57600080fd5b506101ee600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610301565b005b3480156101fc57600080fd5b50610231600480360381019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506104d5565b005b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6001602052816000526040600020602052806000526040600020600091509150505481565b60018060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b3373ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614806103b6575060018060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054145b15156103c157600080fd5b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166378f194708473ffffffffffffffffffffffffffffffffffffffff166001028473ffffffffffffffffffffffffffffffffffffffff166001026104486b033b2e3c9fd0803ce80000008661055a565b6040518463ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180846000191660001916815260200183600019166000191681526020018281526020019350505050600060405180830381600087803b1580156104b857600080fd5b505af11580156104cc573d6000803e3d6000fd5b50505050505050565b6000600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b600081830290506000811215151561057157600080fd5b600082148061058a575082828281151561058757fe5b04145b151561059557600080fd5b929150505600a165627a7a723058201948bb96810defdac8f3371951736dce7afe62eae0f9a6a08c39d758ede853b50029"), BYZANTIUM)) </program>
        <programBytes> #parseByteStack("0x60806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806336569e77146100725780634538c4eb146100c9578063a3b22fc414610140578063bb35783b14610183578063dc4d20fa146101f0575b600080fd5b34801561007e57600080fd5b50610087610233565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3480156100d557600080fd5b5061012a600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610258565b6040518082815260200191505060405180910390f35b34801561014c57600080fd5b50610181600480360381019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061027d565b005b34801561018f57600080fd5b506101ee600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610301565b005b3480156101fc57600080fd5b50610231600480360381019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506104d5565b005b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6001602052816000526040600020602052806000526040600020600091509150505481565b60018060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b3373ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614806103b6575060018060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054145b15156103c157600080fd5b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166378f194708473ffffffffffffffffffffffffffffffffffffffff166001028473ffffffffffffffffffffffffffffffffffffffff166001026104486b033b2e3c9fd0803ce80000008661055a565b6040518463ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180846000191660001916815260200183600019166000191681526020018281526020019350505050600060405180830381600087803b1580156104b857600080fd5b505af11580156104cc573d6000803e3d6000fd5b50505050505050565b6000600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b600081830290506000811215151561057157600080fd5b600082148061058a575082828281151561058757fe5b04145b151561059557600080fd5b929150505600a165627a7a723058201948bb96810defdac8f3371951736dce7afe62eae0f9a6a08c39d758ede853b50029") </programBytes>
        <id> ACCT_ID </id>
        <caller> CALLER_ID </caller>
        <callData> #abiCallData("nope", #address(ABI_guy)) </callData>
        <callValue> 0 </callValue>
        <wordStack> .WordStack => _ </wordStack>
        <localMem> .Map => _ </localMem>
        <pc> 0 => _ </pc>
        <gas> VGas => _ </gas>
        <memoryUsed> 0 => _ </memoryUsed>
        <previousGas> _ => _ </previousGas>
        <static> false </static>
        <callDepth> VCallDepth => _ </callDepth>
      </callState>
      <substate>
        <selfDestruct> VSelfDestruct </selfDestruct>
        <log> _ => VLog </log>
        <refund> _ => VRefund </refund>
      </substate>
      <gasPrice> _ </gasPrice>
      <origin> ORIGIN_ID </origin>
      <previousHash> _ </previousHash>
      <ommersHash> _ </ommersHash>
      <coinbase> _ </coinbase>
      <stateRoot> _ </stateRoot>
      <transactionsRoot> _ </transactionsRoot>
      <receiptsRoot> _ </receiptsRoot>
      <logsBloom> _ </logsBloom>
      <difficulty> _ </difficulty>
      <number> _ </number>
      <gasLimit> _ </gasLimit>
      <gasUsed> _ </gasUsed>
      <timestamp> TIME </timestamp>
      <extraData> _ </extraData>
      <mixHash> _ </mixHash>
      <blockNonce> _ </blockNonce>
      <ommerBlockHeaders> _ </ommerBlockHeaders>
      <blockhash> _ </blockhash>
    </evm>
    <network>
      <activeAccounts> SetItem(ACCT_ID) _ </activeAccounts>
      <accounts>
        <account>
          <acctID> ACCT_ID </acctID>
          <balance> BAL </balance>
          <code> #parseByteStack("0x60806040526004361061006d576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806336569e77146100725780634538c4eb146100c9578063a3b22fc414610140578063bb35783b14610183578063dc4d20fa146101f0575b600080fd5b34801561007e57600080fd5b50610087610233565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3480156100d557600080fd5b5061012a600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610258565b6040518082815260200191505060405180910390f35b34801561014c57600080fd5b50610181600480360381019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061027d565b005b34801561018f57600080fd5b506101ee600480360381019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610301565b005b3480156101fc57600080fd5b50610231600480360381019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506104d5565b005b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6001602052816000526040600020602052806000526040600020600091509150505481565b60018060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b3373ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614806103b6575060018060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054145b15156103c157600080fd5b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166378f194708473ffffffffffffffffffffffffffffffffffffffff166001028473ffffffffffffffffffffffffffffffffffffffff166001026104486b033b2e3c9fd0803ce80000008661055a565b6040518463ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180846000191660001916815260200183600019166000191681526020018281526020019350505050600060405180830381600087803b1580156104b857600080fd5b505af11580156104cc573d6000803e3d6000fd5b50505050505050565b6000600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555050565b600081830290506000811215151561057157600080fd5b600082148061058a575082828281151561058757fe5b04145b151561059557600080fd5b929150505600a165627a7a723058201948bb96810defdac8f3371951736dce7afe62eae0f9a6a08c39d758ede853b50029") </code>
          <storage> (_:Map
                      (#DaiMove.can[CALLER_ID][ABI_guy] |-> (Could => 0)))
           </storage>
          <nonce> _ </nonce>
        </account>
       ... 
      </accounts>
      <txOrder> _ </txOrder>
      <txPending> _ </txPending>
      <messages> _ </messages>
    </network>
  </ethereum>
requires #rangeAddress(ACCT_ID)
andBool #notPrecompileAddress(ACCT_ID)
andBool #rangeAddress(CALLER_ID)
andBool #rangeAddress(ORIGIN_ID)
andBool #rangeUInt(48, TIME)
andBool #rangeUInt(256, BAL)
andBool VCallDepth <=Int 1024

    andBool (#rangeAddress(ABI_guy)
    andBool (#rangeUInt(256, Could)
    andBool (VGas >Int 300000)))

endmodule
