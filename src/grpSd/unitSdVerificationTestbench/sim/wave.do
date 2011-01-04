onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/CardInterface/Cmd
add wave -noupdate -format Logic /Testbed/CardInterface/SClk
add wave -noupdate -format Literal -radix hexadecimal /Testbed/CardInterface/Data
add wave -noupdate -format Logic /Testbed/IWbBus/ERR_I
add wave -noupdate -format Logic /Testbed/IWbBus/RTY_I
add wave -noupdate -format Logic /Testbed/IWbBus/CLK_I
add wave -noupdate -format Logic /Testbed/IWbBus/RST_I
add wave -noupdate -format Logic /Testbed/IWbBus/ACK_I
add wave -noupdate -format Literal -radix hexadecimal /Testbed/IWbBus/DAT_I
add wave -noupdate -format Logic /Testbed/IWbBus/CYC_O
add wave -noupdate -format Literal -radix hexadecimal /Testbed/IWbBus/ADR_O
add wave -noupdate -format Literal -radix hexadecimal /Testbed/IWbBus/DAT_O
add wave -noupdate -format Logic /Testbed/IWbBus/STB_O
add wave -noupdate -format Logic /Testbed/IWbBus/WE_O
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextr
add wave -noupdate -format Logic /Testbed/top/sdwbslave_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdwbslave_inst/irstsync
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/iwbctrl
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/owbctrl
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/iwbdat
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/owbdat
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/icontroller
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/ocontroller
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/owritefifo
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/iwritefifo
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/oreadfifo
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/ireadfifo
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/r
add wave -noupdate -format Literal /Testbed/top/sdwbslave_inst/nxr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2496665 ns} 0} {{Cursor 2} {6033878 ns} 0} {{Cursor 3} {19999903 ns} 0}
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
WaveRestoreZoom {2005 us} {4105 us}
