`include "cpu.v"
`include "spi_memory.v"

module computer (
    input reset,
    input clk,
    
    // SPI pins
    output mosi,
    input miso,
    output cs,
    output spi_clock
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

    spi_memory memory(

        .clk(clk),
        .reset(reset),
        .ram_enabled(1'b1), //TODO: add GPIO router module

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
        .spi_clock(spi_clock)
    );

endmodule