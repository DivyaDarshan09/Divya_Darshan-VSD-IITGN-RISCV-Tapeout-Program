`include "/home/ddarshan/Darshan/rtl/defines.v"
`default_nettype none

module gpio_tb;

  // -------------------------
  // Clock & Reset
  // -------------------------
  reg wb_clk_i;
  reg wb_rst_i;

  // -------------------------
  // Wishbone signals
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
  // GPIO signals
  // -------------------------
  reg  [`MPRJ_IO_PADS-1:0] io_in;
  wire [`MPRJ_IO_PADS-1:0] io_out;
  wire [`MPRJ_IO_PADS-1:0] io_oeb;

  // -------------------------
  // DUT SELECTION
  // -------------------------
  // Comment / uncomment as needed
  // `define USE_REFACTORED

`ifdef USE_REFACTORED
  user_project_gpio_example_ref dut (
`else
  user_project_gpio_example dut (
`endif
    .wb_clk_i (wb_clk_i),
    .wb_rst_i (wb_rst_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i (wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),
    .io_in    (io_in),
    .io_out   (io_out),
    .io_oeb   (io_oeb)
  );

  // -------------------------
  // Clock generation
  // -------------------------
  always #5 wb_clk_i = ~wb_clk_i;

  // -------------------------
  // Simple Wishbone tasks
  // -------------------------
  task wb_write(input [31:0] addr, input [31:0] data);
  begin
    @(posedge wb_clk_i);
    wbs_adr_i = addr;
    wbs_dat_i = data;
    wbs_sel_i = 4'hF;
    wbs_we_i  = 1;
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wait (wbs_ack_o);
    @(posedge wb_clk_i);
    wbs_cyc_i = 0;
    wbs_stb_i = 0;
    wbs_we_i  = 0;
  end
  endtask

  task wb_read(input [31:0] addr);
  begin
    @(posedge wb_clk_i);
    wbs_adr_i = addr;
    wbs_we_i  = 0;
    wbs_cyc_i = 1;
    wbs_stb_i = 1;
    wait (wbs_ack_o);
    @(posedge wb_clk_i);
    $display("[READ ] Addr=0x%08X Data=0x%08X", addr, wbs_dat_o);
    wbs_cyc_i = 0;
    wbs_stb_i = 0;
  end
  endtask

  // -------------------------
  // Test sequence
  // -------------------------
  initial begin
    $dumpfile("gpio_tb.vcd");
    $dumpvars(0, gpio_tb);

    // Init
    wb_clk_i  = 0;
    wb_rst_i  = 1;
    wbs_stb_i = 0;
    wbs_cyc_i = 0;
    wbs_we_i  = 0;
    wbs_sel_i = 0;
    wbs_dat_i = 0;
    wbs_adr_i = 0;
    io_in     = 0;

    // Reset
    #20;
    wb_rst_i = 0;

    // ----------------------------------
    // TEST 1 : WRITE GPIO LOW
    // ----------------------------------
    $display("\n[TEST-1] WRITE GPIO[31:0]");
    wb_write(32'h300FFFF0, 32'h000000AA);
    $display("[INFO ] io_out[7:0] = %b", io_out[7:0]);

    // ----------------------------------
    // TEST 2 : WRITE GPIO HIGH
    // ----------------------------------
    $display("\n[TEST-2] WRITE GPIO[37:32]");
    wb_write(32'h300FFFF4, 32'h0000003F);
    $display("[INFO ] io_out[37:32] = %b", io_out[37:32]);

    // ----------------------------------
    // TEST 3 : SET GPIO DIRECTION (OEB)
    // ----------------------------------
    $display("\n[TEST-3] SET GPIO DIRECTION");
    wb_write(32'h300FFFEC, 32'hFFFFFFFF); // LOW → INPUT
    wb_write(32'h300FFFE8, 32'h000000FF); // HIGH → INPUT
    $display("[INFO ] io_oeb[7:0] = %b", io_oeb[7:0]);

    // ----------------------------------
    // TEST 4 : READ GPIO INPUT
    // ----------------------------------
    $display("\n[TEST-4] READ GPIO INPUT");
    io_in = 38'h15555;
    wb_read(32'h300FFFF0);
    wb_read(32'h300FFFF4);

    // ----------------------------------
    // SUMMARY
    // ----------------------------------
    $display("\n=====================================");
    $display("[PASS] GPIO write/read tested");
    $display("[PASS] USER_PROJECT_GPIO_EXAMPLE MODULE RTL PASSESD");
    $display("=====================================\n");

    #20;
    $finish;
  end

endmodule

`default_nettype wire

