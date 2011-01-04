onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tbsdcmd/clk
add wave -noupdate -format Logic /tbsdcmd/finished
add wave -noupdate -format Logic /tbsdcmd/nresetasync
add wave -noupdate -format Literal /tbsdcmd/tocmd
add wave -noupdate -format Logic /tbsdcmd/cmd
add wave -noupdate -format Literal /tbsdcmd/sentcmd
add wave -noupdate -format Literal /tbsdcmd/counter
add wave -noupdate -format Logic /tbsdcmd/save
add wave -noupdate -format Literal /tbsdcmd/dut/state
add wave -noupdate -format Literal /tbsdcmd/dut/nextstate
add wave -noupdate -format Logic /tbsdcmd/dut/serialcrc
add wave -noupdate -format Literal /tbsdcmd/dut/counter
add wave -noupdate -format Literal /tbsdcmd/dut/nextcounter
add wave -noupdate -format Literal /tbsdcmd/dut/output
add wave -noupdate -format Logic /tbsdcmd/dut/iocmd
add wave -noupdate -format Literal /tbsdcmd/dut/ifromcontroller
add wave -noupdate -format Logic /tbsdcmd/dut/inresetasync
add wave -noupdate -format Logic /tbsdcmd/dut/iclk
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/iclk
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/inresetasync
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/iclear
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/idatain
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/idata
add wave -noupdate -format Logic /tbsdcmd/dut/crc7_inst/oserial
add wave -noupdate -format Literal /tbsdcmd/dut/crc7_inst/oparallel
add wave -noupdate -format Literal /tbsdcmd/dut/crc7_inst/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {242 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {567 ns}
