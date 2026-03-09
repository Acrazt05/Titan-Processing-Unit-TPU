module dmux_16(
    input wire [15:0] in,
    input wire sel,
    output wire [15:0] a,
    output wire [15:0] b
);

    assign a = sel ? 0 : in;
    assign b = sel ? in : 0;

endmodule