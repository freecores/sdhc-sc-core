
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
	Memory SimpleDualPortedRam {Rtl}
	Memory SinglePortedRam {Rtl}
	StrobesClocks StrobeGen {Rtl}
	Sd SdWbSlave {Rtl}
	Sd SdClockMaster {Rtl}
	Sd SdCardSynchronizer {Rtl}
	Synchronization Synchronizer {Rtl}
	StrobesClocks EdgeDetector {Rtl}
	Sd SdWbSdControllerSync {Rtl}
	Sd SdTop {Rtl}}

set svunits {Sd SdCardModel
	Sd SdVerificationTestbench}

#set tb
set top Testbed

