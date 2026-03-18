module RAM8 (
    input clk, res, write,
    input [2:0] w_add,
    input [7:0] in,
    input [2:0] r_add,
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
                if(write)
                //if writing, store input in write address!
                    mem[w_add] <= in;
            else if (write == 0)
                //if not, output what's in the read address!
                out <= mem[r_add];
        end

endmodule