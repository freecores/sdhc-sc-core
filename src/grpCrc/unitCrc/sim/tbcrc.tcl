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
# File        : tbcrc.tcl
# Owner       : Rainer Kastl
# Description : 
# Links       : 
# 

set pkgs {Crc CRCs}
set units {Crc Crc {Rtl}}
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

vcom ../../unit$tb/src/tb$tb-$tbarch-ea.vhdl

vsim tb$tb

do wave.do
run -all
