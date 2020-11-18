module smk_case;

initial begin
  `TB_DIN         = 132'b0;
  `TB_DIN_VALID   = 1'b0;
  `TB_DOUT_READY  = 1'b0;
  #(`CLOCK_PERIOD * 2)
  `TB_DOUT_READY  = 1'b1;
  `TB_DIN         = {4'b1000, 128'b0};
  `TB_DIN_VALID   = 1'b1;
  #(`CLOCK_PERIOD * 32)
  `TB_DIN_VALID   = 1'b0;
  #(`CLOCK_PERIOD)
  `TB_DIN_VALID   = 1'b1;

end

endmodule
