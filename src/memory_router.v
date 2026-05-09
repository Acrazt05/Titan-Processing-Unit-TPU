`include "spi_memory.v"
`include "gpio.v"
`include "uio.v"

/*
========= Memory Router =============
Wrapper that routes to SPI, GPIO, or UIO based on address.
Memory Map:
0x0000 - 0x3FFD : SPI RAM (16382 words)
0x3FFE          : UIO
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
    output spi_clock,

    //GPIO
    input  [7:0] gpio_in_s,
    output [7:0] gpio_out_s,

    //UI GPIO
    output [7:0] uio_oe,
    input  [7:0] uio_in_s,
    output [7:0] uio_out_s
);

    // Address constants
    localparam MAX_SPI_ADDR  = 14'h3FFD;
    localparam UIO_ADDR      = 14'h3FFE;
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
        //.ram_enabled(1'b1),
        .rom_address(rom_address),
        .ram_address(ram_address),
        .ram_data_in(ram_data_in),
        .ram_write(ram_write && ram_is_spi),
        //.ram_write(ram_write),
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
        .input_signals(gpio_in_s),
        .output_signals(gpio_out_s),
        .data_in(ram_data_in[7:0]),
        .load(ram_write && ram_is_gpio),
        .out(gpio_out)
    );

    // UIO Instantiation
    uio uio_inst(
        .clk(clk),
        .reset(reset),
        .in(ram_data_in),
        .uio_input(uio_in_s),
        .load(ram_write && ram_is_uio),
        .out(uio_out)
    );

    assign uio_oe = uio_out[7:0];
    assign uio_out_s = uio_out[15:8];

    // Output Multiplexer: Route the correct data back to the CPU
    assign ram_data_out = ram_is_gpio ? gpio_out :
                          ram_is_uio  ? uio_out  :
                          spi_ram_out;

    assign ram_data_out = spi_ram_out;

endmodule
