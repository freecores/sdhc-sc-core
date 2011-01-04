set pkgs {Global Global
	Sd Sd
	Crc CRCs}
set units {Crc Crc {Rtl}
	Sd SdCmd {Rtl}}
set tb SdCmd
set tbarch Bhv

vlib work
vmap work work

foreach {grp pkg} $pkgs {
    vcom ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
}

foreach {grp en arch} $units {
    vcom ../../../grp$grp/unit$en/src/$en-$arch-ea.vhdl
}

vcom ../../unit$tb/src/tb$tb-$tbarch-ea.vhdl

vsim tb$tb

do wave.do
run -all