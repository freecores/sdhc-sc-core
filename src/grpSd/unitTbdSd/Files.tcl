set libs {altera_mf cycloneii}

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
	Cyclone2 WriteDataFifo {Syn}
	StrobesClocks StrobeGen {Rtl}
	Sd SdWbSlave {Rtl}
	Sd SdClockMaster {Rtl}
	Sd SdCardSynchronizer {Rtl}
	Synchronization Synchronizer {Rtl}
	StrobesClocks EdgeDetector {Rtl}
	StrobesClocks StrobeGen {Rtl}
	Sd SdWbSdControllerSync {Rtl}
	Sd TestWbMaster {Rtl}
	Rs232 Rs232Tx {Rtl}
	Components Ics307Configurator {Rtl}
	Sd SdTop {Rtl}
	Sd TbdSd {Rtl}}

set tb {Sd TbdSd {Bhv}}


