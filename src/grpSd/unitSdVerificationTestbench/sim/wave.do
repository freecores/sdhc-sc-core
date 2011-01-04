onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/ohighspeed
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/isddata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/osddata
add wave -noupdate -format Literal -expand /Testbed/top/sdtop_inst/sdcontroller_inst/idataram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/odataram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/nextr
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/timeoutenable
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/timeoutdisable
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcontroller_inst/timeout
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontroller_inst/timeoutmax
add wave -noupdate -divider dataram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/memory
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/odatar
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/iaddrr
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/odatarw
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/dataram_inst/iwerw
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/idatarw
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/dataram_inst/iaddrrw
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/dataram_inst/iclk
add wave -noupdate -divider sdcmd
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/istrobe
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/ifromcontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/otocontroller
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/iocmd
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/serialcrc
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdcmd_inst/crccorrect
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/crcout
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/nextr
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/o
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmd_inst/nexto
add wave -noupdate -divider sddata
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sddata_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sddata_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sddata_inst/istrobe
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/isddatafromcontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/osddatatocontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/isddatafromram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/osddatatoram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/iodata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcin
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcout
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/crcdatain
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/r
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddata_inst/nextr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5026264 ns} 0}
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
WaveRestoreZoom {5025749 ns} {5027814 ns}
