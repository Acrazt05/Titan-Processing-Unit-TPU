module computer (
    input reset,
    input clk,

    //GPIO
    input  [7:0] gp_inputs, // Dedicated inputs
    output [7:0] gp_outputs,  // Dedicated outputs

    //UI GPIO
    output [7:0] uio_oe, // IOs: Enable path (active high: 0=input, 1=output)
    input  [7:0] uio_in,  // IOs: Input path
    output [7:0] uio_out // IOs: Output path
);

    wire [7:0] usable_uio_oe;
    assign uio_oe = {usable_uio_oe[7:4], 4'b1011}; 

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
        
        .gp_inputs(gp_inputs),
        .gp_outputs(gp_outputs),

        .uio_oe(usable_uio_oe),
        .uio_in(uio_in),
        .uio_out(uio_out)
    );

endmodule