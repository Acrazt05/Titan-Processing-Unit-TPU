module pc (
    input load,
    input inc, 
    input reset,
    input clk,

    input [15:0] in,
    output reg [15:0] out
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            out <= 16'b0;
        end else if(load) begin
            out <= in;
        end else if(inc) begin
            out <= out + 1;
        end
    end
    
endmodule