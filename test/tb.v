`timescale 1ns/1ns

module computer_tb;

    reg clk = 0;
    reg rst_n = 0;

    reg [7:0] ui_in = 8'hA;
    wire [7:0] uo_out;
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // DUT
    tt_um_Acrazt05_titan_proccesing_unit uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // SPI wiring
    wire cs   = uio_out[0];
    wire mosi = uio_out[1];
    wire miso;
    wire sck  = uio_out[3];

    assign uio_in = {5'b0, miso, 2'b0};

    spi_ram_sim memory_tb (
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .spi_clock(sck)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $display("Simulation initiated. ui_in = %h", ui_in);

        $dumpfile("tb.fst");
        $dumpfile("wave.vcd");
        $dumpvars(0, computer_tb);

        // RESET (active low!)
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;

        // Let program run
        repeat (50000) @(posedge clk);

        $display("Simulation finished. uo_out = %h", uo_out);
        $finish;
    end

endmodule