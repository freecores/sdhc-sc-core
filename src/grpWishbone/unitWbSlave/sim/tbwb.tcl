set pkgs {Wishbone Wishbone}
set units {Wishbone WbSlave {Rtl}}
set tb Crc
set tbarch bhv

vlib work
vmap work work

foreach {grp pkg} $pkgs {
    vcom ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
}

foreach {grp en arch} $units {
    vcom ../../../grp$grp/unit$en/src/$en-$arch-ea.vhdl
}

#vcom ../../unit$tb/src/tb$tb-$tbarch-ea.vhdl

#vsim tb$tb

#do wave.do
#run -all
