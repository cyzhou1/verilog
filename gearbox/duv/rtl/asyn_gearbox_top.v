module asyn_gearbox (
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
wire         ctrl_cnt_nxt;
wire         ctrl_en;
wire         ctrl_clr;
wire         stop_read;

assign ctrl_en = i_red;
assign ctrl_clr = ctrl_cnt == 5'd31;
assign ctrl_cnt_nxt = ctrl_clr ? 5'd0 : ctrl_cnt + 'd1;
assign stop_read = ctrl_clr;

dfflr #(5) (clk, i_rst_n, ctrl_en, ctrl_cnt_nxt, ctrl_cnt);

//===========================================================================
//FIFO signals
//===========================================================================
//status
wire            full;
wire            empty;
//write side
wire             wr_clk      = i_wclk;
wire             wr_rst_n    = i_rst_n;
wire             wr_en       = i_wen && (!full);
wire  [131:0]    wr_data     = i_wdata;

//read side
wire             rd_clk      = i_rclk;
wire             rd_rst_n    = i_rst_n;
wire             rd_en       = i_ren && (!stop_read) && (!empty);
//output data 
wire  [131:0]    rd_data;

//fifo instance
ASYN_FIFO #(
  .AW (5),
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


//================================================================================
//gearbox signals
//================================================================================
wire     [131:0] din;
wire             din_valid;
wire             din_ready;
wire             dout_ready
wire     [127:0] dout;
wire             dout_valid;

assign din = rd_data;
assign dout_ready = rd_en;

dffr #(1) din_vld_1 (i_rclk, i_rst_n, rd_en, din_valid);

//gearbox instance
gearbox_132_128 (
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

















