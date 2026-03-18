module RAM8 (
    input clk, res, write,
    input [2:0] address,
    input [7:0] in,
    output reg [7:0] out
);
    //8 boxes of 8 bits each
    reg [7:0] mem [7:0];
    //counter
    integer i;

    //each time clock ticks or reset is on!
    always@(posedge clk or posedge res)
        begin
            if(res) begin
                //go through boxes 0-7 and set them to 0!
                for(i=0; i<=7; i=i+1)
                    mem[i] <= 0;
                    end

            else
                if(load)
                //if writing, store input in write address!
                    mem[address] <= in;
            else if (load == 0)
                //if not, output what's in the read address!
                out <= mem[address];
        end

endmodule