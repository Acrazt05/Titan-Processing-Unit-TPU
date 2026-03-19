module RAM64
(
input clock,
input reset,
input write_on,
input read_on,
input [5:0] write_addr,
input [63:0] data_in,
input [5:0] read_addr,
output reg [63:0] data_out,
);
reg[63:0] mem[0:63];

//start mem and reg definition
integer i;
always@(posedge clock or posedge reset)
begin 
if(reset) begin
for (i=0;i<64;i=i+1)
mem[i]<= 64'b00000000;
end
else begin
//for write=1
if(write_on)begin 
mem[write_addr]<= data_in;
end
//for write=0
if(read_on)begin
data_out<= mem[read_addr];
end



endmodule
