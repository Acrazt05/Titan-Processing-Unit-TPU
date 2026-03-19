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

    integer f;
    integer i;

    always @(posedge clk) begin
        
        if(load) begin
            mem[address] <= in;
        end 
        
        out <= mem[address];

        // Dump entire screen periodically
        f = $fopen("screen.bin", "w");
        if (f) begin
            for (i = 0; i < 8192; i = i + 1) begin
                $fwrite(f, "%h\n", mem[i]);
            end
            $fclose(f);
        end
    end

endmodule