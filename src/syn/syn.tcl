if [info exists pkgs] {
	foreach {grp pkg} $pkgs {
		set fname ../../../grp$grp/pkg$pkg/src/$pkg-p.vhdl
		if [file isfile $fname] {
			set_global_assignment -name VHDL_FILE "$fname"
		} else {
			post_message -type error "Pkg $grp $pkg not found!"
		}
	}
}

if [info exists units] {
	foreach {grp en arch} $units {
		set prefix ../../../grp$grp/unit$en/src
		if [file isfile $prefix/$en-e.vhdl] {
			set_global_assignment -name VHDL_FILE "$prefix/$en-e.vhdl"
			if [file isfile $prefix/$en-$arch-a.vhdl] {
				set_global_assignment -name VHDL_FILE "$prefix/$en-$arch-a.vhdl"
			}
		} elseif [file isfile $prefix/$en-$arch-ea.vhdl] {
			set_global_assignment -name VHDL_FILE "$prefix/$en-$arch-ea.vhdl"
		} else {
			post_message -type error "Unit $grp $en $arch not found!"
		}
	}
}
