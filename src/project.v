/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`include "computer.v"

module tt_um_titan_proccesing_unit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  /*
  uio[0] - GPIO21 - CS
  uio[1] - GPIO22 - MOSI
  uio[2] - GPIO23 - MISO
  uio[3] - GPIO24 - SCK

  */

  assign uio_oe[3:0] = 4'b1101; 

  wire cs = uio_out[0];
  wire mosi = uio_out[1];
  wire miso = uio_in[2];
  wire sck = uio_out[3];

  computer tpu(

    //TODO: add fucntionality to drive GPIO pins
    //TODO: add vga (if will do)

    .reset(~rst_n),
    .clk(clk),

    .mosi(mosi),
    .miso(miso),
    .cs(cs),
    .spi_clock(sck)
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
