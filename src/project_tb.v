`timescale 1ns/1ns

module computer_tb;

    reg clk = 0;
    reg reset = 0;

    // Instantiate your computer
    tt_um_titan_proccesing_unit uut (
        .ui_in(8'b0),
        .uo_out(),
        .uio_in(8'b0),
        .uio_out(),
        .uio_oe(),
        .ena(1),
        .clk(clk),
        .rst_n(reset)
    );

    // Clock: 10ns period (100 MHz equivalent simulation)
    always #1 clk = ~clk;

    initial begin
        // Waveform dump
        $dumpfile("wave.vcd");
        $dumpvars(0, computer_tb);

        // Reset sequence
        #1;
        reset = 0;

        // Run long enough for programs to execute
        #1001;

        $finish;
    end

endmodule