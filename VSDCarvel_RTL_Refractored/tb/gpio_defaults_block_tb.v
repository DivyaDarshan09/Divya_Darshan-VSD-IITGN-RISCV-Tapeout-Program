`timescale 1ns/1ps
`default_nettype none

module gpio_defaults_block_tb;

    localparam int GPIO_BITS   = 13;
    localparam int TOTAL_CASES = 1 << GPIO_BITS;

    wire [GPIO_BITS-1:0] gpio_defaults [0:TOTAL_CASES-1];

    genvar cfg;
    generate
        for (cfg = 0; cfg < TOTAL_CASES; cfg = cfg + 1) begin : GEN_CFG
            gpio_defaults_block #(
                .GPIO_CONFIG_INIT(cfg[GPIO_BITS-1:0])
            ) dut (
                .gpio_defaults(gpio_defaults[cfg])
            );
        end
    endgenerate

    integer i;

    initial begin
        #1;

        $display("======================================================");
        $display(" GPIO DEFAULTS BLOCK – EXHAUSTIVE PRINT VERIFICATION");
        $display("======================================================");

        for (i = 0; i < TOTAL_CASES; i = i + 1) begin
            if (gpio_defaults[i] === i[GPIO_BITS-1:0]) begin
                $display("PASS | CFG=%04d (0x%04h) | OUT=%013b",
                         i, i, gpio_defaults[i]);
            end else begin
                $display("FAIL | CFG=%04d (0x%04h) | EXP=%013b | GOT=%013b",
                         i, i, i[GPIO_BITS-1:0], gpio_defaults[i]);
                $fatal;
            end
        end

        $display("======================================================");
        $display(" ✅ ALL %0d CONFIGURATIONS VERIFIED SUCCESSFULLY", TOTAL_CASES);
        $display("======================================================");

        $finish;
    end

endmodule

`default_nettype wire

