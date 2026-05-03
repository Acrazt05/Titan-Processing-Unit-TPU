::iverilog -o spi_memory_test.out spi_ram_sim_tb.v spi_ram_sim.v
::vvp spi_memory_test.out
::gtkwave wave_spi.vcd

iverilog -o spi_memory_test.out spi_memory_tb.v spi_memory.v spi_ram_sim.v
vvp spi_memory_test.out
::gtkwave wave_spi.vcd