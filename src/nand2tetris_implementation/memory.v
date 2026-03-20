`include "keyboard.v"
`include "screen.v"
`include "ram_16k.v"

module memory (
    input [15:0] in,
    input [14:0] address,
    input load,
    input clk,
    output [15:0] out
);

    // Address decoding (fixed)
    wire isRAM = (address <= 15'd16383);
    wire isScreen = (address >= 15'd16384) && (address <= 15'd24575);
    wire isKeyboard = (address == 15'd24576);

    // RAM MEMORY
    wire [13:0] memoryAddress = address[13:0];
    wire loadRam = isRAM & load;
    wire [15:0] ramOut;

    ram_16k ram_16k(
        .in(in),
        .out(ramOut),
        .clk(clk),
        .load(loadRam),
        .address(memoryAddress)
    );

    // SCREEN MEMORY
    wire loadScreen = isScreen & load;
    wire [15:0] screenOut;
    wire [12:0] screenAddress = address - 15'd16384;

    screen screen(
        .in(in),
        .out(screenOut),
        .clk(clk),
        .load(loadScreen),
        .address(screenAddress)
    );
    
    // KEYBOARD
    wire [15:0] keyboardOut;
  
    keyboard keyboard(
        .out(keyboardOut),
        .clk(clk)
    );

    assign out = isRAM      ? ramOut :      //RAM MEMORY ADDRESS 
                 isScreen   ? screenOut :   //SCREEN ADDRESS
                 isKeyboard ? keyboardOut : //KEYBOARD ADDRESS (24576)
                                16'b0;      //UNSUPPORTED MEMORY ADDRESS
    
endmodule