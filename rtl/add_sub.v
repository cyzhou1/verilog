module add_sub #(
  DW = 16
) (
  input       [DW-1:0] ain,
  input       [DW-1:0] bin,
  input                sel,
  output      [DW-1:0] cout
);

wire [DW-2:0] ain_e;
wire [DW-2:0] bin_e;
wire [DW-2:0] cout_e;
wire          cout_msb;
wire [DW-2:0] cout_rest;

assign ain_e = ain[DW-1] ? (~ain([DW-2:0] + 'b1) : ain[DW-2:0];
assign bin_e = bin[DW-1] ^ sel ? (~bin[DW-2:0] + 'b1) : bin[DW-2:0];

assign cout_e = ain_e + bin_e;

assign cout_msb = cout_e[DW-2];
assign cout_rest = cout_e[DW-2] ? (~cout_e + 'b1) : cout_e;

assign cout = {cout_msb, cout_rest};

endmodule
