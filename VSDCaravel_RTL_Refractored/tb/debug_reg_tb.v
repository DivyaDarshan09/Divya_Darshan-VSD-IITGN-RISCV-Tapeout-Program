`default_nettype wire

module debug_reg_tb;

  // -------------------------
  // Clock & Reset
  // -------------------------
  reg wb_clk_i;
  reg wb_rst_i;

  // -------------------------
  // Wishbone Interface
  // -------------------------
  reg         wbs_stb_i;
  reg         wbs_cyc_i;
  reg         wbs_we_i;
  reg  [3:0]  wbs_sel_i;
  reg  [31:0] wbs_dat_i;
  reg  [31:0] wbs_adr_i;
  wire        wbs_ack_o;
  wire [31:0] wbs_dat_o;

  // -------------------------
  // ASCII DATA (VALID HEX)
  // -------------------------
  localparam [31:0] REG1_DATA = 32'h56534431; // "VSD1"
  localparam [31:0] REG2_DATA = 32'h52495343; // "RISC"

  // -------------------------
  // DUT
  // -------------------------
  debug_regs dut (
    .wb_clk_i  (wb_clk_i),
    .wb_rst_i  (wb_rst_i),
    .wbs_stb_i (wbs_stb_i),
    .wbs_cyc_i (wbs_cyc_i),
    .wbs_we_i  (wbs_we_i),
    .wbs_sel_i (wbs_sel_i),
    .wbs_dat_i (wbs_dat_i),
    .wbs_adr_i (wbs_adr_i),
    .wbs_ack_o (wbs_ack_o),
    .wbs_dat_o (wbs_dat_o)
  );

  // Clock
  always #5 wb_clk_i = ~wb_clk_i;

  initial begin
    $dumpfile("debug_reg_tb.vcd");
    $dumpvars(0, debug_reg_tb);

    // Init
    wb_clk_i  = 0;
    wb_rst_i  = 1;
    wbs_stb_i = 0;
    wbs_cyc_i = 0;
    wbs_we_i  = 0;
    wbs_sel_i = 4'h0;
    wbs_dat_i = 32'h0;
    wbs_adr_i = 32'h0;

    #20 wb_rst_i = 0;

// ==================================================
    // TEST-1 : NO TRANSACTION (IDLE)
    // ==================================================
 $display("\n==============================================");
    $display("\n[TEST-1] NO TRANSACTION (IDLE STATE)");
    @(posedge wb_clk_i);
    if (wbs_ack_o === 1'b0 && wbs_dat_o === 32'h0)
      $display("[PASS] Idle state OK (ACK=0, DATA=0)");
    else begin
      $display("[FAIL] Idle state incorrect");
      $finish;
    end

    // ==================================================
    // TEST-2 : WRITE debug_reg_1 (VSD1)
    // ==================================================
    $display("\n[TEST-2] WRITE debug_reg_1");
    $display("[INFO] Addr = 0x08, Data = VSD1");

    @(posedge wb_clk_i);
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wbs_we_i  = 1;
    wbs_sel_i = 4'hF;
    wbs_adr_i = 32'h8;
    wbs_dat_i = REG1_DATA;

    wait (wbs_ack_o);
    @(posedge wb_clk_i);
    wbs_cyc_i = 0; wbs_stb_i = 0; wbs_we_i = 0;

    $display("[PASS] Write successful");

    // ==================================================
    // TEST-3 : READ debug_reg_1
    // ==================================================
    $display("\n[TEST-3] READ debug_reg_1");

    @(posedge wb_clk_i);
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wbs_we_i  = 0;
    wbs_adr_i = 32'h8;

    wait (wbs_ack_o);
    @(posedge wb_clk_i);

    $display("[INFO] Read Data (HEX)  : 0x%08X", wbs_dat_o);
    $display("[INFO] Read Data (ASCII): %c%c%c%c",
              wbs_dat_o[31:24], wbs_dat_o[23:16],
              wbs_dat_o[15:8],  wbs_dat_o[7:0]);

    if (wbs_dat_o == REG1_DATA)
      $display("[PASS] Data matched (VSD1)");
    else $fatal(1, "[FAIL] Data mismatch");

    wbs_cyc_i = 0; wbs_stb_i = 0;

    // ==================================================
    // TEST-4 : WRITE debug_reg_2 (RISC)
    // ==================================================
    $display("\n[TEST-4] WRITE debug_reg_2");
    $display("[INFO] Addr = 0x0C, Data = RISC");

    @(posedge wb_clk_i);
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wbs_we_i  = 1;
    wbs_sel_i = 4'hF;
    wbs_adr_i = 32'hC;
    wbs_dat_i = REG2_DATA;

    wait (wbs_ack_o);
    @(posedge wb_clk_i);
    wbs_cyc_i = 0; wbs_stb_i = 0; wbs_we_i = 0;

    $display("[PASS] Write successful");

    // ==================================================
    // TEST-5 : READ debug_reg_2
    // ==================================================
    $display("\n[TEST-5] READ debug_reg_2");

    @(posedge wb_clk_i);
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wbs_we_i  = 0;
    wbs_adr_i = 32'hC;

    wait (wbs_ack_o);
    @(posedge wb_clk_i);

    $display("[INFO] Read Data (HEX)  : 0x%08X", wbs_dat_o);
    $display("[INFO] Read Data (ASCII): %c%c%c%c",
              wbs_dat_o[31:24], wbs_dat_o[23:16],
              wbs_dat_o[15:8],  wbs_dat_o[7:0]);

    if (wbs_dat_o == REG2_DATA)
      $display("[PASS] Data matched (RISC)");
    else $fatal(1, "[FAIL] Data mismatch");

    wbs_cyc_i = 0; wbs_stb_i = 0;

    // ==================================================
    // SUMMARY
    // ==================================================
    $display("\n==============================================");
    $display("[SUMMARY]");
    $display("[PASS] Idle verified");
    $display("[PASS] debug_reg_1 (VSD1) verified");
    $display("[PASS] debug_reg_2 (RISC) verified");
    $display("[PASS] VSD Caravel Debug RTL – VALIDATED");
    $display("[PASS] India RISC-V Tapeout Program READY");
    $display("==============================================\n");

 $display("==============================================\n");
    #20 $finish;
  end

endmodule

`default_nettype wire

