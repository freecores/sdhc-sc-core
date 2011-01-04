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

set sysvlogparams [list +incdir+../../unitSdCardModel/src+../src+../../unitSdWbSlave/src+../../../grpVerification/unitLogger/src/]

#set tb
set top Testbed

