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
# File        : TbdSdsyn.tcl
# Owner       : Rainer Kastl
# Description : 
# Links       : 
# 

package require ::quartus::project
package require ::quartus::flow

project_new TbdSdsyn -revision TbdSdSyn -overwrite

set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C35F484C8
set_global_assignment -name TOP_LEVEL_ENTITY TbdSd
set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga

source ../Files.tcl
source ../../../syn/syn.tcl

set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name SMART_RECOMPILE ON
set_global_assignment -name FMAX_REQUIREMENT "100 MHz" -section_id SdClock
set_global_assignment -name FMAX_REQUIREMENT "100 MHz" -section_id WbClock
set_global_assignment -name ENABLE_DRC_SETTINGS OFF
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS OFF
set_global_assignment -name USE_CONFIGURATION_DEVICE ON

# Generate RBF
set_global_assignment -name GENERATE_RBF_FILE ON
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF

source ../Pins.tcl

set_global_assignment -name TIMEQUEST_DO_REPORT_TIMING ON
set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON
set_global_assignment -name FINAL_PLACEMENT_OPTIMIZATION ALWAYS
set_global_assignment -name AUTO_GLOBAL_MEMORY_CONTROLS ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING ON
set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA
set_global_assignment -name OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name CYCLONE_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name MAXII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON
set_global_assignment -name MUX_RESTRUCTURE OFF

set_instance_assignment -name CLOCK_SETTINGS SdClock -to iSdClk
set_instance_assignment -name CLOCK_SETTINGS WbClock -to iWbClk
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

# Commit assignments
export_assignments

# Compile project
if {[catch {execute_flow -compile} result]} {
	puts "\nResult: $result\n"
	puts "ERROR: Compilation failed. See report files.\n"
} else {
	puts "\nINFO: Compilation was successful.\n"
}

project_close
