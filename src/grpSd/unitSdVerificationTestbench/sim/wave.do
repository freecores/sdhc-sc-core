onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -divider SdWbSlave
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
add wave -noupdate -divider sdcard
add wave -noupdate -format Logic /Testbed/CardInterface/Clk
add wave -noupdate -format Logic /Testbed/CardInterface/nResetAsync
add wave -noupdate -format Logic /Testbed/CardInterface/Cmd
add wave -noupdate -format Logic /Testbed/CardInterface/SClk
add wave -noupdate -format Literal -radix hexadecimal /Testbed/CardInterface/Data
add wave -noupdate -divider clockmaster
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/irstsync
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/ihighspeed
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/idisable
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/osdstrobe
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/osdcardclk
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/sdclk
add wave -noupdate -format Literal /Testbed/top/sdclockmaster_inst/counter
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/sdstrobe25mhz
add wave -noupdate -format Logic /Testbed/top/sdclockmaster_inst/sdstrobe50mhz
add wave -noupdate -divider sddata
add wave -noupdate -format Logic /Testbed/top/sddata_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sddata_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sddata_inst/istrobe
add wave -noupdate -format Literal /Testbed/top/sddata_inst/isddatafromcontroller
add wave -noupdate -format Literal /Testbed/top/sddata_inst/osddatatocontroller
add wave -noupdate -format Literal /Testbed/top/sddata_inst/idata
add wave -noupdate -format Literal /Testbed/top/sddata_inst/odata
add wave -noupdate -format Literal /Testbed/top/sddata_inst/ireadwritefifo
add wave -noupdate -format Literal /Testbed/top/sddata_inst/oreadwritefifo
add wave -noupdate -format Literal /Testbed/top/sddata_inst/iwritereadfifo
add wave -noupdate -format Literal /Testbed/top/sddata_inst/owritereadfifo
add wave -noupdate -format Logic /Testbed/top/sddata_inst/odisablesdclk
add wave -noupdate -format Literal /Testbed/top/sddata_inst/crcin
add wave -noupdate -format Literal /Testbed/top/sddata_inst/crcout
add wave -noupdate -format Literal /Testbed/top/sddata_inst/crcdatain
add wave -noupdate -format Literal /Testbed/top/sddata_inst/r
add wave -noupdate -format Literal /Testbed/top/sddata_inst/nextr
add wave -noupdate -divider sdcontroller
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/ohighspeed
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osddata
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdwbslave
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextr
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutenable
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutdisable
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeout
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/timeoutmax
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1150621 ns} 0} {{Cursor 2} {10084945 ns} 0} {{Cursor 3} {10085095 ns} 0}
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
WaveRestoreZoom {1149954 ns} {1155829 ns}
