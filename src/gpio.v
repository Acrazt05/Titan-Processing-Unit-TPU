
module gpio (
    input clk,
    input reset,

    //being driven outside the chip
    input  [7:0] input_signals, //Read-only
    output [7:0] output_signals,

    input load,
    input [7:0] data_in,

    output [15:0] out
);

    reg [7:0] outputs_reg;

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            outputs_reg <= 8'b0;
        end else if (load) begin
            //Set phyisical outputs
            outputs_reg <= data_in;
        end
    end

    assign output_signals = outputs_reg;
    assign out = {input_signals, outputs_reg};

endmodule
