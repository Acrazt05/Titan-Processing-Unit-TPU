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
    output reg [15:0] ram_data_out,
    output reg [15:0] rom_data_out,

    // Signals CPU when both accesses finished
    output reg data_ready,

    // SPI pins
    output reg mosi,
    input miso,
    output reg cs,
    output spi_clock
);

    //==========================================================
    // Memory layout inside SPI RAM
    //
    // Each Hack word = 2 bytes
    //
    // ROM  : 0x0000 - 0x7FFF  (byte addresses)
    // RAM  : 0x8000 - 0xFFFF
    //==========================================================
    parameter RAM_OFFSET = 16'h8000;

    //==========================================================
    // SPI clock generation
    //==========================================================
    //==========================================================
    // Internal registers
    //==========================================================

    // SPI transmit register
    reg [7:0] shift_reg;

    // counts bits being transmitted
    reg [2:0] bit_counter;

    // current SPI byte address
    reg [15:0] spi_address;

    // stores bytes received from SPI
    reg [7:0] byte0;
    reg [7:0] byte1;

    // FSM state register
    reg [3:0] state;

    reg dummy_bit;

    reg [15:0] buffer_ram_data_out;
    reg [15:0] buffer_rom_data_out;

    //==========================================================
    // SPI command values
    //==========================================================
    localparam SPI_READ  = 8'h03;
    localparam SPI_WRITE = 8'h02;

    //==========================================================
    // State Machine
    //==========================================================
    localparam IDLE            = 0;

    localparam ROM_CMD         = 1;
    localparam ROM_ADDR_H      = 2;
    localparam ROM_ADDR_L      = 3;
    localparam ROM_DATA_0      = 4;
    localparam ROM_DATA_1      = 5;

    localparam RAM_CMD         = 6;
    localparam RAM_ADDR_H      = 7;
    localparam RAM_ADDR_L      = 8;
    localparam RAM_DATA_0      = 9;
    localparam RAM_DATA_1      = 10;

    localparam RAM_WRITE_DATA0 = 11;
    localparam RAM_WRITE_DATA1 = 12;

    localparam DONE            = 13;

    reg spi_phase;

    reg [1:0] counter;
    wire clk_en = (counter == 2'd3);
    assign spi_clock = clk_en;

    always @(posedge clk or posedge reset) begin
        if(reset || data_ready) begin //TODO: maybe don't need data_ready here
            spi_phase <= 0;
            state <= IDLE;
            cs <= 1;
            data_ready <= 0;
            mosi <= 0;
            dummy_bit <= 1'b0;
            counter <= 2'd0;

        end 
    end

endmodule