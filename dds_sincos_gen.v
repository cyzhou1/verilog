module dds_sincos_gen #(
  parameter ROM_AW    = 8,
  parameter ROM_DW    = 8,
  parameter ROM_DEP   = (1 ** ROM_AW)
) (
  input                  clk,
  input                  rst_n,
  input                  ce,
  input  [ROM_AW-1:0]    kin, 
  output [ROM_DW-1:0]    sin_data,
  output [ROM_DW-1:0]    cos_data
);

//=======================================================================
//SIN BASE ADDRESS & COS BASE ADDRESS
//=======================================================================
parameter COS_BASE_ADDR = (ROM_DEP >> 2);

wire  [ROM_AW-1:0]     kin_r;
wire  [ROM_AW-1:0]     step;
wire  [ROM_AW-1:0]     phrs_cnt;
wire  [ROM_AW-1:0]     phrs_cnt_nxt;
wire  [ROM_AW-1:0]     sin_addr;
wire  [ROM_AW-1:0]     cos_addr;
wire  [ROM_DW-1:0]     sin_data_o;
wire  [ROM_DW-1:0]     cos_data_o;     

//asyn input should be registered
dfflr #(ROM_AW) freq_sync (clk, rst_n, ce, kin, kin_r);

//=========================================================================
//PHREASE COUNTER
//=========================================================================
assign step         = kin_r;
assign phrs_cnt_nxt = phrs_cnt + step;

dfflr #(ROM_AW) phrs_gen (clk, rst_n, ce, phrs_cnt_nxt, phrs_cnt);

//=========================================================================
//ROM ADDRESS
//=========================================================================
assign sin_addr = phrs_cnt;
assign cos_addr = phrs_cnt + COS_BASE_ADDR;
//behavior model for ROM is used 
rom_sim #(
  .AW  (ROM_AW ),
  .DW  (ROM_DW ),
  .DEP (ROM_DEP)
) sin_rom (
  .clk    (clk       ),
  .ce     (ce        ),
  .addr   (sin_addr  ),
  .data   (sin_data_o)
);

rom_sim #(
  .AW   (ROM_AW ),
  .DW   (ROM_DW ),
  .DEP  (ROM_DEP)
) cos_rom (
  .clk    (clk       ),
  .ce     (ce        ),
  .addr   (cos_addr  ),
  .data   (cos_data_o)
);

assign sin_data = sin_data_o;
assign cos_data = cos_data_o;

endmodule


