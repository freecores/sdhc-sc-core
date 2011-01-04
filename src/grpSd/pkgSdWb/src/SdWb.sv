`ifndef SDWB_SV
`define SDWB_SV

`include "WbTransaction.sv";

const WbData cOperationRead = 'h00000001;
const WbData cOperationWrite = 'h00000010;

const WbAddr cOperationAddr = 'b000;
const WbAddr cStartAddrAddr = 'b001;
const WbAddr cEndAddrAddr = 'b010;
const WbAddr cReadDataAddr = 'b011;
const WbAddr cWriteDataAddr = 'b100;

`endif

