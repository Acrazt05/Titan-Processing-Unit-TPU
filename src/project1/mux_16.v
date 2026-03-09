module mux_16(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire sel,
    output wire [15:0] out
);

assign out = sel ? b : a;

endmodule