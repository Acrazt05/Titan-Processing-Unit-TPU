`include "half_adder.v"
`include "full_adder.v"


//16-bit ripple-carry adder (you could implement a carry-lookahead or Kogge-Stone adder to make it faster)
module bad_add_16 (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] sum,
    output wire carry
);

wire [15:0] inter_carry;
//a,b,sum,carry
half_adder half_adder_1(a[0],b[0],sum[0], inter_carry[0]);

//a,b,c,sum,carry
full_adder full_adder_1(a[1],b[1],inter_carry[0],sum[1],inter_carry[1]);
full_adder full_adder_2(a[2],b[2],inter_carry[1],sum[2],inter_carry[2]);
full_adder full_adder_3(a[3],b[3],inter_carry[2],sum[3],inter_carry[3]);
full_adder full_adder_4(a[4],b[4],inter_carry[3],sum[4],inter_carry[4]);
full_adder full_adder_5(a[5],b[5],inter_carry[4],sum[5],inter_carry[5]);
full_adder full_adder_6(a[6],b[6],inter_carry[5],sum[6],inter_carry[6]);
full_adder full_adder_7(a[7],b[7],inter_carry[6],sum[7],inter_carry[7]);
full_adder full_adder_8(a[8],b[8],inter_carry[7],sum[8],inter_carry[8]);
full_adder full_adder_9(a[9],b[9],inter_carry[8],sum[9],inter_carry[9]);
full_adder full_adder_10(a[10],b[10],inter_carry[9],sum[10],inter_carry[10]);
full_adder full_adder_11(a[11],b[11],inter_carry[10],sum[11],inter_carry[11]);
full_adder full_adder_12(a[12],b[12],inter_carry[11],sum[12],inter_carry[12]);
full_adder full_adder_13(a[13],b[13],inter_carry[12],sum[13],inter_carry[13]);
full_adder full_adder_14(a[14],b[14],inter_carry[13],sum[14],inter_carry[14]);
full_adder full_adder_15(a[15],b[15],inter_carry[14],sum[15],inter_carry[15]);

assign carry = inter_carry[15];
    
endmodule