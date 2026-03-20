//32768 16-bit registers 
module rom_32k (
    //DATA
    output reg [15:0] out,

    //CONTROL
    input clk,
    input [14:0] address //log2(32768) = 15 bits
);

    //32768 registers of 16 bits each
    reg [15:0] mem [0:32767];

    // Load memory from file
    parameter HEX_PATH = "./programs/";
    parameter file_name = "jump.mem";

    initial begin
        $readmemb({HEX_PATH, file_name}, mem); //binary instructions
        //$readmemh({HEX_PATH, file_name}, mem); //hex instructions
    end

    always @(posedge clk) begin
        out <= mem[address];
    end

endmodule