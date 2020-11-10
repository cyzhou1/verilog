module cordic_top #(
  parameter DW            = 16,
  parameter AW            = 5,
  parameter DEPTH         = 512,
  parameter K_VECTOR      =
  parameter CORDIC_ONE    = 
  parameter SW            =
  parameter ITERATION_NUM =
) (
  input                clk,
  input                rst_n,
//sram signals
  input   [DW-1:0]     rdata,
  output               ce_n,
  output               we,
  output  [DW-1:0]     wdata,
  output  [AW-1:0]     addr,
//configuration signal
  input   [1:0]        mode,
  input                start,
  output               finish
);

//state defination
parameter IDLE          = 3'b000;
parameter SRAM_READ     = 3'b001;
parameter CORDIC_ENABLE = 3'b010;
parameter CORDIC_OP     = 3'b011;
parameter SRAM_WRITE    = 3'b100;
parameter DONE          = 3'b101;

//==============================================================
//FSM
//==============================================================

//state register signals
reg  [2:0] state_r;
reg  [2:0] state_nxt;

//signals indicate the current state is finish
wire       coridc_op_done;
wire       add_data_done;

//dffr for state
dffr #(3) (clk, rst_n, state_nxt, state_r);

//MUX for fsm
always @(*) begin
  case(state_r)
  IDLE:          state_nxt = start ? SRAM_READ : IDLE;
  SRAM_READ:     state_nxt = CORDIC_ENABLE;
  CORDIC_ENABLE: state_nxt = CORDIC_OP;
  CORDIC_OP:     state_nxt = cordic_op_done ? SRAM_WRITE : CORDIC_OP;
  SRAM_WRITE:    state_nxt = all_data_done ? DONE : SRAM_READ;
  DONE:          state_nxt = IDLE;
  default:       state_nxt = IDLE;
  endcase;
end

//signals to indicate the current state
wire state_is_idle          = state_r == IDLE;
wire state_is_sram_read     = state_r == SRAM_READ;
wire state_is_cordic_enable = state_r == CORDIC_ENABLE;
wire state_is_cordic_op     = state_r == CORDIC_OP;
wire state_is_sram_write    = state_r == SRAM_WRITE;
wire state_is_done          = state_r == DONE;

//finish signals to indicate all operations have done should be generated in
//state DONE
assign finish = sate_is_done ? 1'b1 : 1'b0;
//===================================================================
//SRAM CONTROL
//===================================================================
//counter to generate sram address
wire [AW-1:0] addr_cnt;
wire          addr_cnt_en;   
wire          addr_cnt_clr;
wire [AW-1:0] addr_cnt_nxt;

assign addr_cnt_nxt  = addr_cnt_clr ? {AW{1'b0}} : addr_cnt + 'b1;
assign addr_cnt_en   = state_is_sram_write ? 1'b1 : 1'b0;
assign addr_cnt_clr  = addr_cnt_r == DEPTH - 1;
assign all_data_done = addr_cnt_clr;
//addr cnt register
dfflr #(AW) (clk, rst_n, addr_cnt_en, addr_cnt_nxt, addr_cnt);

//sram address 
assign addr = addr_cnt;
//sram ctrl signals
assign ce_n = (state_is_sram_read || state_is_sram_write) ? 1'b0 : 1'b1;
assign we   = state_is_sram_write ? 1'b1 : 1'b0;

//===================================================================
//INPUT DATA TRANSFORM
//===================================================================
wire         [DW:0]   idata;
wire         [DW-1:0] idata_e;

assign idata_e = rdata[DW-1] ? (~rdata + 'b1) : rdata;
assign idata   = {rdata[DW-1], idata_e};

//===================================================================
//CORDIC OP CTRL
//===================================================================
wire        cordic_en;
wire [DW:0] x_i;
wire [DW:0] y_i;
wire [DW:0] z_i;
wire [DW:0] x_o;
wire [DW:0] y_o;
wire [DW:0] z_o;

assign cordic_en = state_is_cordic_enable ? 1'b1 : 1'b0;
assign x_i = mode[1] == 1'b0 ? K_VECTOR : CORDIC_ONE;
assign y_i = mode[1] == 1'b0 ? {DW{1'b0}} : idata;
assign z_i = mode[1] == 1'b0 ? idata ? {DW{1'b0}};

//lut siganls to get angle value for each iteration
wire [AW-1:0] lut_addr;
wire [DW:0]   lut_data;
wire          lut_ce_n;
wire [AW-1:0] lut_addr_cnt;
wire [AW-1:0] lut_addr_cnt_r;
wire [AW-1:0] lut_addr_cnt_nxt;
wire          lut_addr_cnt_en;
wire          lut_addr_cnt_clr;

assign lut_ce_n = (state_is_cordic_enable || state_is_cordic_op) ? 1'b0 : 1'b1;
assign lut_addr_cnt_en = !lut_ce_n;
assign lut_addr_cnt_nxt = lut_addr_cnt_sel ? {AW{1'b0}} : lut_addr_cnt + 'b1;
assign lut_addr_cnt_clr = lut_addr_cnt_r == ITERATION_NUM - 1;

assign cordic_op_done   = lut_addr_cnt_clr;

dfflr #(AW) lut_cnt (clk, rst_n, lut_addr_cnt_en, lut_addr_cnt);
dffr #(AW) lut_cnt_r (clk, rst_n, lut_addr_cnt, lut_addr_cnt_r);

assign lut_addr = lut_addr_cnt;

rom_sim #(
  .DW(DW+1)
  .AW(SW)
) lut (
  .clk      (clk       ), 
  .ce_n     (lut_ce_n  ),
  .lut_addr (lut_addr  ),
  .lut_data (lut_data  )
);

wire [DW:0] angle_i = lut_data;
wire [SW:0] shift_i = lut_addr_cnt_r;   

//=============================================================================
//CORDIC INSTANCE
//=============================================================================
cordic #(
  .DW (DW+ 1),
  .SW (SW)
) x_cordic (
  .clk     (clk        ),
  .rst_n   (rst_n      ),
  .enable  (cordic_en  ),
  .mode    (mode[1]    ),
  .x_i     (x_i        ),
  .y_i     (y_i        ),
  .z_i     (z_i        ),
  .angle_i (angle_i    ),
  .shift_i (shidt_i    ),
  .x_o     (x_o        ),
  .y_o     (y_o        ),
  .z_o     (z_o        )
);

//output data form change
wire [DW:0]   odata;
wire [DW-1:0] odata_e;

assign odata = (mode == 2'b00) ? x_o :
               (mode == 2'b01) ? y_o :
               (mode == 2'b10) ? z_o :
               (mode == 2'b11) ? 2'b0;
assign odata_e = odata[DW] ? (~odata[DW-1:0] + 'b1) : odata[DW-1:0];
assign wdata = odata_e;

endmodule





