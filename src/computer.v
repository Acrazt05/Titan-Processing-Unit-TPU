`include "cpu.v"
`include "memory_router.v"

module computer (
    input reset,
    input clk,
    
    // SPI pins
    output reg mosi,
    input miso,
    output reg cs,
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

    memory_router memory(
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
        .spi_clock(spi_clock)
    );

endmodule