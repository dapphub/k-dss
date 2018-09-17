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
        <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015d565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed811415610158576100ea6b033b2e3c9fd0803ce800000060243561015d565b600080526000806000806024356004356109c4f1151561010957600080fd5b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561015657600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019257600080fd5b8284830414600085141715156101a757600080fd5b50929150505600a165627a7a72305820543575317b5e3067936b6237d6fb1093e46b420861eb59ef409aad954327aad90029"), BYZANTIUM)) </program>
        <programBytes> #parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015d565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed811415610158576100ea6b033b2e3c9fd0803ce800000060243561015d565b600080526000806000806024356004356109c4f1151561010957600080fd5b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561015657600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019257600080fd5b8284830414600085141715156101a757600080fd5b50929150505600a165627a7a72305820543575317b5e3067936b6237d6fb1093e46b420861eb59ef409aad954327aad90029") </programBytes>
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
        <callDepth> CALL_DEPTH => _ </callDepth>
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
          <code> #parseByteStack("0x60806040527c0100000000000000000000000000000000000000000000000000000000600035046336569e7781141561003e5760005460405260206040f35b63c5ce281e8114156100565760015460405260206040f35b63ad677d0b8114156100c6576100786b033b2e3c9fd0803ce80000003461015d565b7f42066cbb000000000000000000000000000000000000000000000000000000006000526001546004526004356024528060445260008060646000806000545af115156100c457600080fd5b005b63ef693bed811415610158576100ea6b033b2e3c9fd0803ce800000060243561015d565b600080526000806000806024356004356109c4f1151561010957600080fd5b7f42066cbb00000000000000000000000000000000000000000000000000000000600052600154600452336024528060000360445260008060646000806000545af1151561015657600080fd5b005b600080fd5b600082820290507f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8082111561019257600080fd5b8284830414600085141715156101a757600080fd5b50929150505600a165627a7a72305820543575317b5e3067936b6237d6fb1093e46b420861eb59ef409aad954327aad90029") </code>
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
requires 0 <=Int ACCT_ID    andBool ACCT_ID    <Int (2 ^Int 160)
andBool 0 <=Int CALLER_ID  andBool CALLER_ID  <Int (2 ^Int 160)
andBool 0 <=Int ORIGIN_ID  andBool ORIGIN_ID  <Int (2 ^Int 160)
  andBool #rangeBytes(32, Ilk)

endmodule
