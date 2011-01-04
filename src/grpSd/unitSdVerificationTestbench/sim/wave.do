onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/CmdInterface/Clk
add wave -noupdate -format Logic /Testbed/CmdInterface/nResetAsync
add wave -noupdate -format Logic /Testbed/CmdInterface/Cmd
add wave -noupdate -divider Controller
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/state
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextstate
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -divider Cmd
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/state
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/nextstate
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/serialcrc
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crccorrect
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/counter
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/nextcounter
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/output
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/iocmd
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/otocontroller
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/ifromcontroller
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/iclk
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/receivedtoken
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/nextreceivedtoken
add wave -noupdate -divider Crc
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/iclear
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/idatain
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/idata
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/oiscorrect
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crc7_inst/oserial
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/crc7_inst/oparallel
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/crc7_inst/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2937 ns} 0}
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
WaveRestoreZoom {1133 ns} {3046 ns}
