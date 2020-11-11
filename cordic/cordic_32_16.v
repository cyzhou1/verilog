module cordic_32_16 (
  input                 clk,
  input                 rst_n,
  input                 mode,
  input  signed  [31:0] x_i,
  input  signed  [31:0] y_i,
  input  signed  [31:0] z_i,
  
  output signed  [31:0] x_o,
  output signed  [31:0] y_o,
  output signed  [31:0] z_o
);

wire  signed [31:0] x_1;
wire  signed [31:0] x_2;
wire  signed [31:0] x_3;
wire  signed [31:0] x_4;
wire  signed [31:0] x_5;
wire  signed [31:0] x_6;
wire  signed [31:0] x_7;
wire  signed [31:0] x_8;
wire  signed [31:0] x_9;
wire  signed [31:0] x_10;
wire  signed [31:0] x_11;
wire  signed [31:0] x_12;
wire  signed [31:0] x_13;
wire  signed [31:0] x_14;
wire  signed [31:0] x_15;
wire  signed [31:0] x_16;

wire  signed [31:0] y_1;
wire  signed [31:0] y_2;
wire  signed [31:0] y_3;
wire  signed [31:0] y_4;
wire  signed [31:0] y_5;
wire  signed [31:0] y_6;
wire  signed [31:0] y_7;
wire  signed [31:0] y_8;
wire  signed [31:0] y_9;
wire  signed [31:0] y_10;
wire  signed [31:0] y_11;
wire  signed [31:0] y_12;
wire  signed [31:0] y_13;
wire  signed [31:0] y_14;
wire  signed [31:0] y_15;
wire  signed [31:0] y_16;

wire  signed [31:0] z_1;
wire  signed [31:0] z_2;
wire  signed [31:0] z_3;
wire  signed [31:0] z_4;
wire  signed [31:0] z_5;
wire  signed [31:0] z_6;
wire  signed [31:0] z_7;
wire  signed [31:0] z_8;
wire  signed [31:0] z_9;
wire  signed [31:0] z_10;
wire  signed [31:0] z_11;
wire  signed [31:0] z_12;
wire  signed [31:0] z_13;
wire  signed [31:0] z_14;
wire  signed [31:0] z_15;
wire  signed [31:0] z_16;

//first stage
cordic_s #(32, 0, 823549) cordic_1s  (clk, rst_n, mode, x_i, y_i, z_i, x_1, y_1, z_1);

//second stage
cordic_s #(32, 1, 486170) cordic_2s  (clk, rst_n, mode, x_1, y_1, z_1, x_2, y_2, z_2);

//third state
cordic_s #(32, 2, 256879) cordic_3s  (clk, rst_n, mode, x_2, y_2, z_2, x_3, y_3, z_3);

//fourth stage
cordic_s #(32, 3. 130396) cordic_4s  (clk, rst_n, mode, x_3, y_3, z_3, x_4, y_4, z_4);

//fifth stage
cordic_s #(32, 4, 65451 ) cordic_5s  (clk, rst_n, mode, x_4, y_4, z_4, x_5, y_5, z_5);

//sixth stage
cordic_s #(32, 5, 32756 ) cordic_6s  (clk, rst_n, mode, x_5, y_5, z_5, x_6, y_6, z_6);

//seventh stage
cordic_s #(32, 6, 16383 ) cordic_7s  (clk, rst_n, mode, x_6, y_6, z_6, x_7, y_7, z_7);

//eighth stage
cordic_s #(32, 7, 8191  ) cordic_8s  (clk, rst_n, mode, x_7, y_7, z_7, x_8, y_8, z_8);

//ninth stage
cordic_s #(32, 8, 4096  ) cordic_9s  (clk, rst_n, mode, x_8, y_8, z_8, x_9, y_9, z_9);

//tenth stage
cordic_s #(32, 9, 2048  ) cordic_10s (clk, rst_n, mode, x_9, y_9, z_9, x_10, y_10, z_10);

//eleventh stage
cordic_s #(32, 10, 1024 ) cordic_11s (clk, rst_n, mode, x_10, y_10, z_10, x_11, y_11, z_11);

//twelveth stage
cordic_s #(32, 11, 512  ) cordic_12s (clk, rst_n, mode, x_11, y_11, z_11, x_12, y_12, z_12);

//theteenth stage
cordic_s #(32, 12, 256  ) cordic_13s (clk, rst_n, mode, x_12, y_12, z_12, x_13, y_13, z_13);

//forteenth stage
cordic_s #(31, 13, 128  ) cordic_14s (clk, rst_n, mode, x_13, y_13, z_13, x_14, y_14, z_14);

//fifteenth stage
cordic_s #(31, 14, 64   ) cordic_15s (clk, rst_n, mode, x_14, y_14, z_14, x_15, y_15, z_15);

//sixteenth stage
cordic_s #(31, 15, 33   ) cordic_16s (clk, rst_n, mode, x_15, y_15, z_15, x_16, y_16, z_16); 


assign x_o = x_16;
assign y_o = y_16;
assign z_o = z_16;

endmodule






























