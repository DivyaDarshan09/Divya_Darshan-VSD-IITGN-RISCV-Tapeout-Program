// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_gpio_example
 *
 * GPIO test module
 *
 * NOTE:
 *  - This file intentionally keeps LEGACY RTL logic active.
 *  - A width-mismatch issue was identified in oeb_h handling.
 *  - A proposed fix is documented below and kept commented
 *    for verification and review purposes.
 *
 *-------------------------------------------------------------
 */

//`include "defines.v"

module user_project_gpio_example (
    // Wishbone Slave ports
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // GPIOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);

    // ---------------------------------------------------------
    // Internal Registers
    // ---------------------------------------------------------
    reg [31:0] io_l;      // GPIO[31:0]
    reg [5:0]  io_h;      // GPIO[37:32]

    reg [31:0] oeb_l;     // OEB[31:0]
    reg [5:0]  oeb_h;     // OEB[37:32]

    // ---------------------------------------------------------
    // Wishbone Interface Logic (LEGACY – ACTIVE)
    // ---------------------------------------------------------
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            io_l      <= 32'h0;
            io_h      <= 6'h0;
            oeb_l     <= 32'h0;
            oeb_h     <= 6'h0;
            wbs_dat_o <= 32'h0;
            wbs_ack_o <= 1'b0;

        end else if (wbs_cyc_i && wbs_stb_i && wbs_we_i &&
                     !wbs_ack_o &&
                     (wbs_adr_i == 32'h300FFFF4 ||
                      wbs_adr_i == 32'h300FFFF0 ||
                      wbs_adr_i == 32'h300FFFEC ||
                      wbs_adr_i == 32'h300FFFE8)) begin
            // -------------------------------------------------
            // WRITE TRANSACTION (LEGACY LOGIC)
            // -------------------------------------------------

            // GPIO[31:0]
            io_l[7:0]    <= ((wbs_adr_i == 32'h300FFFF0) && wbs_sel_i[0]) ? wbs_dat_i[7:0]   : io_l[7:0];
            io_l[15:8]   <= ((wbs_adr_i == 32'h300FFFF0) && wbs_sel_i[1]) ? wbs_dat_i[15:8]  : io_l[15:8];
            io_l[23:16]  <= ((wbs_adr_i == 32'h300FFFF0) && wbs_sel_i[2]) ? wbs_dat_i[23:16] : io_l[23:16];
            io_l[31:24]  <= ((wbs_adr_i == 32'h300FFFF0) && wbs_sel_i[3]) ? wbs_dat_i[31:24] : io_l[31:24];

            // GPIO[37:32]
            io_h[5:0] <= ((wbs_adr_i == 32'h300FFFF4) && wbs_sel_i[0]) ?
                          wbs_dat_i[5:0] : io_h[5:0];

            // OEB[31:0]
            oeb_l[7:0]    <= ((wbs_adr_i == 32'h300FFFEC) && wbs_sel_i[0]) ? wbs_dat_i[7:0]   : oeb_l[7:0];
            oeb_l[15:8]   <= ((wbs_adr_i == 32'h300FFFEC) && wbs_sel_i[1]) ? wbs_dat_i[15:8]  : oeb_l[15:8];
            oeb_l[23:16]  <= ((wbs_adr_i == 32'h300FFFEC) && wbs_sel_i[2]) ? wbs_dat_i[23:16] : oeb_l[23:16];
            oeb_l[31:24]  <= ((wbs_adr_i == 32'h300FFFEC) && wbs_sel_i[3]) ? wbs_dat_i[31:24] : oeb_l[31:24];

            // -------------------------------------------------
            // OEB[37:32] — LEGACY LOGIC (ACTIVE)
            // BUG:
            //   - oeb_h is only 6 bits wide
            //   - Code treats it as 32-bit register
            //   - Out-of-range bit assignments are ignored
            // -------------------------------------------------
            oeb_h[7:0]    <= ((wbs_adr_i==32'h300FFFE8) && wbs_sel_i[0]) ? wbs_dat_i[7:0]   : oeb_h[7:0];
            oeb_h[15:8]   <= ((wbs_adr_i==32'h300FFFE8) && wbs_sel_i[1]) ? wbs_dat_i[15:8]  : oeb_h[15:8];
            oeb_h[23:16]  <= ((wbs_adr_i==32'h300FFFE8) && wbs_sel_i[2]) ? wbs_dat_i[23:16] : oeb_h[23:16];
            oeb_h[31:24]  <= ((wbs_adr_i==32'h300FFFE8) && wbs_sel_i[3]) ? wbs_dat_i[31:24] : oeb_h[31:24];

            // -------------------------------------------------
            // PROPOSED FIX (UNDER VERIFICATION – NOT ACTIVE)
            //
            // if ((wbs_adr_i == 32'h300FFFE8) && wbs_sel_i[0]) begin
            //     oeb_h <= wbs_dat_i[5:0];
            // end
            //
            // RATIONALE:
            //   - Matches actual width of oeb_h
            //   - Avoids simulator-dependent truncation
            // -------------------------------------------------

            wbs_ack_o <= 1'b1;

        end else if (wbs_cyc_i && wbs_stb_i && !wbs_we_i &&
                     !wbs_ack_o &&
                     (wbs_adr_i == 32'h300FFFF4 ||
                      wbs_adr_i == 32'h300FFFF0 ||
                      wbs_adr_i == 32'h300FFFEC ||
                      wbs_adr_i == 32'h300FFFE8)) begin
            // -------------------------------------------------
            // READ TRANSACTION
            // -------------------------------------------------
            wbs_dat_o <= (wbs_adr_i == 32'h300FFFF0) ? io_in[31:0] :
                         (wbs_adr_i == 32'h300FFFF4) ? io_in[`MPRJ_IO_PADS-1:32] :
                         (wbs_adr_i == 32'h300FFFEC) ? io_oeb[31:0] :
                                                       io_oeb[37:32];

            wbs_ack_o <= 1'b1;

        end else begin
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h0;
        end
    end

    // ---------------------------------------------------------
    // GPIO Output Mapping
    // ---------------------------------------------------------
    assign io_out = {io_h, io_l};
    assign io_oeb = {oeb_h, oeb_l};

endmodule

`default_nettype wire

