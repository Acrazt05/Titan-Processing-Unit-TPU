`include "keyboard.v"
`include "screen.v"
`include "ram_16k.v"

module memory (
    input [15:0] in,
    input [14:0] address,
    input load,
    input clk,
    output reg [15:0] out
);

    wire [1:0] memoryChipSelector = address[14:13];
  
    wire [13:0] memoryAddress = address[13:0];
    wire loadRam = !memoryChipSelector[0] & load;
    reg [15:0] ramOut;
  
    ram_16k ram_16k(in,ramOut,clk,loadRam,memoryAddress);

    wire loadScreen = memoryChipSelector[0] & load;
    reg [15:0] screenOut;
    wire [12:0] screenAddress = address[12:0];
  
    screen screen(in,screenOut,clk,loadScreen,screenAddress);
    
    reg [15:0] keyboardOut;
  
    keyboard keyboard(keyboardOut,clk);

    always @(posedge clk) begin
        case (memoryChipSelector)
            //RAM MEMORY ADDRESS 
            2'b00, 2'b01: out <= ramOut;
            //SCREEN ADDRESS
            2'b10: out <= screenOut;
             //KEYBOARD ADDRESS (24576)
            2'b11: out <= keyboardOut;
            //UNSUPPORTED MEMORY ADDRESS
            default: out = 16'bx; // Include a default case to avoid latches
        endcase

        /*
        if(address <= 15'd_16383) begin
            //RAM MEMORY ADDRESS
            out <= ramOut;
            ramSelected <= 1;
        end else if(address <= 15'd_24575) begin
            //SCREEN ADDRESS
            out <= screenOut;
            ramSelected <= 0;
        end else if(address == 15'd_24576) begin
            //KEYBOARD ADDRESS
            out <= keyboardOut;
        end else begin
            //UNSUPPORTED MEMORY ADDRESS
            out <= 16'b0;
        end*/
    end
    
endmodule