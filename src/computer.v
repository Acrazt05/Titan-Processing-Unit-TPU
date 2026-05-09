`include "cpu.v"
`include "memory_router.v"

module computer (
    input reset,
    input clk,
    
    // SPI pins
    output mosi,
    input miso,
    output cs,
    output spi_clock,

    //GPIO
    input  [7:0] gpio_in,
    output [7:0] gpio_out,

    //UI GPIO
    output [7:0] uio_oe,
    input  [7:0] uio_in,
    output [7:0] uio_out
);

    wire [15:0] instruction;
    wire [13:0] count;

    wire [15:0] inM;
    wire writeM;
    wire [15:0] outM;
    wire [13:0] addressM;

    wire inc;

    cpu cpu(
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .clk(clk),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(count),
        .inc(inc)
    );

    memory_router router(
        .clk(clk),
        .reset(reset),

        .rom_address(count),
        .rom_data_out(instruction),

        .ram_address(addressM),
        .ram_write(writeM),
        .ram_data_in(outM),
        .ram_data_out(inM),
        
        .data_ready(inc),
        
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .spi_clock(spi_clock),

        .gpio_in_s(gpio_in),
        .gpio_out_s(gpio_out),

        .uio_oe(uio_oe),
        .uio_in_s(uio_in),
        .uio_out_s(uio_out)
    );

endmodule