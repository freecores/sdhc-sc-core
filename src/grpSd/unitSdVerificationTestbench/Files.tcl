# SDHC-SC-Core
# Secure Digital High Capacity Self Configuring Core
# 
# (C) Copyright 2010, Rainer Kastl
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# File        : Files.tcl
# Owner       : Rainer Kastl
# Description : 
# Links       : 
# 

set libs {altera_mf}

set pkgs {Global Global
	Sd Sd
	Crc CRCs
	Rs232 Rs232
	Components Ics307Values
	Wishbone Wishbone
	Sd SdWb
}

set units {Crc Crc {Rtl}
	Sd SdCmd {Rtl}
	StrobesClocks Counter {Rtl}
	Sd SdController {Rtl}
	Sd SdData {Rtl}
	Cyclone2 CycSimpleDualPortedRam {Syn}
	Memory SimpleDualPortedRam {Rtl}
	Memory SinglePortedRam {Rtl}
	StrobesClocks StrobeGen {Rtl}
	Sd SdWbSlave {Rtl}
	Sd SdClockMaster {Rtl}
	Sd SdCardSynchronizer {Rtl}
	Synchronization Synchronizer {Rtl}
	StrobesClocks EdgeDetector {Rtl}
	Sd SdWbSdControllerSync {Rtl}
	Cyclone2 WriteDataFifo {Syn}
	Sd SdClkDomain {Rtl}
	Sd SdTop {Rtl}}

set svunits {Sd SdCardModel
	Sd SdVerificationTestbench}

set sysvlogparams [list +incdir+../../unitSdCardModel/src+../src+../../unitSdWbSlave/src+../../../grpVerification/unitLogger/src/+../../../grpSdVerification/unitSdCoreTransactionBFM/src+../../../grpSdVerification/unitSdCoreTransactionSeqGen/src+../../../grpSdVerification/unitSdCoreTransferFunction/src+../../../grpSdVerification/unitSdCoreChecker/src+../../../grpSdVerification/unitSdCoreTransaction/src+../../pkgSdWb/src/]

#set tb
set top Testbed
set vsimargs -coverage
