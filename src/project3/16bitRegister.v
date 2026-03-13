module Bit(
  input reg [15:0]in,
  input load,
  output reg [15:0]out
);
  
  always @(posedge load) begin
    out <= in;
  end
endmodule
  