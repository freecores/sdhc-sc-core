# Copyright (C) 1991-2010 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: CRCsyn.tcl
# Generated on: Wed Jun 23 17:07:05 2010

# Load Quartus II Tcl Project package
package require ::quartus::project
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "CRCsyn"]} {
		puts "Project CRCsyn is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists CRCsyn]} {
		project_open -revision CRCsyn CRCsyn
	} else {
		project_new -revision CRCsyn CRCsyn
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone II"
	set_global_assignment -name DEVICE EP2C35F484C8
	set_global_assignment -name TOP_LEVEL_ENTITY crc
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "9.1 SP2"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "21:01:43  APRIL 16, 2010"
	set_global_assignment -name LAST_QUARTUS_VERSION "9.1 SP2"
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name VHDL_FILE "../../pkgCRCs/src/CRCs-p.vhdl"
	set_global_assignment -name VHDL_FILE "../src/Crc-Rtl-ea.vhdl"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name SMART_RECOMPILE ON
	set_global_assignment -name FMAX_REQUIREMENT "100 MHz" -section_id Clock
	set_global_assignment -name ENABLE_DRC_SETTINGS OFF
	set_global_assignment -name MISC_FILE "Z:/SD-CORE/src/grpCrc/unitCrc/syn/CRCsyn.dpf"
	set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS OFF
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name GENERATE_RBF_FILE ON
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_instance_assignment -name CLOCK_SETTINGS Clock -to iClk
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

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
