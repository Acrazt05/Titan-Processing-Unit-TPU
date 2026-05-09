::python ./programs/assembler.py ./programs/ram_write_test.tpu hex
iverilog -o project.out project_tb.v project.v spi_ram_sim.v computer.v cpu.v memory_router.v spi_memory.v gpio.v uio.v register_16.v pc.v alu.v
vvp project.out
::gtkwave wave.vcd