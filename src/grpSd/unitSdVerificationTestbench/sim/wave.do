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
add wave -noupdate -format Literal /Testbed/top/sddata_inst/rbitinwordc
add wave -noupdate -format Literal /Testbed/top/sddata_inst/rwordc
add wave -noupdate -format Literal /Testbed/top/sddata_inst/rbytec
add wave -noupdate -format Literal /Testbed/top/sddata_inst/rbitc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2496665 ns} 0} {{Cursor 2} {6033878 ns} 0} {{Cursor 3} {18655442 ns} 0}
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
WaveRestoreZoom {0 ns} {21 ms}
