`include "spi_memory.v"
`include "gpio.v"
`include "uio.v"

/*
========= Memory Router =============
Wrapper that routes to SPI, GPIO, or UIO based on address.
Memory Map:
0x0000 - 0x3FFC : SPI RAM (16381 words)
0x3FFD          : UIO
0x3FFE          : Reserved
0x3FFF          : GPIO
=====================================
*/

module memory_router(
    input clk,
    input reset,

    // CPU addresses
    input [13:0] ram_address,
    input [13:0] rom_address,

    // RAM write interface
    input [15:0] ram_data_in,
    input ram_write,

    // Data returned to CPU
    output [15:0] ram_data_out,
    output [15:0] rom_data_out,

    // Signals CPU when both accesses finished
    output data_ready,

    // SPI pins
    output mosi,
    input miso,
    output cs,
    output spi_clock
);

    // Address constants
    localparam MAX_SPI_ADDR  = 14'h3FFC;
    localparam UIO_ADDR      = 14'h3FFD;
    localparam GPIO_ADDR     = 14'h3FFF;

    // Decode logic
    wire ram_is_spi  = (ram_address <= MAX_SPI_ADDR);
    wire ram_is_uio  = (ram_address == UIO_ADDR);
    wire ram_is_gpio = (ram_address == GPIO_ADDR);

    // Internal data lines
    wire [15:0] spi_ram_out;
    wire [15:0] gpio_out;
    wire [15:0] uio_out;

    // SPI Memory Instantiation
    spi_memory memory_inst(
        .clk(clk),
        .reset(reset),
        .ram_enabled(ram_is_spi),
        .rom_address(rom_address),
        .ram_address(ram_address),
        .ram_data_in(ram_data_in),
        .ram_write(ram_write && ram_is_spi),
        .ram_data_out(spi_ram_out),
        .rom_data_out(rom_data_out),
        .data_ready(data_ready), // SPI controller handles the timing for both
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .spi_clock(spi_clock)
    );

    // GPIO Instantiation
    gpio gpio_inst(
        .clk(clk),
        .reset(reset),
        .in(ram_data_in),
        .load(ram_write && ram_is_gpio),
        .out(gpio_out)
    );

    // UIO Instantiation
    uio uio_inst(
        .clk(clk),
        .reset(reset),
        .in(ram_data_in),
        .load(ram_write && ram_is_uio),
        .out(uio_out)
    );

    // Output Multiplexer: Route the correct data back to the CPU
    assign ram_data_out = ram_is_gpio ? gpio_out :
                          ram_is_uio  ? uio_out  :
                          spi_ram_out;

endmodule
