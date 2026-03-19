module keyboard (
    output reg [15:0] out,
    input clk
);

    integer f;
    integer value;
    integer test;

    initial out = 0;

    always @(posedge clk) begin
        f = $fopen("keyboard.bin", "r");
        if (f) begin
            test = $fscanf(f, "%d", value);
            out <= value;
            $fclose(f);
        end
    end

endmodule