set pkgs {Global Global Sd Sd Crc CRCs}
set units {Crc Crc {Rtl} Sd SdCmd {Rtl} Sd SdCmdWrapper {Rtl}}
set svunits {Sd SdCardModel Sd SdVerificationTestbench}
#set tb 
#set tbarch 
set top Testbed

vlib work
vmap work work

foreach {grp pkg} $pkgs {
    vcom ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
}

foreach {grp en arch} $units {
    vcom ../../../grp$grp/unit$en/src/$en-$arch-ea.vhdl
}

foreach {grp unit} $svunits {
    vlog ../../../grp$grp/unit$unit/src/$unit.sv
}

if ([info exists tb]) {
	vcom ../../unit$tb/src/tb$tb-$tbarch-ea.vhdl
}

if ([info exists top]) {
	vsim $top
	do wave.do
	run -all
}

