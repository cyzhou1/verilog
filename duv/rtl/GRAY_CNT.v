module GRAY_CNT#(
		parameter	WIDTH = 4
		)(
		input					clk,
		input					rst_n,
		input					en,
		output reg	[WIDTH-1:0]	gry_cnt
		);

wire		[WIDTH-1:0]		bin_din;
wire		[WIDTH-1:0]		gry_din;
reg			[WIDTH-1:0]		bin_qout;

assign bin_din = en ? (bin_qout + 'b1) : bin_qout;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		bin_qout <= 'b0;
	else 
		bin_qout <= bin_din;
end

assign gry_din = (bin_din >> 1) ^ bin_din;
always @(posedge clk or negedge rst_n)
begin
	gry_cnt <= gry_din;
end
		

endmodule


			
