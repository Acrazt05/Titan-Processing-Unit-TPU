`include "half_adder.v"

module full_adder (
    input wire a,
    input wire b,
    input wire c,

    output wire sum,
    output wire carry
);

    wire ABSum;
    wire ABCarry;
    
    wire ABCCarry;

    //a,b,sum,carry
    half_adder half_adder_1(a,b,ABSum,ABCarry);
    half_adder half_adder_2(c,ABSum,sum,ABCCarry);

    assign carry = ABCarry | ABCCarry;

endmodule