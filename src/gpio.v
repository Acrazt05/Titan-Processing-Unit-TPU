
module gpio (
    input clk,
    input reset,
    input [15:0] in,
    input load,

    output [15:0] out
);

    reg [15:0] internal_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            internal_reg <= 16'b0;
        end else if (load) begin
            internal_reg <= in;
        end
    end

    assign out = internal_reg;

endmodule
