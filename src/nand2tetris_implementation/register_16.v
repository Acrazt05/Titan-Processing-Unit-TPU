module register_16(
  input [15:0] in,
  input load,
  input clk,
  output reg [15:0]out
);
  
  always @(posedge clk) begin
    if(load) begin
      out <= in;
    end 
  end
endmodule
  