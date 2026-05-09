::python ./programs/assembler.py ./programs/ram_write_test.tpu hex
iverilog -o project.out project_tb.v project.v spi_ram_sim.v
vvp project.out
::gtkwave wave.vcd