onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/iocmd
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/osclk
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/iodata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/oreceivedcontent
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/oreceivedcontentvalid
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/oreceiveddata
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/oreceiveddatavalid
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmdtocontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcmdfromcontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddatatocontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddatafromcontroller
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddatafromram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sddatatoram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontrollertodataram
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/sdcontrollerfromdataram
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdstrobe
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdstrobe25mhz
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sdstrobe50mhz
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/highspeed
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/icmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/ocmd
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/idata
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/odata
add wave -noupdate -format Logic /Testbed/top/sdtop_inst/sclk
add wave -noupdate -format Literal /Testbed/top/sdtop_inst/counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13244864 ns} 0}
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
WaveRestoreZoom {13244389 ns} {13246454 ns}
