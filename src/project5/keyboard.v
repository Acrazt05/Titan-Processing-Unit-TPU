module keyboard (
    output reg [15:0] out,
    input clk
);

    always @(posedge clk ) begin
        //TODO: implement actual keyboard
        //Character set is on Appendix 5 (page 413 pdf)
        out <= out + 1;
    end

endmodule