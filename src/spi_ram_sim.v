module spi_ram_sim (
    input  wire spi_clock,
    input  wire cs,
    input  wire mosi,
    output reg  miso
);

    //====================================================
    // 64KB memory
    //====================================================
    reg [7:0] mem [0:65535];

    //====================================================
    // SPI state machine
    //====================================================
    localparam IDLE      = 0;
    localparam CMD       = 1;
    localparam ADDR_H    = 2;
    localparam ADDR_L    = 3;
    localparam READ      = 4;
    localparam WRITE     = 5;

    localparam SPI_READ  = 8'h03;
    localparam SPI_WRITE = 8'h02;

    reg [2:0] state = IDLE;

    reg [7:0] shift_reg;
    reg [2:0] bit_counter = 7;

    reg [15:0] address;

    //====================================================
    // Debug file
    //====================================================
    integer logfile;
    integer dumpfile;

    initial begin
        logfile = $fopen("spi_ram_writes.log","w");
        dumpfile = $fopen("spi_ram_dump.hex","w");
    end

    //====================================================
    // Reset state when CS goes high
    //====================================================
    always @(posedge cs) begin
        state <= IDLE;
        bit_counter <= 7;
    end

    //====================================================
    // SPI operation
    //====================================================
    always @(posedge spi_clock) begin

        if(cs)
            miso <= 0;

        else begin

            case(state)

                //------------------------------------------
                // IDLE -> receive command
                //------------------------------------------
                IDLE: begin
                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin
                        bit_counter <= 7;

                        if({shift_reg[7:1], mosi} == SPI_READ)
                            state <= ADDR_H;
                        else if({shift_reg[7:1], mosi} == SPI_WRITE)
                            state <= ADDR_H;
                        else
                            state <= IDLE;

                        shift_reg <= 0;
                    end
                    else
                        bit_counter <= bit_counter - 1;
                end


                //------------------------------------------
                // address high
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
                // address low
                //------------------------------------------
                ADDR_L: begin
                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin
                        address[7:0] <= {shift_reg[7:1], mosi};
                        bit_counter <= 7;

                        if(shift_reg == SPI_WRITE)
                            state <= WRITE;
                        else
                            state <= READ;
                    end
                    else
                        bit_counter <= bit_counter - 1;
                end


                //------------------------------------------
                // READ MODE
                //------------------------------------------
                READ: begin

                    miso <= mem[address][bit_counter];

                    if(bit_counter == 0) begin
                        bit_counter <= 7;
                        address <= address + 1;
                    end
                    else
                        bit_counter <= bit_counter - 1;

                end


                //------------------------------------------
                // WRITE MODE
                //------------------------------------------
                WRITE: begin

                    shift_reg[bit_counter] <= mosi;

                    if(bit_counter == 0) begin

                        mem[address] <= {shift_reg[7:1], mosi};

                        $fwrite(logfile,
                            "WRITE %04h = %02h at time %0t\n",
                            address,
                            {shift_reg[7:1], mosi},
                            $time
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


    //====================================================
    // Dump entire memory to hex file
    //====================================================
    task dump_memory;
        integer i;
        begin
            $fclose(dumpfile);
            dumpfile = $fopen("spi_ram_dump.hex","w");

            for(i=0;i<65536;i=i+1)
                $fdisplay(dumpfile,"%02x",mem[i]);

        end
    endtask


endmodule