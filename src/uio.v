module uio (
    input clk,
    input reset,
    
    input [15:0] in,
    input [7:0] uio_input,
    input load,

    output [15:0] out
);

    reg [15:0] internal_reg;

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            internal_reg <= 16'b0;
        end

        else begin

            // update direction when loading
            if (load) begin
                internal_reg[7:0] <= in[7:0];
                internal_reg[15:8] <= (in[15:8] & in[7:0]) | (uio_input & ~in[7:0]);
            end
            // inputs always update
            else begin
                internal_reg[15:8] <= (internal_reg[15:8] & internal_reg[7:0]) | (uio_input & ~internal_reg[7:0]);
            end
        end

    end

    assign out = internal_reg;

endmodule