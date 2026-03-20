module PC
(
input clock,
input [15:0] data_in,
input load,
input reset,
output register[15:0] data_out,
);

always @(posedge clock or posedge reset) begin
if reset(i) begin
data_out<= 16'b0;
end 
else if load(i) begin 
data_out (i)<=data_in(i);
end
else if increment(i) begin
data_out(i)<=data_out(i)+1;
end
end
endmodule
