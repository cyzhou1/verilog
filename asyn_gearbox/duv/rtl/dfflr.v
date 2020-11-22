//D flip-flop with load enable and reset
//reset value is 0
module dfflr #(
  parameter DW = 8
) (
  input           clk,
  input           rst_n,
  input           load_en,
  input  [DW-1:0] din,
  output [DW-1:0] dout
);

reg [DW-1:0] dout_r;
always @(posedge clk or negedge rst_n)
begin
  if (!rst_n)
    dout_r <= {DW{1'b0}};
  else 
    if (load_en)
      dout_r <= din;
end

assign dout = dout_r;

endmodule
