module register_16(
  input [15:0] in,
  input load,
  input clk,
  input reset,
  output reg [15:0]out
);
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out <= 16'b0;
    end else if(load) begin
      out <= in;
    end 
  end
endmodule
  