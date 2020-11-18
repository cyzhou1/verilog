module ASYN_FIFO #(
		parameter	AW	= 8,
		parameter	DW	= 8
		) (
		input					wr_clk,
		input					wr_rst_n,
		input					wr_en,
		input		[DW-1:0]	wr_data,
		input					rd_clk,
		input					rd_rst_n,
		input					rd_en,
		output		[DW-1:0]	rd_data,
		//rseponce
		output					full,
		output					empty
		);

		wire		[AW:0]		wr_ptr;
		wire		[AW:0]		rd_ptr;
		wire					wr_valid;
		wire					rd_valid;

		assign wr_valid		= wr_en && !full;
		assign rd_valid		= rd_en && !empty;

		//wr_ptr gray form
		GRAY_CNT #(
				.WIDTH	(AW+1)
				) wr_ptr_cnt(
				.clk		(wr_clk		),
				.rst_n		(wr_rst_n	),
				.en			(wr_valid	),
				.gry_cnt	(wr_ptr		)
				);
		//rd_ptr gray form
		GRAY_CNT #(
				.WIDTH	(AW+1)
				) rd_ptr_cnt(
				.clk		(rd_clk		),
				.rst_n		(rd_rst_n	),
				.en			(rd_en		),
				.gry_cnt	(rd_ptr		)
				);
		//synchrosize
		reg			[AW:0]	wr_ptr_r;
		reg			[AW:0]	rd_ptr_r;
		reg			[AW:0]	syn_wr_ptr;
		reg			[AW:0]	syn_rd_ptr;
		//synchrinsize the write ptr in read clock
		always @(posedge rd_clk or negedge rd_rst_n)
		begin
			if(!rd_rst_n) begin
				wr_ptr_r	<= 'b0;
				syn_wr_ptr	<= 'b0;
			end
			else begin
				wr_ptr_r	<= wr_ptr;
				syn_wr_ptr	<= wr_ptr_r;
			end
		end
		//synchronsize the read ptr in write clock 
		always @(posedge wr_clk or negedge wr_rst_n)
		begin
			if(!wr_rst_n) begin
				rd_ptr_r	<= 'b0;
				syn_rd_ptr	<= 'b0;
			end
			else begin
				rd_ptr_r	<= rd_ptr;
				syn_rd_ptr	<= rd_ptr_r;
			end
		end

		//Gray to bianry logic
		wire	[AW:0]		wr_ptr_bin;
		wire	[AW:0]		rd_ptr_bin;
		wire	[AW:0]		syn_wr_ptr_bin;
		wire	[AW:0]		syn_rd_ptr_bin;

		genvar i;
		generate 
			for (i=0; i<AW+1; i=i+1) begin: gry_bin_loop
				assign wr_ptr_bin[i]		= ^(wr_ptr >> i);
				assign rd_ptr_bin[i]		= ^(rd_ptr >> i);
				assign syn_wr_ptr_bin[i]	= ^(syn_wr_ptr >> i);
				assign syn_rd_ptr_bin[i]	= ^(syn_rd_ptr >> i);
			end
		endgenerate

		//full and empty signal
		wire	[AW-1:0]	wr_addr_bin;
		wire    [AW-1:0]	rd_addr_bin;
		wire	[AW-1:0]	syn_rd_addr_bin;
		wire				msb_wr_ptr_bin;
		wire				msb_syn_rd_ptr_bin;
		
		assign	wr_addr_bin			= wr_ptr_bin[AW-1:0];
		assign  rd_addr_bin			= rd_ptr_bin[AW-1:0];
		assign	syn_rd_addr_bin		= syn_rd_ptr_bin[AW-1:0];
		assign	msb_wr_ptr_bin		= wr_ptr_bin[AW];
		assign	msb_syn_rd_ptr_bin	= syn_rd_ptr_bin[AW];

		assign full		= (msb_wr_ptr_bin != msb_syn_rd_ptr_bin) && (wr_addr_bin == syn_rd_addr_bin);
		assign empty	= rd_ptr_bin == syn_wr_ptr_bin;
		
		//insatence
		DPRAM #(
			.AW	(AW),
			.DW	(DW)
			)fifo_ram(
			.clk		(wr_clk		),
			.wr_en		(wr_valid	),
			.rd_en		(rd_valid	),
			.wr_addr	(wr_addr_bin),
			.rd_addr	(rd_addr_bin),
			.wr_data	(wr_data	),
			.rd_data	(rd_data	)
			);

				
endmodule
