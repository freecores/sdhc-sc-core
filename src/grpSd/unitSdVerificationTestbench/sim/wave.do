onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider top
add wave -noupdate -format Logic /Testbed/top/iclk
add wave -noupdate -format Logic /Testbed/top/inresetasync
add wave -noupdate -format Logic /Testbed/top/iocmd
add wave -noupdate -format Logic /Testbed/top/osclk
add wave -noupdate -format Literal /Testbed/top/iodata
add wave -noupdate -format Logic /Testbed/top/otx
add wave -noupdate -format Literal /Testbed/top/oledbank
add wave -noupdate -format Literal /Testbed/top/odigitadr
add wave -noupdate -format Literal /Testbed/top/irs232tx
add wave -noupdate -format Literal /Testbed/top/ors232tx
add wave -noupdate -format Literal /Testbed/top/r
add wave -noupdate -format Literal /Testbed/top/nextr
add wave -noupdate -format Literal /Testbed/top/receivedcontent
add wave -noupdate -format Logic /Testbed/top/oreceivedcontentvalid
add wave -noupdate -divider controller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/isddata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/osddata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/osdregisters
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/nextr
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/timeout
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/nextcmdtimeout
add wave -noupdate -divider cmd
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/serialcrc
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/crccorrect
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/o
add wave -noupdate -divider data
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/isddatafromcontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/osddatatocontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcin
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcout
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcdatain
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/nextr
add wave -noupdate -divider rs232
add wave -noupdate -format Literal /Testbed/top/rs232tx_inst/r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1545140 ns} 0}
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
WaveRestoreZoom {0 ns} {7401261 ns}
