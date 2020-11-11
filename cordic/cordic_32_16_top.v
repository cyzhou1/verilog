module cordic_32_16_top (
  input                     clk,
  input                     rst_n,
  input                     start,
  input            [1:0]    mode,
  input   signed   [31:0]   din,
  output  signed   [31:0]   dout,
  output                    valid
);

parameter IDLE   = 2'b00;  //state idle
parameter INIT   = 2'b01;  //state data inition
parameter DIVLD  = 2'b10;  //state data invalid
parameter DVLD   = 2'b11;  //state data valid

parameter K_VECTOR = 636751;
parameter INT_ONE  = 1 << 28;
//==================================================================
//FSM
//==================================================================
wire        [1:0]  state_r;
reg         [1:0]  state_nxt;
wire               pip_done;
//state register
dffr #(2) (clk, rst_n, state_nxt, state_r);

//fsm
always @(*) begin
  case(state_r)
  IDLE:    state_nxt = start ? INIT : IDLE;
  INIT:    state_nxt = DIVLD;
  DIVLD:   state_nxt = pip_done ? DVLD : DIVLD;
  DVLD:    state_nxt = DVLD;
  default: state_nxt = IDLE;
  endcase
end

//wire state_is_idle  = state_r == IDLE;
wire state_is_init  = state_r == INIT;
wire state_is_divld = state_r == DIVLD;
wire state_is_dvld  = state_r == DVLD;

//===================================================================
//DATA INITION
//===================================================================
wire signed [31:0] x_i;
wire signed [31:0] y_i;
wire signed [31:0] z_i;
wire signed [31:0] x_nxt;
wire signed [31:0] y_nxt;
wire signed [31:0] z_nxt;

assign x_nxt = (mode[1] == 1'b0) ? K_VECTOR : INT_ONE;
assign y_nxt = (mode[1] == 1'b0) ? 32'b0 : din;
assign z_nxt = (mode[1] == 1'b0) ? din : 32'b0;

wire               i_en = state_is_init && state_is_divld && state_is_dvld;
//wire               o_en = state_is_dvld;

dfflr #(32) x_init_dff (clk, rst_n, i_en, x_nxt, x_i);
dfflr #(32) y_init_dff (clk, rst_n, i_en, y_nxt, y_i);
dfflr #(32) z_init_dff (clk, rst_n, i_en, z_nxt, z_i);

//=====================================================================
//Pipeline counter to indicate the pip is over
//=====================================================================
wire   [3:0] pip_cnt;
wire   [3:0] pip_cnt_nxt;
wire         pip_en;

assign pip_en = state_is_divld;
assign pip_done = pip_cnt == 4'd15;
assign pip_cnt_nxt = (pip_cnt == 4'd15) ? 4'd0 : pip_cnt + 4'd1;

dfflr #(4) pip_dff (clk, rst_n, pip_en, pip_cnt_nxt, pip_cnt);

//======================================================================
//output select
//======================================================================
wire               o_en = state_is_dvld;
wire               valid_r;
wire signed [31:0] dout_nxt;
wire signed [31:0] dout_r;
wire signed [31:0] x_o;
wire signed [31:0] y_o;
wire signed [31:0] z_o;

assign dout_nxt = (mode == 2'b00) ? x_o :        //sin()
                  (mode == 2'b01) ? y_o :        //cos()
                  (mode == 2'b10) ? z_o : 32'b0; //atan()

dfflr #(32) dout_dff (clk, rst_n, o_en, dout_nxt, dout_r);
dfflr #(1) valid_dff (clk, rst_n, o_en, o_en, valid_r);

assign dout = dout_r;
assign valid = valid_r;
 
//=======================================================================
//CORDIC PIPELINE MODULE INSTANCE
//=======================================================================

cordic_32_16 (
  .clk       (clk       ),
  .rst_n     (rst_n     ),
  .mode      (mode[1]   ),
  .x_i       (x_i       ),
  .y_i       (y_i       ),
  .z_i       (z_i       ),
  .x_o       (x_o       ),
  .y_o       (y_o       ),
  .z_o       (z_o       )
);

endmodule
