set pkgs {}
set units {}
set svunits {Sd SdCardModel}
#set tb 
#set tbarch 

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
	vsim tb$tb
	#do wave.do
	run -all
}

