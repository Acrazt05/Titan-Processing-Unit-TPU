module spi_ram_sim #(
    parameter MEMFILE = "program.hex"
)(
    input  wire spi_clock,
    input  wire cs,
    input  wire mosi,
    output reg  miso
);

    //---------------------------------------------------
    // Memory
    //---------------------------------------------------
    reg [7:0] mem [0:65535];

    //---------------------------------------------------
    // SPI states
    //---------------------------------------------------
    localparam IDLE   = 0;
    localparam CMD    = 1;
    localparam ADDR_H = 2;
    localparam ADDR_L = 3;
    localparam READ   = 4;
    localparam WRITE  = 5;

    localparam SPI_READ  = 8'h03;
    localparam SPI_WRITE = 8'h02;

    reg [2:0] state = IDLE;

    reg [7:0] cmd;
    reg [7:0] shift_reg;

    reg [15:0] address;

    reg [2:0] bit_counter;

    //---------------------------------------------------
    // Debug files
    //---------------------------------------------------
    integer spi_log;
    integer dump_file;

    //---------------------------------------------------
    // Initialization
    //---------------------------------------------------
    initial begin

        // preload ROM program
        $readmemh(MEMFILE, mem);

        spi_log   = $fopen("spi_transactions.log","w");
        dump_file = $fopen("memory_dump.hex","w");

        $display("SPI RAM simulator initialized");
        $display("Loaded program: %s", MEMFILE);

        //---------------------------------------------------
        // Show first 5 memory locations
        //---------------------------------------------------
        /*$display("First 5 memory bytes:");
        $display("mem[%0d] = %02x", 0, mem[0]);
        $display("mem[%0d] = %02x", 1, mem[1]);
        $display("mem[%0d] = %02x", 2, mem[2]);
        $display("mem[%0d] = %02x", 3, mem[3]);
        $display("mem[%0d] = %02x", 4, mem[4]);*/

    end

    //---------------------------------------------------
    // Reset when CS goes high
    //---------------------------------------------------
    always @(negedge cs) begin
        state <= CMD;
        miso <= 0;
        bit_counter <= 7;
    end

    always @(posedge cs) begin
        state <= IDLE;
        miso <= 0;
        bit_counter <= 7;
    end

    //sample -> posedge (mosi)
    always @(posedge spi_clock ) begin
        if(cs == 0) begin 
            case (state)
                //------------------------------------------
                // Receive command
                //------------------------------------------
                CMD: begin

                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin

                        cmd <= {shift_reg[7:1], mosi};

                        $fwrite(spi_log,
                            "[%0t] CMD %02x\n",
                            $time,
                            {shift_reg[7:1], mosi}
                        );

                        bit_counter <= 7;
                        state <= ADDR_H;

                    end
                    else
                        bit_counter <= bit_counter - 1;

                end 
                //------------------------------------------
                // Address high
                //------------------------------------------
                ADDR_H: begin

                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin

                        address[15:8] <= {shift_reg[7:1], mosi};

                        bit_counter <= 7;
                        state <= ADDR_L;

                    end
                    else
                        bit_counter <= bit_counter - 1;

                end

                //------------------------------------------
                // Address low
                //------------------------------------------
                ADDR_L: begin

                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin

                        address[7:0] <= {shift_reg[7:1], mosi};

                        $fwrite(spi_log,
                            "[%0t] ADDR %04x\n",
                            $time,
                            {address[15:8], {shift_reg[7:1], mosi}}
                        );

                        bit_counter <= 7;

                        if(cmd == SPI_WRITE) begin
                            state <= WRITE;
                        end
                        else begin
                            state <= READ;
                        end
                    end
                    else
                        bit_counter <= bit_counter - 1;

                end

                //------------------------------------------
                // WRITE MODE
                //------------------------------------------
                WRITE: begin

                    shift_reg[bit_counter] <= mosi;
                    //$display("SPI bit: addr=%h bit=%d mosi=%b", address, bit_counter, mosi);

                    if(bit_counter == 0) begin

                        mem[address] <= {shift_reg[7:1], mosi};
                        //$display("SPI bit: addr=%h data=%h", address, mem[address]);

                        $fwrite(spi_log,
                            "[%0t] WRITE %04x = %02x\n",
                            $time,
                            address,
                            {shift_reg[7:1], mosi}
                        );

                        dump_memory();

                        address <= address + 1;
                        bit_counter <= 7;

                    end
                    else
                        bit_counter <= bit_counter - 1;

                end

            endcase
        end
    end

    //drive -> nedge (miso)
    always @(negedge spi_clock) begin
        //$display("state=%d", state); || (state==ADD_L && bit_counter == 0)
        if(cs == 0) begin 
            if(state==READ ) begin 
                //------------------------------------------
                // READ MODE
                //------------------------------------------

                miso <= mem[address][bit_counter];

                //$display("SPI bit: addr=%h bit=%d miso=%b", address, bit_counter, mem[address][bit_counter]);

                if(bit_counter == 0) begin

                    $fwrite(spi_log,
                        "[%0t] READ %04x -> %02x\n",
                        $time,
                        address,
                        mem[address]
                    );

                    address <= address + 1;
                    bit_counter <= 7;

                end
                else
                    bit_counter <= bit_counter - 1;

            end
        end
    end

    //---------------------------------------------------
    // Memory dump task
    //---------------------------------------------------
    task dump_memory;

        integer i;

        begin

            $fclose(dump_file);
            dump_file = $fopen("memory_dump.hex","w");

            for(i = 0; i < 65536; i = i + 1)
                $fdisplay(dump_file,"%02x",mem[i]);

        end

    endtask

endmodule