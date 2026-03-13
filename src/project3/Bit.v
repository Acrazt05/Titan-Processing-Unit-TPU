module Bit(
  input reg in,
  input load,
  output reg out
);
  
  always @(posedge load) begin
    out <= in;
  end
endmodule

