module rom_sim # (
  DW     = 16,
  AW     = 8,
  DEP    = 2 ** AW
) (
  input                          clk,
  input                          ce,
  input     [AW-1:0]             addr,
  output    [DW-1:0]             data
);

reg [DW-1:0] mem[DEP-1:0];

//behavior function of ram
reg [AW-1:0] addr_r;

initial begin
  $system("$PRJ_PATH/sim/rm/sin_gen.exe");
  $readmemh("sin.dat", mem);
end

always @(posedge clk) 
  addr_r <= addr;

assign data = mem[addr_r];

endmodule

