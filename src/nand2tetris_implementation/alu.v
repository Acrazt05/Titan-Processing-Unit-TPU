module alu (
    //input data
    input wire [15:0] x,
    input wire [15:0] y,

    //control bits (can potentially code 128 different calculations)
    input wire zx,
    input wire nx,
    input wire zy,
    input wire ny,
    input wire f,
    input wire no,

    //
    output wire zr,
    output wire ng,

    //output data
    output wire [15:0] out
);

    wire [15:0] inter_x_1 = zx ? 16'd0 : x; 
    wire [15:0] inter_x_2 = nx ? ~inter_x_1 : inter_x_1;

    wire [15:0] inter_y_1 = zy ? 16'd0 : y; 
    wire [15:0] inter_y_2 = ny ? ~inter_y_1 : inter_y_1;

    wire [15:0] inter_out_1 = f ? inter_x_2 + inter_y_2 : inter_x_2 & inter_y_2;
    wire [15:0] inter_out_2 = no ? ~inter_out_1 : inter_out_1;

    assign out = inter_out_2;
    assign zr = out == 16'd0 ? 1 : 0;
    assign ng = out[15]; // MSB = negative in 2's complement

endmodule