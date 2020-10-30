//D flip-flop with load enable and reset
//reset value is 0
module dfflr #(
  parameter DW = 8
) (
  input           clk,
  input           rst_n,
  input           load_en,
  input  [DW-1:0] din,
  output [DW-1:0] qout
);

reg [DW-1:0] qout_r;
always @(posedge clk or negedge rst_n)
begin
  if (!rst_n)
    qout_r <= {DW{1'b0}};
  else 
    if (load_en)
      qout_r <= din;
end

assign qout = qout_r;

endmodule
