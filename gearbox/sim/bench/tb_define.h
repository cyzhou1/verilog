//================================================
//DUV RELATED
//================================================
//data address
`define ADDR_WIDTH 8

//data address depth
`define ADDR_DEPTH (2 ** `ADDR_WIDTH)

//data width
`define DATA_WIDTH 16

//=================================================
//SIMULATION RELATED
//=================================================
//clock period
`define CLOCK_PERIOD 10

//Reset duration
`define RESET_DUR  5

//Max simulation time
`define MAX_SIM_TIME 100000

//use C reference model instead a verilog task
`define RM_USE_C

//==================================================
//PATH DEFINATION
//==================================================




//==================================================
//TB SIGNAL DEFINATION 
//==================================================
`define     TB_DIN              tb.din
`define     TB_DIN_VALID        tb.din_valid
`define     TB_DOUT_READY       tb.dout_ready
