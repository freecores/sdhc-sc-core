// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010 Rainer Kastl
// 
// This file is part of SDHC-SC-Core.
// 
// SDHC-SC-Core is free software: you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// SDHC-SC-Core is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
// 
// File        : SdWb.sv
// Owner       : Rainer Kastl
// Description : SD Wishbone constants for SystemVerilog
// Links       : 
// 

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

