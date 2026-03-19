`include "cpu.v"
`include "memory.v"
`include "rom_32k.v"

module computer (
    input reset,
    input clk
);

    wire [15:0] instruction;
    wire [14:0] count;

    rom_32k rom_32k(
        .out(instruction),
        .clk(clk),
        .address(count)
    );    

    wire [15:0] inM;
    wire writeM;
    wire [15:0] outM;
    wire [14:0] addressM;

    cpu cpu(
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .clk(clk),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(count)
    );

    memory memory(
        .in(outM),
        .address(addressM),
        .load(writeM),
        .clk(clk),
        .out(inM)
    );


endmodule