module ctrl (
  input                  clk,
  input                  rst_n,
  
//prbs signals
  output                 prbs_gen_en,
  output                 prbs_chk_en,

//jtx signals
  output                 sysref,
  output                 sync,
  output   [2:0]         work_mode,
  output   [1:0]         syncword_mode,
  output                 cfg_lemc_offset,
  output                 cfg_sysref_oneshot,
  output                 cfg_sysref_disable,
  output   [6:0]         cmd_crc12,

//start signals
  input                  tx_reset_done,
  input                  rx_reset_done,
  input                  lemc
);

//=========================================================================
//SIGNALS NOT CHANGED WHEN OPERATING
//=========================================================================
assign work_mode           = 3'b001;
assign syncword_mode       = 2'b01;
assign cmd_crc12           = 7'b0;
assign cfg_sync_shot       = 1'b1;
assign cfg_sysref_disable  = 1'b0;
//registers
wire         prbs_gen_en_r;
wire         prbs_gen_en_enable;
wire         prbs_chk_en_r;
wire         prbs_chk_en_enable;
wire  [3:0]  sysref_cnt;
wire  [3:0]  sysref_cnt_nxt;
wire         sysref_cnt_done; 
wire         sysref_cnt_en;

assign prbs_gen_en_enable = lemc && tx_reset_done;
assign prbs_chk_en_enable = lemc && rx_reset_done;
assign sysref_cnt_en      = tx_reset_done && rx_reset_done && !cfg_sysref_disable;

//===========================================================================
//PRBS GENRATOR ENABLE SIGNALS GENERATION
//===========================================================================
dfflr #(
  .DW (1)
) prbs_gen_reg (
  .clk     (clk               ),
  .rst_n   (rst_n             ),
  .load_en (prbs_gen_en_enable),  
  .din     (1'b1              ),
  .qout    (prbs_gen_en_r     )
);
assign prbs_gen_en = prbs_gen_en_r;
//============================================================================
//PRBS CHECKER ENABLE SIGNALS GENERATION
//============================================================================
dfflr #(
  .DW (1)
) prbs_chk_reg (
  .clk     (clk               ),
  .rst_n   (rst_n             ),
  .load_en (prbs_chk_en_enable),
  .din     (1'b1              ),
  .qout    (prbs_chk_en_r     )
);
assign prbs_chk_en = prbs_chk_en_r;

//============================================================================
//SYSREF COUNTER
//============================================================================
assign sysref_cnt_done = sysref_cnt == 4'd15;
assign sysref_cnt      = sysref_cnt_done ? 4'b0 : sysref_cnt + 4'b1;

dfflr #(
  .DW (4)
) x_sysref_cnt (
  .clk     (clk               ),
  .rst_n   (rst_n             ),
  .load_en (sysref_cnt_en     ),
  .din     (sysref_cnt_nxt    ),
  .qout    (sysref_cnt        )
);

assign sysref = sysref_cnt_done;

endmodule



