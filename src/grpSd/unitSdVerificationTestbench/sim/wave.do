onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/CmdInterface/Clk
add wave -noupdate -format Logic /Testbed/CmdInterface/nResetAsync
add wave -noupdate -format Literal /Testbed/CmdInterface/CmdId
add wave -noupdate -format Literal /Testbed/CmdInterface/Arg
add wave -noupdate -format Logic /Testbed/CmdInterface/Valid
add wave -noupdate -format Logic /Testbed/CmdInterface/Receiving
add wave -noupdate -format Logic /Testbed/CmdInterface/Cmd
add wave -noupdate -format Logic /Testbed/CmdWrapper/sdcmd/iocmd
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/state
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/nextstate
add wave -noupdate -format Logic /Testbed/CmdWrapper/sdcmd/serialcrc
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/counter
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/nextcounter
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/output
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/otocontroller
add wave -noupdate -format Literal /Testbed/CmdWrapper/sdcmd/ifromcontroller
add wave -noupdate -format Logic /Testbed/CmdWrapper/sdcmd/inresetasync
add wave -noupdate -format Logic /Testbed/CmdWrapper/sdcmd/iclk
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
WaveRestoreZoom {0 ns} {1913 ns}
