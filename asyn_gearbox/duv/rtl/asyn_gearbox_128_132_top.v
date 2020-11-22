module asyn_gearbox_128_132_top (
//phy layer interface  
  input                        i_wclk,
  input                        i_rst_n,
  input                        i_wen,
  input      [127:0]           i_wdata,
//link layer interface
  input                        i_rclk,
  input                        i_ren,
  output     [131:0]           o_rdata,
  output                       o_rdata_ready
);

//==========================================================================
//gearbox Block
//==========================================================================
wire  [127:0]  din;
wire           din_valid;
wire  [131:0]  dout;
wire           dout_valid;

assign din        = i_wdata;
assign din_valid  = i_wen;

//gearbox instance
gearbox_128_132 x_gearbox_x (
  .clk          (i_wclk        ),
  .rst_n        (i_rst_n       ),
  .din          (din           ),
  .din_valid    (din_valid     ),
  .dout         (dout          ),
  .dout_valid   (dout_valid    )
);

//=============================================================================
//FIFO Block
//=============================================================================
//phy layer side
wire          wr_clk     = i_wclk;
wire          wr_rst_n   = i_rst_n;
wire          wr_en      = dout_valid;
wire  [131:0] wr_data    = dout;
wire          full;
//link layer side
wire          rd_clk     = i_rclk;
wire          rd_en      = i_ren;
wire          rd_rst_n   = i_rst_n;
wire          empty;
wire  [131:0] rd_data;

ASYN_FIFO #(
  .AW (8),
  .DW (132)
) asyn_fifo_132 (
  .wr_clk       (wr_clk       ),
  .wr_rst_n     (wr_rst_n     ),
  .wr_en        (wr_en        ),
  .wr_data      (wr_data      ),
  .full         (full         ),
  .rd_clk       (rd_clk       ),
  .rd_rst_n     (rd_rst_n     ),
  .rd_en        (rd_en        ),
  .rd_data      (rd_data      ),
  .empty        (empty        )
);

//output data
assign o_rdata = rd_data;
assign o_rdata_ready = i_ren;

//dffr #(1) o_ready_1 (rd_clk, rd_rst_n, i_ren, o_rdata_ready);

endmodule
