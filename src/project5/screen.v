//8192 16-bit registers 
module screen (
    //DATA
    input [15:0] in,
    output reg [15:0] out,

    //CONTROL
    input clk,
    input load,
    input [12:0] address //log2(8192) = 13 bits
);

    //8192 registers of 16 bits each
    reg [15:0] mem [0:8191];

    always @(posedge clk) begin
        
        if(load) begin
            mem[address] <= in;
        end 
        
        out <= mem[address];
    end

   //TODO: implement actual screen refresh

endmodule