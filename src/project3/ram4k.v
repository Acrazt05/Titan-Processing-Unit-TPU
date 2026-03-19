module RAM4K (
    input clk, load,
    input [11:0] w_add, //12 bits!
    input [15:0] in,
    output reg [15:0] out

);
    //4096 boxes of 16 bits!
    reg [15:0] mem [0:4095];
    //counter

    //each time clock ticks
    always@(posedge clk) begin
            //if load is 1, store input in write address!
            if(load) begin
                mem[w_add] <= in;
            end
            //assuming load is 0, output what's in the write address
            out <= mem[w_add];
    end

endmodule