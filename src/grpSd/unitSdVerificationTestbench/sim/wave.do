onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /Testbed/CardInterface/Cmd
add wave -noupdate -format Logic /Testbed/CardInterface/SClk
add wave -noupdate -format Literal /Testbed/CardInterface/Data
add wave -noupdate -format Logic /Testbed/IWbBus/ERR_I
add wave -noupdate -format Logic /Testbed/IWbBus/RTY_I
add wave -noupdate -format Logic /Testbed/IWbBus/CLK_I
add wave -noupdate -format Logic /Testbed/IWbBus/RST_I
add wave -noupdate -format Logic /Testbed/IWbBus/ACK_I
add wave -noupdate -format Literal /Testbed/IWbBus/DAT_I
add wave -noupdate -format Logic /Testbed/IWbBus/CYC_O
add wave -noupdate -format Literal /Testbed/IWbBus/ADR_O
add wave -noupdate -format Literal /Testbed/IWbBus/DAT_O
add wave -noupdate -format Logic /Testbed/IWbBus/SEL_O
add wave -noupdate -format Logic /Testbed/IWbBus/STB_O
add wave -noupdate -format Literal /Testbed/IWbBus/TGA_O
add wave -noupdate -format Literal /Testbed/IWbBus/TGC_O
add wave -noupdate -format Logic /Testbed/IWbBus/TGD_O
add wave -noupdate -format Logic /Testbed/IWbBus/WE_O
add wave -noupdate -format Logic /Testbed/IWbBus/LOCK_O
add wave -noupdate -format Literal /Testbed/IWbBus/CTI_O
add wave -noupdate -format Literal /Testbed/IWbBus/BTE_O
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2518 ns} 0} {{Cursor 2} {10084945 ns} 0} {{Cursor 3} {10085095 ns} 0}
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
WaveRestoreZoom {0 ns} {5875 ns}
