`ifndef SDCORETRANSACTION_SV
`define SDCORETRANSACTION_SV

class SdCoreTransaction;
endclass

class SdCoreTransactionSequence;
endclass

typedef mailbox #(SdCoreTransactionSequence) SdCoreTransSeqMb;

`endif
