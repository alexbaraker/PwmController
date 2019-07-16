cd ../../quartus
vlib work

vcom -93 -work work ../src/fpga/PwmController.vhd
vcom -93 -work work ../sim/src/PwmController_tb.vhd

vsim -novopt PwmController_tb

do ../sim/script/wave.do
run 2 ms