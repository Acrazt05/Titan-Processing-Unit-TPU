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

    //GPIO
    input  [7:0] gp_inputs,
    output [7:0] gp_outputs,

    //UI GPIO
    output [7:0] uio_oe,
    input  [7:0] uio_in,
    output [7:0] uio_out
);

    // Address constants
    localparam MAX_SPI_ADDR  = 14'h3FFD;
    localparam UIO_ADDR      = 14'h3FFE;
    localparam GPIO_ADDR     = 14'h3FFF;

    // Decode logic
    wire ram_is_spi  = (ram_address <= MAX_SPI_ADDR);
    wire ram_is_uio  = (ram_address == UIO_ADDR);
    wire ram_is_gpio = (ram_address == GPIO_ADDR);

    /*
        uio[0] - GPIO21 - CS
        uio[1] - GPIO22 - MOSI
        uio[2] - GPIO23 - MISO
        uio[3] - GPIO24 - SCK

    */

    wire cs, mosi, miso, spi_clock;

    assign uio_out[3:0] = {
        spi_clock,
        1'b0,
        mosi,
        cs
    };

    assign miso = uio_in[2];

    assign uio_oe = uio_output[7:0];
    assign uio_out[7:4] = uio_output[15:12];

    wire [15:0] spi_ram_out;

    // SPI Memory Instantiation
    spi_memory memory_inst(
        .clk(clk),
        .reset(reset),
        
        .rom_address(rom_address),
        .rom_data_out(rom_data_out),
        
        .ram_enabled(ram_is_spi),
        .ram_address(ram_address),
        .ram_data_in(ram_data_in),
        .ram_write(ram_write && ram_is_spi),
        .ram_data_out(spi_ram_out),
        
        .data_ready(data_ready), // SPI controller handles the timing for both
        
        .cs(cs),
        .mosi(mosi),
        .miso(miso),
        .spi_clock(spi_clock)
    );

    wire [15:0] gpio_out;

    // GPIO Instantiation
    gpio gpio_inst(
        .clk(clk),
        .reset(reset),
        .input_signals(gp_inputs),
        .output_signals(gp_outputs),
        .data_in(ram_data_in[7:0]),
        .load(ram_write && ram_is_gpio),
        .out(gpio_out)
    );

    wire [15:0] uio_output;

    // UIO Instantiation
    uio uio_inst(
        .clk(clk),
        .reset(reset),
        .in(ram_data_in),
        .uio_input(uio_in),
        .load(ram_write && ram_is_uio),
        .out(uio_output)
    );

    // Output Multiplexer: Route the correct data back to the CPU
    assign ram_data_out = ram_is_gpio ? gpio_out :
                          ram_is_uio  ? uio_output  :
                          spi_ram_out;

endmodule
