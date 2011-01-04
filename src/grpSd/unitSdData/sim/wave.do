onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider data
add wave -noupdate -format Logic /tbsddata/sddata_inst/iclk
add wave -noupdate -format Logic /tbsddata/sddata_inst/inresetasync
add wave -noupdate -format Literal /tbsddata/sddata_inst/isddatafromcontroller
add wave -noupdate -format Literal /tbsddata/sddata_inst/osddatatocontroller
add wave -noupdate -format Literal /tbsddata/sddata_inst/iodata
add wave -noupdate -format Literal /tbsddata/sddata_inst/crcin
add wave -noupdate -format Literal /tbsddata/sddata_inst/crcout
add wave -noupdate -format Literal -expand /tbsddata/sddata_inst/r
add wave -noupdate -format Literal /tbsddata/sddata_inst/nextr
add wave -noupdate -divider top
add wave -noupdate -format Logic /tbsddata/clk
add wave -noupdate -format Logic /tbsddata/nresetasync
add wave -noupdate -format Logic /tbsddata/finished
add wave -noupdate -format Literal /tbsddata/fromcontroller
add wave -noupdate -format Literal /tbsddata/tocontroller
add wave -noupdate -format Literal /tbsddata/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40434 ns} 0}
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
WaveRestoreZoom {40277 ns} {41944 ns}
