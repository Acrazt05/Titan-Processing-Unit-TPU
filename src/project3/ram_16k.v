//16384 16-bit registers 
module ram_16k (
    //DATA
    input [15:0] in,
    output reg [15:0] out,

    //CONTROL
    input clk,
    input load,
    input [13:0] address //log2(16384) = 14 bits
);

    //16384 registers of 16 bits each
    reg [15:0] mem [0:16383];

    always @(posedge clk) begin
        
        if(load) begin
            mem[address] <= in;
        end 
        
        out <= mem[address];
    end

endmodule