`timescale 1ns/1ns

module spi_ram_sim_tb;

    reg spi_clock = 0;
    reg cs = 1;
    reg mosi = 0;
    wire miso;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------
    spi_ram_sim #(
        .MEMFILE("program.hex")
    ) dut (
        .spi_clock(spi_clock),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

    //--------------------------------------------------
    // Clock (SPI mode 0)
    //--------------------------------------------------
    always #1 spi_clock = ~spi_clock;

    //--------------------------------------------------
    // shift out + in one byte (mode 0)
    //--------------------------------------------------
    task spi_byte(input [7:0] tx, output [7:0] rx);
        integer i;
        begin
            rx = 0;

            for(i = 7; i >= 0; i = i - 1) begin

                // drive MOSI on falling edge
                @(negedge spi_clock);
                mosi = tx[i];

                // sample MISO on rising edge
                @(posedge spi_clock);
                rx[i] = miso;

            end
        end
    endtask

    //--------------------------------------------------
    // simple test
    //--------------------------------------------------
    reg [7:0] r;

    initial begin

        $dumpfile("wave_spi.vcd");
        $dumpvars(0, spi_ram_sim_tb);

        $display("===== SPI RAM SIMPLE TEST =====");

        #5;

        //--------------------------------------------------
        // WRITE 0xAA to address 0x1234
        //--------------------------------------------------
        cs = 0;

        spi_byte(8'h02, r);        // WRITE
        spi_byte(8'h12, r);        // ADDR high
        spi_byte(8'h34, r);        // ADDR low
        spi_byte(8'hAA, r);        // DATA

        cs = 1;

        #5;

        //--------------------------------------------------
        // READ back from 0x1234
        //--------------------------------------------------
        cs = 0;

        spi_byte(8'h03, r);        // READ
        spi_byte(8'h12, r);        // ADDR high
        spi_byte(8'h34, r);        // ADDR low
        spi_byte(8'h00, r);        // dummy byte (reads data)

        cs = 1;

        $display("READ RESULT = %02x (expected AA)", r);

        #10;

        $display("===== DONE =====");
        $finish;

    end

endmodule