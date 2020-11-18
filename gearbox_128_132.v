module gearbox_128_132 (
//phy layer interface
  input                      clk,
  input                      rst_n,
  input    [127:0]           din,
  input                      din_valid,
//link layer interface
  output   [131:0]           dout,
  output                     dout_valid
);

//=======================================================================================
//CTRL PATH
//=======================================================================================
wire  [5:0] holding;
wire  [5:0] holding_nxt;

assign holding_nxt = (holding == 6'd0) ? 6'd32 : (holding - 6'd1);

dfflr #(6) holding_cnt_6(clk, rst_n, din_valid, holding_nxt, holding);

//=======================================================================================
//DATA PATH
//=======================================================================================
wire   [6:0]    shift_width;
wire   [255:0]  storage;
wire   [255:0]  storage_nxt;
wire   [255:0]  aligned_din;
wire   [255:0]  storage_mux_1;

assign shift_width   = {2'b0, holding[4:0]} << 2;
assign aligned_din   = (holing == 6'd32) ? {din, 128'd0} : ({128'd0, din} << shift_width);
assign storage_mux_1 = holding[5] ? storage : (storage >> 128); 
assign storage_nxt   = storage_mux_1 | aligned_din;

dfflr #(256) stroage_256 (clk, rst_n, din_valid, storage_nxt, storage);

//data valid signal
wire dout_valid_nxt = (holding == 'd0) ? 1'b0 : 1'b1;

dfflr #(1) dout_valid_1 (clk, rst_n, din_valid, dout_valid_nxt, dout_valid);

//data reverse
wire [131:0] data_reverse = storage[131:0];
wire [131:0] data_out;

genvar i;
generate 
  for(i=0; i<132; i=i+1) begin : loop
    assign data_out[i] = data_reverse[131-i];
  end
endgenerate

assign dout = data_out;

endmodule

