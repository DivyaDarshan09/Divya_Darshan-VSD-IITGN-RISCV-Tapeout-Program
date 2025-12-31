`timescale 1ns/1ps
`default_nettype none

module tb_scl180_marco_sparecell;

    wire LO;

`ifdef USE_POWER_PINS
    // Power rails must be NETS, not variables
    wire VPWR;
    wire VGND;

    // Drive power rails
    assign VPWR = 1'b1;
    assign VGND = 1'b0;
`endif

    // DUT instantiation
    scl180_marco_sparecell dut (
`ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
`endif
        .LO(LO)
    );

    initial begin
    $dumpfile("tb_scl180_marco_sparecell.vcd");
    $dumpvars(0, tb_scl180_marco_sparecell);
        $display("======================================");
        $display(" Spare Cell Verification (Power-Aware)");
        $display("======================================");

        #5;

        $display("LO = %b", LO);

        if (LO !== 1'b0) begin
            $display("❌ ERROR: LO is not tied low");
            $fatal;
        end

        if (^LO === 1'bX) begin
            $display("❌ ERROR: LO is X or Z");
            $fatal;
        end

        $display("✅ PASS: LO is stable, tied low, no X/Z");
        $display("======================================");
        $finish;
    end

endmodule

`default_nettype wire

