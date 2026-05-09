`timescale 1ns/1ns

module computer_tb;

    reg clk = 0;
    reg reset = 0;

    wire [7:0] ui_in = 8'hA;
    wire [7:0] uo_out;
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate your computer
    tt_um_titan_proccesing_unit uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(reset)
    );

    /*
        uio[0] - GPIO21 - CS
        uio[1] - GPIO22 - MOSI
        uio[2] - GPIO23 - MISO
        uio[3] - GPIO24 - SCK

    */

    wire cs = uio_out[0];
    wire mosi = uio_out[1];
    wire miso;// = uio_in[2];
    wire sck = uio_out[3];

    assign uio_in = {
        5'b0, miso, 2'b00
    };

    spi_ram_sim memory_tb(
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .spi_clock(sck)
    );

    // Clock: 10ns period (100 MHz equivalent simulation)
    always #1 clk = ~clk;

    initial begin
        // Waveform dump
        $dumpfile("wave.vcd");
        $dumpvars(0, computer_tb);
        //$dumpvars(0, memory_tb);

        // Reset sequence
        #1;
        reset = 1;

        // Run long enough for programs to execute
        #200001;

        $finish;
    end

endmodule