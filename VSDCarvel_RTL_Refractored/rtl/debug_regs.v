`default_nettype wire
// module that has registers used for debug
module debug_regs (    
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o);

    reg [31:0] debug_reg_1;
    reg [31:0] debug_reg_2;

 

 // write
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            debug_reg_1 <=0;
            debug_reg_2 <=0;
            wbs_dat_o   <=0;
            wbs_ack_o   <=0;
        end else if (wbs_cyc_i && wbs_stb_i && wbs_we_i && !wbs_ack_o && (wbs_adr_i[3:0]==4'hC||wbs_adr_i[3:0]==4'h8))begin // write
            // write to reg1
            debug_reg_1[7:0]    <= ((wbs_adr_i[3:0]==4'h8) && wbs_sel_i[0])?  wbs_dat_i[7:0]   :debug_reg_1[7:0];
            debug_reg_1[15:8]   <= ((wbs_adr_i[3:0]==4'h8) && wbs_sel_i[1])?  wbs_dat_i[15:8]  :debug_reg_1[15:8];
            debug_reg_1[23:16]  <= ((wbs_adr_i[3:0]==4'h8) && wbs_sel_i[2])?  wbs_dat_i[23:16] :debug_reg_1[23:16];
            debug_reg_1[31:24]  <= ((wbs_adr_i[3:0]==4'h8) && wbs_sel_i[3])?  wbs_dat_i[31:24] :debug_reg_1[31:24];
            // write to reg2
            debug_reg_2[7:0]    <= ((wbs_adr_i[3:0]==4'hC) && wbs_sel_i[0])?  wbs_dat_i[7:0]   :debug_reg_2[7:0];
            debug_reg_2[15:8]   <= ((wbs_adr_i[3:0]==4'hC) && wbs_sel_i[1])?  wbs_dat_i[15:8]  :debug_reg_2[15:8];
            debug_reg_2[23:16]  <= ((wbs_adr_i[3:0]==4'hC) && wbs_sel_i[2])?  wbs_dat_i[23:16] :debug_reg_2[23:16];
            debug_reg_2[31:24]  <= ((wbs_adr_i[3:0]==4'hC) && wbs_sel_i[3])?  wbs_dat_i[31:24] :debug_reg_2[31:24];
            wbs_ack_o <= 1;
        end else if (wbs_cyc_i && wbs_stb_i && !wbs_we_i && !wbs_ack_o && (wbs_adr_i[3:0]==4'hC||wbs_adr_i[3:0]==4'h8)) begin // read 
            wbs_dat_o <= ((wbs_adr_i[3:0]==4'hC)) ? debug_reg_2 : debug_reg_1; 
            wbs_ack_o <= 1;
        end else begin 
            wbs_ack_o <= 0;
            wbs_dat_o <= 0;
        end
    end




    //--------------------------------------------------------------------------
    // New Updated logic for verification 
    //--------------------------------------------------------------------------
   //   This will not force the wbs_dat_o to 0 when no transaction initiated. 
   //--------------------------------------------------------------------------  
   // Holds the previous state value
   //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Wishbone transaction detect
    // A transaction is active when:
    //   - cyc & stb are asserted by master
    //   - slave has not yet acknowledged
    //--------------------------------------------------------------------------
    

 /*   wire wb_trans;
    assign wb_trans = wbs_cyc_i && wbs_stb_i && !wbs_ack_o;

  
  always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            // Reset state
            debug_reg_1 <= 32'h0;
            debug_reg_2 <= 32'h0;
            wbs_dat_o   <= 32'h0;
            wbs_ack_o   <= 1'b0;
        end else begin
            // Default: ACK deasserted
            // ACK is a one-cycle pulse and must be explicitly asserted
            wbs_ack_o <= 1'b0;

            //------------------------------------------------------------------
            // WRITE transaction
            //------------------------------------------------------------------
            if (wb_trans && wbs_we_i) begin
                if (wbs_adr_i[3:0] == 4'h8) begin
                    // Write to debug_reg_1 (byte-wise)
                    if (wbs_sel_i[0]) debug_reg_1[7:0]   <= wbs_dat_i[7:0];
                    if (wbs_sel_i[1]) debug_reg_1[15:8]  <= wbs_dat_i[15:8];
                    if (wbs_sel_i[2]) debug_reg_1[23:16] <= wbs_dat_i[23:16];
                    if (wbs_sel_i[3]) debug_reg_1[31:24] <= wbs_dat_i[31:24];
                end else if (wbs_adr_i[3:0] == 4'hC) begin
                    // Write to debug_reg_2 (byte-wise)
                    if (wbs_sel_i[0]) debug_reg_2[7:0]   <= wbs_dat_i[7:0];
                    if (wbs_sel_i[1]) debug_reg_2[15:8]  <= wbs_dat_i[15:8];
                    if (wbs_sel_i[2]) debug_reg_2[23:16] <= wbs_dat_i[23:16];
                    if (wbs_sel_i[3]) debug_reg_2[31:24] <= wbs_dat_i[31:24];
                end

                // Signal completion of write
                wbs_ack_o <= 1'b1;
            end

            //------------------------------------------------------------------
            // READ transaction
            //------------------------------------------------------------------
            else if (wb_trans && !wbs_we_i) begin
                if (wbs_adr_i[3:0] == 4'h8)
                    wbs_dat_o <= debug_reg_1;
                else if (wbs_adr_i[3:0] == 4'hC)
                    wbs_dat_o <= debug_reg_2;
                else
                    wbs_dat_o <= 32'h0;  // invalid offset returns 0

                // Signal completion of read
                wbs_ack_o <= 1'b1;
            end

            // NOTE:
            // wbs_dat_o is intentionally NOT cleared when idle.
            // It holds the last read value, which is correct Wishbone behavior.
        end
    end

    
    end
    */
endmodule

`default_nettype wire

