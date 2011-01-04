set src ../src

vlib work
vmap work work

vcom $src/crc-p.vhdl
vcom $src/crc-ea.vhdl
vcom $src/tb-crc-ea.vhdl

vsim tb_crc

add wave *
add wave duv7/*
run -all

