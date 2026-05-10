//==========================================================
// SPI MEMORY
//
// This module allows the Hack CPU to use SPI RAM as if it
// were normal ROM and RAM.
//
// CPU sees:
//   ROM address space starting at 0
//   RAM address space starting at 0
//
// Internally we convert addresses to byte addresses for SPI.
//==========================================================
module spi_memory (
    input clk,
    input reset,
    input ram_enabled, //0 -> only read ROM, 1 -> read both ROM and RAM

    // CPU addresses (WORD addresses)
    input [13:0] ram_address, 
    input [13:0] rom_address,

    // RAM write interface
    input [15:0] ram_data_in,
    input ram_write,

    // Data returned to CPU
    output [15:0] ram_data_out,
    output [15:0] rom_data_out,

    // Signals CPU when both accesses finished
    output data_ready,

    // SPI pins
    output mosi,
    input miso,
    output cs,
    output spi_clock
);

    assign ram_data_out = 16'b0;
    assign rom_data_out = 16'b0;
    assign data_ready = 1'b0;
    assign mosi = 1'b0;
    assign cs = 1'b0;
    assign spi_clock = 1'b0;
 
endmodule