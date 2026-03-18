module cpu (
    //from data memory
    input [15:0] inM, //RAM[A]
    //from instruction memory
    input [15:0] instruction,

    input reset,

    //to data memory
    output [15:0] outM,
    output writeM,
    output [13:0] addressM,

    //to instruction memory
    output [13:0] pc
);
    


endmodule