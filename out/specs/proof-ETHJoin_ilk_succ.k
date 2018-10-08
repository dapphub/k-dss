requires "../rules.k"

module PROOF-ETHJOIN_ILK_SUCC
  imports ETHEREUM-SIMULATION
  imports EVM
  imports RULES

// ilk
rule
  <k> #execute => #halt </k>
  <exit-code> 1 </exit-code>
  <mode> NORMAL </mode>
  <schedule> BYZANTIUM </schedule>
  <analysis> .Map </analysis>
  <ethereum>
    <evm>
      <output> _ => #asByteStackInWidthaux(Ilk, 31, 32, .WordStack) </output>
      <statusCode> _ => EVMC_SUCCESS </statusCode>
      <callStack> VCallStack </callStack>
      <interimStates> _ </interimStates>
      <touchedAccounts> _ => _ </touchedAccounts>
      <callState>
        <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015f565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed81141561015a576100ea6b033b2e3c9fd0803ce800000060243561015f565b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561013757600080fd5b6108fc602435150260008060008060243560043586f1151561015857600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019457600080fd5b8284830414600085141715156101a957600080fd5b50929150505600a165627a7a723058208d3d580103caa38e0c3c90a2e6c4b2ad604a3ed0e4c45761cb0d02e2d51257f40029"), BYZANTIUM)) </program>
        <programBytes> #parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015f565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed81141561015a576100ea6b033b2e3c9fd0803ce800000060243561015f565b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561013757600080fd5b6108fc602435150260008060008060243560043586f1151561015857600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019457600080fd5b8284830414600085141715156101a957600080fd5b50929150505600a165627a7a723058208d3d580103caa38e0c3c90a2e6c4b2ad604a3ed0e4c45761cb0d02e2d51257f40029") </programBytes>
        <id> ACCT_ID </id>
        <caller> CALLER_ID </caller>
        <callData> #abiCallData("ilk", .TypedArgs) </callData>
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
      <activeAccounts> SetItem(ACCT_ID) </activeAccounts>
      <accounts>
        <account>
          <acctID> ACCT_ID </acctID>
          <balance> BAL </balance>
          <code> #parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015f565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed81141561015a576100ea6b033b2e3c9fd0803ce800000060243561015f565b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561013757600080fd5b6108fc602435150260008060008060243560043586f1151561015857600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019457600080fd5b8284830414600085141715156101a957600080fd5b50929150505600a165627a7a723058208d3d580103caa38e0c3c90a2e6c4b2ad604a3ed0e4c45761cb0d02e2d51257f40029") </code>
          <storage> #ETHJoin.ilk |-> (Ilk)
                          _:Map
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
andBool VCallDepth <Int 1024
  andBool #rangeBytes(32, Ilk)
  andBool VGas >Int 300000

endmodule
