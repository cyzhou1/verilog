module tb;

reg                           clk;
reg                           rst_n;
reg         [131:0]           din;
reg                           dout_ready;
reg                           din_valid;
wire        [127:0]           dout;
wire                          din_ready;
wire                          dout_valid;

//============================================================
//INSTANCE THE DUV
//===========================================================
gearbox_132_128 x_gearbox (
  .clk           (clk         ),
  .rst_n         (rst_n       ),
  .din           (din         ),
  .din_valid     (din_valid   ),
  .din_ready     (din_ready   ),
  .dout          (dout        ),
  .dout_valid    (dout_valid  ),
  .dout_ready    (dout_ready  )
);








//============================================================
//CLOCK SETUP
//============================================================
initial begin
  clk   = 1'b0;
  forever #((`CLOCK_PERIOD)/2)
  clk = !clk;
end

//============================================================
//reset SETUP
//============================================================
initial begin
  rst_n  = 1'b1;
  #(`RESET_DUR)
  rst_n  = 1'b0;
  #(`RESET_DUR)
  rst_n  = 1'b1;
end

//===========================================================
//MAX SIMULATION TIME SETUP
//===========================================================
initial begin
  while ($time < `MAX_SIM_TIME)
    #100;
  $display("##################################################");
  $display("###### The Max simulation time is Met !!! ########");
  $display("##################################################");
  $finish;
end

//===========================================================
//WAVE GENERATION
//===========================================================
`ifdef DUMPON
initial begin
  $display(".......................................................");
  $display("........... Begin dumpping the fsdb file ..............");
  $display(".......................................................");
  $fsdbDumpfile(`FSDB_NAME);
  $fsdbDumpon;
  $fsdbDumpvars;
end
`endif

endmodule


  

