module cordic_s #(
  parameter DW  = 32,
  parameter SFT = 0,
  parameter AGL = 823549
) (
  input                      clk,
  input                      rst_n,
  input                      mode,
  input   signed    [DW-1:0] x_i,
  input   signed    [DW-1:0] y_i,
  input   signed    [DW-1:0] z_i,
  output  signed    [DW-1:0] x_o,
  output  signed    [DW-1:0] y_o,
  output  signed    [DW-1:0] z_o
);

wire signed [DW-1:0] x_s = x_i >>> SFT;
wire signed [DW-1:0] y_s = y_i >>> SFT;

wire add_sub_sel = (mode == 1'b0 && z_i[DW-1] == 1'b0) ? 1'b0 :    
                   (mode == 1'b0 && z_i[DW-1] == 1'b1) ? 1'b1 :
                   (mode == 1'b1 && y_i[DW-1] == 1'b0) ? 1'b1 : 1'b0;

wire signed [DW-1:0] x_nxt;
wire signed [DW-1:0] y_nxt;
wire signed [DW-1:0] z_nxt;
wire signed [DW-1:0] x_r;
wire signed [DW-1:0] y_r;
wire signed [DW-1:0] z_r;

assign x_nxt = (add_sub_sel == 1'b0) ? (x_i - y_s) : (x_i + y_s);
assign y_nxt = (add_sub_sel == 1'b0) ? (y_i + x_s) : (y_i - x_s);
assign z_nxt = (add_sub_sel == 1'b0) ? (z_i - AGL) : (z_i + AGL);

dffr #(DW) (clk, rst_n, x_nxt, x_r);
dffr #(DW) (clk, rst_n, y_nxt, y_r);
dffr #(DW) (clk, rst_n, z_nxt, z_r);

assign x_o = x_r;
assign y_o = y_r;
assign z_o = z_r;

endmodule
