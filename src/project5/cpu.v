`include "register_16.v"
`include "pc.v"
`include "alu.v"

module cpu (
    //from data memory
    input [15:0] inM, //RAM[A]
    //from instruction memory
    input [15:0] instruction, //cccccccccccccccc

    //instuction[15] -> 0 -> A-instruction -> load into A register
    //instruction[15] -> 1 -> C-instuction -> it's a control capsule -> 1xxaccccccdddjjj
    //1xxaccccccdddjjj
    //  a and cccccc -> comp part of the instruction (computation)
    //  ddd -> dest part (destination) [store in A, store in D, store in RAM[A]]
    //  jjj -> jump part (jump)
    //  xx -> ignored (don't care)

    input reset,
    input clk,

    //to data memory
    output [15:0] outM,
    output writeM,
    output [14:0] addressM,

    //to instruction memory
    output [14:0] pc //TODO: maybe change to pc if there is no errors
);
    

    wire isCInstruction = instruction[15];

    wire a = instruction[12]; // a ? load to alu from inM: load to alu from A reg 
    wire [5:0] comp = instruction[11:6];

    wire [2:0] destPart = instruction[5:3]; //[store in A, store in D, store in RAM[A] (=writeM?)]
    wire [2:0] jumpPart = instruction[2:0];


    wire [15:0] ARegInput = isCInstruction ? ALUOutput : instruction;
    wire loadAReg = !isCInstruction | destPart[2];
    wire [15:0] ARegOutput;

    register_16 A_reg (
            .in(ARegInput),
            .load(loadAReg),
            .clk(clk),
            .out(ARegOutput)
        );

    wire [15:0] ALUInputY = a ? inM : ARegOutput;
    wire [15:0] ALUInputX;
    wire [15:0] ALUOutput;

    assign outM = ALUOutput;
    assign writeM = isCInstruction & destPart[0];

    wire zr;
    wire ng;

    alu alu(
        .x(ALUInputX),
        .y(ALUInputY),
        .zx(comp[5]),
        .nx(comp[4]),
        .zy(comp[3]),
        .ny(comp[2]),
        .f(comp[1]),
        .no(comp[0]),
        .zr(zr), //output == 0
        .ng(ng), //output is negative
        .out(ALUOutput));

    wire loadDReg = destPart[1];

    register_16 D_reg (
        .in(ALUOutput),
        .load(loadDReg),
        .clk(clk),
        .out(ALUInputX)
    );

    wire [15:0] programCounterOutput;
    assign pc = programCounterOutput[14:0];
    assign addressM = ARegOutput[14:0];

    reg shouldJump;

    always @(isCInstruction or zr or ng) begin
        if (!isCInstruction)
            shouldJump = 0;
        else begin
            case(jumpPart) 
                //no jump (null)
                3'b000: shouldJump = 0;
                //JGT
                3'b001: shouldJump = !zr & !ng;
                //JEQ
                3'b010: shouldJump = zr;
                //JGE
                3'b011: shouldJump = zr | !ng;
                //JLT
                3'b100: shouldJump = ng;
                //JNE
                3'b101: shouldJump = !zr;
                //JLE
                3'b110: shouldJump = zr | ng;
                //JMP
                3'b111: shouldJump = 1;
                default: shouldJump = 0;
            endcase
        end
    end

    pc program_counter(
        .load(shouldJump),
        .inc(1'b1), //TODO: idk if the inc pin is supposed to always be active, maybe a pause function?
        .reset(reset),
        .clk(clk),
        .in(ARegOutput),
        .out(programCounterOutput)
    );



endmodule