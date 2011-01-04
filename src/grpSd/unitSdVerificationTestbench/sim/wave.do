onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Event /Testbed/CmdReceived
add wave -noupdate -format Event /Testbed/InitDone
add wave -noupdate -divider CardInterface
add wave -noupdate -format Logic /Testbed/CardInterface/Clk
add wave -noupdate -format Logic /Testbed/CardInterface/nResetAsync
add wave -noupdate -format Logic /Testbed/CardInterface/Cmd
add wave -noupdate -format Logic /Testbed/CardInterface/SClk
add wave -noupdate -format Literal -radix hexadecimal /Testbed/CardInterface/Data
add wave -noupdate -divider Wishbone
add wave -noupdate -format Logic /Testbed/BusInterface/ERR_I
add wave -noupdate -format Logic /Testbed/BusInterface/RTY_I
add wave -noupdate -format Logic /Testbed/BusInterface/CLK_I
add wave -noupdate -format Logic /Testbed/BusInterface/RST_I
add wave -noupdate -format Logic /Testbed/BusInterface/ACK_I
add wave -noupdate -format Literal /Testbed/BusInterface/DAT_I
add wave -noupdate -format Logic /Testbed/BusInterface/CYC_O
add wave -noupdate -format Literal /Testbed/BusInterface/ADR_O
add wave -noupdate -format Literal /Testbed/BusInterface/DAT_O
add wave -noupdate -format Logic /Testbed/BusInterface/SEL_O
add wave -noupdate -format Logic /Testbed/BusInterface/STB_O
add wave -noupdate -format Literal /Testbed/BusInterface/TGA_O
add wave -noupdate -format Literal /Testbed/BusInterface/TGC_O
add wave -noupdate -format Logic /Testbed/BusInterface/TGD_O
add wave -noupdate -format Logic /Testbed/BusInterface/WE_O
add wave -noupdate -format Logic /Testbed/BusInterface/LOCK_O
add wave -noupdate -format Literal /Testbed/BusInterface/CTI_O
add wave -noupdate -format Literal /Testbed/BusInterface/BTE_O
add wave -noupdate -divider Controller
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/ohighspeed
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/idataram
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/odataram
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/oledbank
add wave -noupdate -format Literal -expand /Testbed/top/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10082779 ns} 0}
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
WaveRestoreZoom {10082634 ns} {10083617 ns}
