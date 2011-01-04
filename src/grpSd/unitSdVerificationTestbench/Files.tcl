# SDHC-SC-Core
# Secure Digital High Capacity Self Configuring Core
# 
# (C) Copyright 2010 Rainer Kastl
# 
# This file is part of SDHC-SC-Core.
# 
# SDHC-SC-Core is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# SDHC-SC-Core is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
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
	Sd SdTop {Rtl}}

set svunits {Sd SdCardModel
	Sd SdVerificationTestbench}

set sysvlogparams [list +incdir+../../unitSdCardModel/src+../src+../../unitSdWbSlave/src+../../../grpVerification/unitLogger/src/+../../../grpSdVerification/unitSdCoreTransactionBFM/src+../../../grpSdVerification/unitSdCoreTransactionSeqGen/src+../../../grpSdVerification/unitSdCoreTransferFunction/src+../../../grpSdVerification/unitSdCoreChecker/src+../../../grpSdVerification/unitSdCoreTransaction/src+../../pkgSdWb/src/]

#set tb
set top Testbed

