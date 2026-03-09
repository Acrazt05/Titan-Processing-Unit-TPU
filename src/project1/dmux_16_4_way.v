module dmux_16_4_way (
    input wire [15:0] in,
    input wire [1:0] sel,

    output wire [15:0] a,
    output wire [15:0] b,
    output wire [15:0] c,
    output wire [15:0] d
);

    assign a = sel == 2'b00 ? in : 0;
    assign b = sel == 2'b01 ? in : 0;
    assign c = sel == 2'b10 ? in : 0;
    assign d = sel == 2'b11 ? in : 0;
    
endmodule