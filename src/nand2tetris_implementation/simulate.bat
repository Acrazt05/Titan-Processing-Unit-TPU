iverilog -o computer.out computer_tb.v computer.v
vvp computer.out
gtkwave wave.vcd