iverilog -o project.out project_tb.v project.v
vvp project.out
gtkwave wave.vcd