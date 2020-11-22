//Dualport SRAM
//双口SRAM行为模型
module DPRAM #(
	parameter AW	= 8,
	parameter DW	= 8,
	parameter DEPTH = 1 << AW
	)(
	input					clk,
	input					wr_en,
	input					rd_en,
	input		[AW-1:0]	wr_addr,
	input		[AW-1:0]	rd_addr,
	input		[DW-1:0]	wr_data,
	output		[DW-1:0]	rd_data
	);

	reg		[DW-1:0]	ram[DEPTH-1:0];

	assign rd_data = rd_en ? ram[rd_addr] : 'b0;

	always @(posedge clk)
	begin
		if(wr_en)
			ram[wr_addr] <= wr_data;
	end

	endmodule
		
