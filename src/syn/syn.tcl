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
# File        : syn.tcl
# Owner       : Rainer Kastl
# Description : Synthesis script for Quartus
# Links       : 
# 

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
