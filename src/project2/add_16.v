module add16 (
    input  wire [15:0] a,       // 16-bit input A
    input  wire [15:0] b,       // 16-bit input B
    output wire [15:0] sum,     // 16-bit sum
    output wire        carry_out // carry out
);

    assign {carry_out, sum} = a + b;

endmodule