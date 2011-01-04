onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextr
add wave -noupdate -divider cmd
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/inresetasync
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/ifromcontroller
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/otocontroller
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/iocmd
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/serialcrc
add wave -noupdate -format Logic /Testbed/top/sdcmd_inst/crccorrect
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/crcout
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/nextr
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/o
add wave -noupdate -format Literal /Testbed/top/sdcmd_inst/nexto
add wave -noupdate -divider controller
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/inresetasync
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/isdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/osdcmd
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/oledbank
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/r
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/nextr
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutenable
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeout
add wave -noupdate -divider timeout
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/gclkfrequency
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/gtimeouttime
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/iclk
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/inresetasync
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/ienable
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/otimeout
add wave -noupdate -format Literal /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/counter
add wave -noupdate -format Logic /Testbed/top/sdcontroller_inst/timeoutgenerator_inst/enabled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
WaveRestoreZoom {0 ns} {17105 ns}
