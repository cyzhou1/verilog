module asyn_gearbox_132_128_top (
//to link layer
  input                      i_wclk,
  input                      i_rst_n,
  input                      i_wen,
  input     [131:0]          i_wdata,
//to phy layer
  input                      i_rclk,
  input                      i_ren,
  output                     o_rdata_ready,
  output    [127:0]          o_rdata
);

//==========================================================================
//FIFO READ SIDE CTRL
//==========================================================================
wire   [4:0] ctrl_cnt;
wire   [4:0] ctrl_cnt_mux_1;
wire   [4:0] ctrl_cnt_mux_2;
wire   [4:0] ctrl_cnt_mux_3;
wire         ctrl_cnt_32;
wire         ctrl_cnt_en;
//wire         ctrl_clr;
wire         stop_read;

assign ctrl_cnt_en    = i_ren;
assign ctrl_cnt_mux_1 = (&ctrl_cnt) ? 5'b0 : ctrl_cnt + 5'd1;
assign ctrl_cnt_mux_2 = ctrl_cnt_en ? ctrl_cnt_mux_1 : ctrl_cnt;
assign ctrl_cnt_mux_3 = ctrl_cnt_32 ? 5'b0 : ctrl_cnt_mux_2;
//assign ctrl_en = i_ren;
assign ctrl_clr = &ctrl_cnt;
//assign ctrl_cnt_nxt = ctrl_clr ? 5'd0 : (ctrl_cnt + 'd1);

dffr #(1) stop_read_1 (i_rclk, i_rst_n, ctrl_clr, stop_read);
dffr #(5) ctrl_cnt_5 (i_rclk, i_rst_n, ctrl_cnt_mux_3, ctrl_cnt);

wire        ctrl_cnt_32_mux_1;
wire        ctrl_cnt_32_mux_2;
wire        ctrl_cnt_32_mux_3;
assign ctrl_cnt_32_mux_1 = (&ctrl_cnt) ? 1'b1 : ctrl_cnt_32;
assign ctrl_cnt_32_mux_2 = ctrl_cnt_en ? ctrl_cnt_32_mux_1 : ctrl_cnt_32;
assign ctrl_cnt_32_mux_3 = ctrl_cnt_32 ? 1'b0 : ctrl_cnt_32_mux_2;

dffr #(1) ctrl_cnt_32_1 (i_rclk, i_rst_n, ctrl_cnt_32_mux_3, ctrl_cnt_32);

//===========================================================================
//FIFO signals
//===========================================================================
//status
wire            full;
wire            empty;
//write side
wire             wr_clk      = i_wclk;
wire             wr_rst_n    = i_rst_n;
wire             wr_en       = i_wen;
wire  [131:0]    wr_data     = i_wdata;

//read side
wire             rd_clk      = i_rclk;
wire             rd_rst_n    = i_rst_n;
wire             rd_en       = i_ren && (!stop_read);

//output data 
wire  [131:0]    rd_data;

//fifo instance
ASYN_FIFO #(
  .AW (8),
  .DW (132)
) fifo_132 (
  .wr_clk       (wr_clk      ),
  .wr_rst_n     (wr_rst_n    ),
  .wr_en        (wr_en       ),
  .wr_data      (wr_data     ),
  .rd_clk       (rd_clk      ),
  .rd_rst_n     (rd_rst_n    ),
  .rd_en        (rd_en       ),
  .rd_data      (rd_data     ),
  .full         (full        ),
  .empty        (empty       )
);
/*
fifo fifo_132 (
  .aclr       (1'b0         ),
  .rd_dat     (rd_data      ),
  .rd_clk     (rd_clk       ),
  .rd_req     (rd_en        ),
  .rd_empty   (empty        ),
  .rd_used    (             ),
  .wr_dat     (wr_data      ),
  .wr_clk     (wr_clk       ),
  .wr_req     (wr_ren       ),
  .wr_full    (full         ),
  .wr_used    (             )
);
*/

//================================================================================
//gearbox signals
//================================================================================
wire     [131:0] din;
wire             din_valid;
//wire             din_valid_r;
wire             din_ready;
wire             dout_ready;
wire     [127:0] dout;
wire             dout_valid;

assign din = rd_data;
assign dout_ready = din_valid;
assign din_valid = i_ren;
//dffr #(1) din_vld_1 (i_rclk, i_rst_n, i_ren, din_valid);
//dffr #(1) din_vld_2 (i_rclk, i_rst_n, i_ren, din_valid);

//gearbox instance
gearbox_132_128 x_gearbox(
  .clk          (i_rclk        ),
  .rst_n        (i_rst_n       ),
  .din          (din           ),
  .din_valid    (din_valid     ),
  .din_ready    (din_ready     ),
  .dout_ready   (dout_ready    ),
  .dout_valid   (dout_valid    ),
  .dout         (dout          )
);

//output data
assign o_rdata_ready = dout_valid;
assign o_rdata       = dout;

endmodule

















