module spi_clock_generator (
    input  wire clk,
    input  wire reset,
    output wire clk_en
);
    //TODO: remove!
    //assign clk_en = clk;

    // 3-bit counter to count 0-7 (8 states)
    reg [2:0] counter = 3'd0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 3'd0;
        end else begin
            counter <= counter + 3'd1;
        end
    end

    // Pulse high when counter wraps around
    assign clk_en = (counter == 3'd7);

endmodule

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
    input [13:0] ram_address, //TODO: actually both 14-bit address spaces, will keep the 2 bits but will ignore for now
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
    
    spi_clock_generator spi_clock_gen(
        .clk(clk),
        .reset(reset),
        .clk_en(spi_clock)
    );

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


    always @(posedge clk ) begin
        if(data_ready == 1) begin
            state <= IDLE;
            cs <= 1;
            data_ready <= 0;
            mosi <= 0;
            dummy_bit <= 1'b0;
        end
    end

    always @(posedge reset) begin
        state <= IDLE;
        cs <= 1;
        data_ready <= 0;
        mosi <= 0;
        dummy_bit <= 1'b0;
    end


    //drive mosi
    always @(negedge spi_clock) begin
        case(state)

            //==========================================================
            // Send READ command for ROM
            //==========================================================
            ROM_CMD: begin

                //$display("SPI CMD MOSI bitr=%h bit_counter=%h", shift_reg[bit_counter], bit_counter);

                mosi <= shift_reg[bit_counter]; //set mosi to the 1st bit to be sent (starts with command)

                if(bit_counter == 0) begin //when bit_counter = 0 -> command has finished being sent
                    shift_reg <= spi_address[15:8]; //select 1st byte from the rom address to be sent
                    bit_counter <= 7; //restart bit counter to start sending rom address byte 1
                    state <= ROM_ADDR_H; //move on to next state(send rom address byte 1)
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be sent

            end

            //==========================================================
            // Send ROM address high byte
            //==========================================================
            ROM_ADDR_H: begin
                //$display("SPI ROM_ADDR_H MOSI bit=%h bit_counter=%h", shift_reg[bit_counter], bit_counter);

                mosi <= shift_reg[bit_counter]; //send bits from rom_address byte 1

                if(bit_counter == 0) begin //1st rom address byte has been sent
                    shift_reg <= spi_address[7:0];  //select 2nd byte from the rom address to be sent
                    bit_counter <= 7; //restart bit counter to start sending rom address byte 2
                    state <= ROM_ADDR_L; //move on to next state(send rom address byte 2)
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be sent (keep doing this every clk cycle until all bits are sent)

            end

            //==========================================================
            // Send ROM address low byte
            //==========================================================
            ROM_ADDR_L: begin
                //$display("SPI ROM_ADDR_L MOSI bitr=%h bit_counter=%h", shift_reg[bit_counter], bit_counter);

                mosi <= shift_reg[bit_counter]; //send bits from rom_address byte 2

                if(bit_counter == 0) begin //2nd rom address byte has been sent
                    bit_counter <= 7; //restart bit counter to start receiving rom data byte 1
                    state <= ROM_DATA_0;  //move on to next state(receive rom data byte 1)
                    dummy_bit <= 1'b1;  
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be sent (keep doing this every clk cycle until all bits are sent)

            end

            //==========================================================
            // Send RAM command
            //==========================================================
            RAM_CMD: begin
                cs <= 0;
                mosi <= shift_reg[bit_counter]; //output each ram cmd bit 

                if(bit_counter == 0) begin //when bit_counter = 0 -> ram command has finished being sent
                    shift_reg <= spi_address[15:8]; //select 1st byte from the ram address to be sent
                    bit_counter <= 7; //restart bit counter to start sending ram address byte 1
                    state <= RAM_ADDR_H; //move on to next state(send ram address byte 1)
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be sent

            end

            //==========================================================
            // Send RAM address high byte
            //==========================================================
            RAM_ADDR_H: begin

                mosi <= shift_reg[bit_counter];  //send bits from ram_address byte 1

                if(bit_counter == 0) begin //1st ram address byte has been sent
                    shift_reg <= spi_address[7:0]; //select 2nd byte from the ram address to be sent
                    bit_counter <= 7; //restart bit counter to start sending ram address byte 2
                    state <= RAM_ADDR_L; //move on to next state(send ram address byte 2)
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be sent 

            end

            //==========================================================
            // Send RAM address low byte
            //==========================================================
            RAM_ADDR_L: begin

                mosi <= shift_reg[bit_counter]; //send bits from ram_address byte 2

                if(bit_counter == 0) begin //2nd ram address byte has been sent

                    bit_counter <= 7; //restart bit counter to start reading or writing ram data byte 1

                    if(ram_write) //decide wether to read or write to memory (1st byte)
                        state <= RAM_WRITE_DATA0;
                    else begin
                        state <= RAM_DATA_0;
                        dummy_bit <= 1'b1;
                    end

                end
                else
                    bit_counter <= bit_counter - 1;  //there is one less bit to be sent 

            end


            //==========================================================
            // Write RAM byte 0
            //==========================================================
            RAM_WRITE_DATA0: begin

                //mosi <= ram_data_in[15 - bit_counter];
                mosi <= ram_data_in[7 + bit_counter];

                if(bit_counter == 0) begin
                    bit_counter <= 7;
                    state <= RAM_WRITE_DATA1;
                end
                else
                    bit_counter <= bit_counter - 1;

            end

            //==========================================================
            // Write RAM byte 1
            //==========================================================
            RAM_WRITE_DATA1: begin

                //mosi <= ram_data_in[7 - bit_counter];
                mosi <= ram_data_in[bit_counter];

                if(bit_counter == 0)
                    state <= DONE;
                else
                    bit_counter <= bit_counter - 1;

            end
        endcase

    end

    //==========================================================
    // Main SPI controller
    //==========================================================
    always @(posedge spi_clock) begin
        case(state)
 
           //==========================================================
            // IDLE
            //
            // Start a new CPU cycle.
            // First we fetch the instruction from ROM.
            //==========================================================
            IDLE: begin

                cs <= 0;               // start SPI transaction
                data_ready <= 0;       //tell the cpu to wait for data (stall pc)

                // Convert CPU word address → SPI byte address
                // The SPI Memory uses 8-bit words and the CPU uses 16 bit words
                // Address is shifthed left (multiplied by 2) to account for that
                // i.e. 0 -> will return spi memory address [0,1] on the spi transaction
                // 1 -> [2,3], 2 -> [4,5] an etc... ¨ 
                spi_address <= rom_address << 1;

                shift_reg <= SPI_READ; //Read command (0x03)
                bit_counter <= 7; //how many bits are left to transfer (8 in this case (a read command))

                state <= ROM_CMD; //move on to next state

            end

            //==========================================================
            // Receive ROM byte 0
            //==========================================================
            ROM_DATA_0: begin

                if(dummy_bit) begin
                    dummy_bit <= 1'b0;
                end else begin
                    /*if(bit_counter == 7) begin
                        $display("receiving 1st ROM bit: %b", miso);
                    end*/

                    byte0[bit_counter] <= miso; //save each incomming bit (from rom data byte 1)

                    if(bit_counter == 0) begin //1st rom data byte has been received
                        bit_counter <= 7; //restart bit counter to start receiving rom data byte 2
                        state <= ROM_DATA_1;  //move on to next state(receive rom data byte 2)
                    end
                    else
                        bit_counter <= bit_counter - 1;  //there is one less bit to be received 
                end
            end

            //==========================================================
            // Receive ROM byte 1
            //
            // Combine two bytes → 16-bit instruction
            //==========================================================
            ROM_DATA_1: begin

                byte1[bit_counter] <= miso;  //save each incomming bit (from rom data byte 2)

                if(bit_counter == 0) begin //2nd rom data byte has been received (move on to ram write/read cmd)

                    buffer_rom_data_out <= {byte0, byte1[7:1], miso}; //combine both bytes into 16-bit word instruction to give back to cpu

                    if (ram_enabled) begin
                        // Prepare RAM access (note that spi_address get overwritten with the new ram value instead of the rom value)
                        spi_address <= (ram_address << 1) + RAM_OFFSET; //same as before, multiply by two but also add offset to get to ram partition

                        if(ram_write) //decide wether or not to read or write to ram memory
                            shift_reg <= SPI_WRITE; //save command
                        else
                            shift_reg <= SPI_READ; //save command

                        bit_counter <= 7; //restart bit counter to start sending read or write ram cmd

                        state <= RAM_CMD; //move on to next state (send ram command (read or write)) (we don't use fast read)
                        cs <= 1;

                    end else begin
                        state <= DONE; //finish transaction, RAM doesn't need to be read
                        //cs <= 1;
                        //data_ready <= 1;
                    end
                end
                else
                    bit_counter <= bit_counter - 1; //there is one less bit to be received 

            end

            //==========================================================
            // Receive RAM byte 0
            //==========================================================
            RAM_DATA_0: begin
                if(dummy_bit) begin
                    dummy_bit <= 1'b0;
                end else begin
                    byte0[bit_counter] <= miso;

                    if(bit_counter == 0) begin
                        bit_counter <= 7;
                        state <= RAM_DATA_1;
                    end
                    else
                        bit_counter <= bit_counter - 1;
                end
            end

            //==========================================================
            // Receive RAM byte 1
            //==========================================================
            RAM_DATA_1: begin

                byte1[bit_counter] <= miso;

                if(bit_counter == 0) begin

                    buffer_ram_data_out <= {byte0, byte1[7:1], miso};

                    state <= DONE;

                end
                else
                    bit_counter <= bit_counter - 1;

            end

            //==========================================================
            // Finish transaction
            //==========================================================
            DONE: begin
                if(ram_enabled == 1) begin
                    ram_data_out <= buffer_ram_data_out;
                end else begin
                    ram_data_out <= 16'b0;
                end

                rom_data_out <= buffer_rom_data_out;
                cs <= 1;
                data_ready <= 1;
                state <= IDLE;

            end
        endcase
    end

endmodule