
proc compileWithPsl {fname grp en psl} {
	upvar $psl mpsl

	if [info exists mpsl($en)] {
		set pslfile "../../../grp$grp/unit$en/src/$mpsl($en).psl"
		if [file isfile $pslfile] {
			vcom $fname -pslfile $pslfile
		} else {
			echo "pslfile $pslfile not found"
			vcom $fname
		}
	} else {
		vcom $fname
	}
};

proc compileUnit {grp en arch tpsl} {
	upvar $tpsl psl
	set prefix ../../../grp$grp/unit$en/src
	if [file isfile $prefix/$en-e.vhdl] {
		compileWithPsl "$prefix/$en-e.vhdl" $grp $en psl
		if [file isfile $prefix/$en-$arch-a.vhdl] {
			vcom "$prefix/$en-$arch-a.vhdl"
		}
	} elseif [file isfile $prefix/$en-$arch-ea.vhdl] {
		compileWithPsl "$prefix/$en-$arch-ea.vhdl" $grp $en psl
	} else {
		echo "Unit $grp $en $arch not found!"
	}
};


proc compileTb {grp en arch} {
	set prefix ../../../grp$grp/unit$en/src
		if [file isfile $prefix/tb$en-e.vhdl] {
			vcom "$prefix/tb$en-e.vhdl"
			if [file isfile $prefix/tb$en-$arch-a.vhdl] {
				vcom "$prefix/tb$en-$arch-a.vhdl"
			}
		} elseif [file isfile $prefix/tb$en-$arch-ea.vhdl] {
			vcom "$prefix/tb$en-$arch-ea.vhdl"
		} else {
			echo "Testbench $grp $en $arch not found!"
		}
};

vlib work
vmap work work

if [info exists libs] {
	foreach {lib} $libs {
		vmap $lib ../../../lib$lib/sim/$lib
	}
}

if [info exists pkgs] {
	foreach {grp pkg} $pkgs {
		set fname ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
			if [file isfile $fname] {
				vcom "$fname"
			} else {
				echo "Pkg $grp $pkg not found!"
			}
	}
}

if [info exists units] {
	foreach {grp en arch} $units {
		compileUnit $grp $en $arch psl
	}
}



if [info exists tbunits] {
	foreach {grp en arch} $tbunits {
		compileUnit $grp $en $arch
	}
}

if [info exists tb] {
	foreach {grp en arch} $tb {
		compileTb $grp $en $arch

		set top tb$en
	}
}

if [info exists svtb] {
	foreach {grp unit} $svtb {
		set fname ../../../grp$grp/unit$unit/src/tb$unit.sv
		if [file isfile $fname] {
			vlog $fname
		} else {
			echo "Svunit $grp $unit not found! ($fname)"
		}
	}
}

if [info exists svunits] {
	foreach {grp unit} $svunits {
		set fname ../../../grp$grp/unit$unit/src/$unit.sv
		if [file isfile $fname] {
			vlog $fname
		} else {
			echo "Svunit $grp $unit not found! ($fname)"
		}
	}
}

if ([info exists top]) {
	if ([info exists vsimargs]) {
		vsim $vsimargs $top
	} else {
		vsim $top
	}

	if [file isfile wave.do] {
		do wave.do
	}

	if [info exists simtime] {
		run $simtime
	} else {
		run -all
	}
}
