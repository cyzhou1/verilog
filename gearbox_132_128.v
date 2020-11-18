module gearbox_132_128 (
//goloble signals
  input                   clk,
  input                   rst_n,
//to front 
  input                   din_valid,
  input      [131:0]      din,
  output                  din_ready,
//to back
  input                   dout_ready,
  output                  dout_valid,
  output     [127:0]      dout
);

//================================================================================================
//CONTROL PATH
//================================================================================================
wire  [4:0]    holding;
wire           holding_32;

//input data should be invalid/stopped for a cycle when the value of holding counter is equal to 31
assign din_ready = din_valid && (!holding_32);

wire [4:0]   holding_mux_1;
wire [4:0]   holding_mux_2;
wire [4:0]   holding_mux_3;

assign holding_mux_1 = (&holding) ? 5'd0 : (holding + 32'd1); 
assign holding_mux_2 = (din_ready && din_valid) ? holding_mux_1 : holding;
assign holding_mux_3 = holding_32 ? 5'd0 : holding_mux_2;

dffr #(5) holding_5 (clk, rst_n, holding_mux_3, holding);

wire holding_32_mux_1;
wire holding_32_mux_2;
wire holding_32_mux_3;

assign holding_32_mux_1 = (&holding) ? 1'b1 : holding_32;
assign holding_32_mux_2 = (din_ready && din_valid) ? holding_32_mux_1 : holding_32;
assign holding_32_mux_3 = holding_32 ? 1'b0 ? holding_mux_2;

dffr #(1) holding32_1 (clk, rst_n, holding_32_mux_3, holding_32);

//======================================================================================================
//DATA PATH
//======================================================================================================
wire [255:0] aligned_din;
wire [255:0] storage;
wire [255:0] storage_mux_1;
wire [255:0] storage_mux_2;
wire [6:0]   shift_width;

assign shift_width   = {2'd0, holding} << 2; 
assign aligned_din   = {124'd0, din} << shift_width;
assign storage_mux_1 = (din_ready && din_valid) ? (aligned_din | (storage >> 128)) : storage;
assign storage_mux_2 = holding_32 ? (storage >> 128) : storage_mux_1;

dffr #(255) storage_163 (clk, rst_n, storage_mux_2, storage);

wire dout_vld;
wire dout_vld_mux_1;
wire dout_vld_mux_2;

assign dout_vld_mux_1 = (din_ready && din_valid) ? 1'b1 : dout_vld;
assign dout_vld_mux_2 = holding_32 ? 1'b1 : dout_vld_mux_1;

dffr #(1) (clk, rst_n, dout_vld_mux_2, dout_vld);

//output signals
assign dout        = storage[127:0];
assign dout_valid  = dout_vld;

endmodule




