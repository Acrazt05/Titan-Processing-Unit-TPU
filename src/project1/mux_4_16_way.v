module mux_4_16_way(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [15:0] c,
    input wire [15:0] d,
    input wire [1:0] sel,
    output wire [15:0] out
);

always @(*) begin
    case(sel)
        2'd0: out = a;
        2'd1: out = b;
        2'd2: out = c;
        2'd3: out = d;
        default:;
    endcase
end

endmodule