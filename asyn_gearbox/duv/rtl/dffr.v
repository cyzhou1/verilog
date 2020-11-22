//D flip-flop with reset but without load enable 
//reset value is zero
module dffr #(
  parameter DW = 16
) (
  input            clk,
  input            rst_n,
  input   [DW-1:0] din,
  output  [DW-1:0] qout
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    qout_r <= 'b0;
  else
    qout_r <= din;

assign qout = qout_r;

endmodule
