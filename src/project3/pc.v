module PC (
    input load, inc, reset, clk
    input [15:0] in,
    output reg [15:0] out
    );

    always@(posedge clk or posedge reset) begin
        if(reset) begin //if reset is 1, counter is 0!
          out <= 16'b0
        end
        else if(load) begin //else if load is 1, counter is input!
            out <= in;
        end
        else if(inc) begin //else if inc is 1, counter+1!
            out <= out + 1;
        end
    end
endmodule