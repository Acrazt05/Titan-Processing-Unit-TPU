`timescale 1ns/1ns

module spi_memory_tb;

    //==========================================================
    // Testbench signals
    //==========================================================
    reg clk;
    reg reset;

    reg ram_enabled;
    reg [13:0] ram_address;
    reg [13:0] rom_address;

    reg [15:0] ram_data_in;
    reg ram_write;

    wire [15:0] ram_data_out;
    wire [15:0] rom_data_out;

    wire data_ready;

    wire mosi;
    wire  miso;
    wire cs;
    wire spi_clock;

    //==========================================================
    // Instantiate DUT
    //==========================================================
    spi_memory dut (
        .clk(clk),
        .reset(reset),
        .ram_enabled(ram_enabled),
        .ram_address(ram_address),
        .rom_address(rom_address),
        .ram_data_in(ram_data_in),
        .ram_write(ram_write),
        .ram_data_out(ram_data_out),
        .rom_data_out(rom_data_out),
        .data_ready(data_ready),
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .spi_clock(spi_clock)
    );

    spi_ram_sim #(
        .MEMFILE("program.hex")
    ) spi_ram_sim_dut (
        .spi_clock(spi_clock),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

    //==========================================================
    // Clock generation (100 MHz)
    //==========================================================
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    //==========================================================
    // Test sequence
    //==========================================================
    initial begin

        $dumpfile("wave_spi.vcd");
        $dumpvars(0, spi_memory_tb);

        $display("Starting SPI memory testbench");

        reset = 1;
        //reset = 0;

        //------------------------------------------------------
        // Test 1 : ROM read
        //------------------------------------------------------
        //rom_address = 16'h0001;
        rom_address = 14'b00000000000010;
        ram_address = 14'b00000000000010;
        ram_enabled = 1;
        ram_data_in = 16'h0000;
        ram_write = 0;

        wait(data_ready);

        $display("ROM DATA = %h", rom_data_out);
        $display("RAM DATA = %h", ram_data_out);
        
        #5;

        //------------------------------------------------------
        // Test 3 : RAM write
        //------------------------------------------------------
        rom_address = 14'b00000000000010;
        ram_address = 14'b00000000000010;
        ram_enabled = 1;
        ram_data_in = 16'b1100000000000111;
        ram_write = 1;

        wait(data_ready);

        $display("RAM WRITE COMPLETE");
        $display("ROM DATA = %h", rom_data_out);
        $display("RAM DATA = %h", ram_data_out);

        //#100;
        
        $display("Simulation finished");
        $finish;

    end

endmodule