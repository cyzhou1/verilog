//cordic core support for cos, sin, arctan
module cordic #(
  parameter DW = 16
  parameter SW = 3
) (
  input                  clk,
  input                  rst_n,
  input                  mode,      //0: rotation 1: vector
  input         [DW-1:0] x_i,
  input         [DW-1:0] y_i,
  input         [DW-1:0] z_i,
  input         [DW-1:0] angle_i,
  input         [SW-1:0] shift_i,
  input                  enable,
  output        [DW-1:0] x_o,
  output        [DW-1:0] y_o,
  output        [DW-1:0] z_o
);

wire [DW-1:0] x_r;
wire [DW-1:0] y_r;
wire [DW-1:0] z_r;
wire [DW-1:0] x_nxt;
wire [DW-1:0] y_nxt;
wire [DW-1:0] z_nxt;

//for the first stage, primitive input x, y, z should be selected
assign x_nxt = enable ? x_i : x_o;
assign y_nxt = enable ? y_i : y_o;
assign z_nxt = enable ? z_i : z_o;

//register
dffr #(
  .DW (DW)
) x_dffr (
  .clk   (clk   ),
  .rst_n (rst_n ),
  .din   (x_nxt ),
  .qout  (x_r   )
);

dffr #(
  .DW (DW)
) y_dffr (
  .clk   (clk   ),
  .rst_n (rst_n ),
  .din   (y_nxt ),
  .qout  (y_r   )
);

dffr #(
  .DW (DW)
) z_dffr (
  .clk   (clk   ),
  .rst_n (rst_n ),
  .din   (z_nxt ),
  .qout  (z_r   )
);

//======================================================
//SHIFT ADD_SUB OP
//======================================================
wire [DW-1:0] x_shift = x_r >> shift_i;
wire [DW-1:0] y_shift = y_r >> shift_i;

wire add_sub_sel = (mode == 1'b0) ? z_r[DW];  //for rotation mode, add_sub_sel = sign(z)
                                  : ~z_r[DW]; //for vector mode, add_sub_sel = -sign(z)

add_sub #(
  .DW (DW)
) x_add_sub (
  .ain   (x_r         ),
  .bin   (y_shift     ),
  .sel   (add_sub_sel ),
  .cout  (x_o         )
);

add_sub #(
  .DW (DW)
) y_add_sub (
  .ain   (y_r         ),
  .bin   (x_shift     ),
  .sel   (add_sub_sel ),
  .cout  (y_o         )
);

add_sub #(
  .DW (DW)
) z_add_sub (
  .ain   (z_r         ),
  .bin   (angle_i     ),
  .sel   (add_sub_sel ),
  .cout  (z_o         )
);

endmodule
