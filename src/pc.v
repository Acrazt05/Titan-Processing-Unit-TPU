module pc (
    input load,
    input inc, 
    input reset,
    input clk,

    input [13:0] in,
    output reg [13:0] out
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            out <= 14'b0;
        end else if(load) begin
            out <= in;
        end else if(inc) begin
            out <= out + 1;
        end
    end
    
endmodule