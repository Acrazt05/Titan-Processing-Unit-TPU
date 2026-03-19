`timescale 1ns/1ns

module computer_tb;

    reg clk = 0;
    reg reset = 1;

    // Instantiate your computer
    computer uut (
        .clk(clk),
        .reset(reset)
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
        #93;

        $finish;
    end

endmodule