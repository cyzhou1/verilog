module ahb_sram_ctrl (
//AHB side
  input                         hclk,
  input                         hrst_n,
  input                         hsel,
  input                         hwrite,
  input              [2:0]      hsize,
  input              [1:0]      htrans,
  input              [31:0]     haddr,
  input              [31:0]     hwdata,
  output                        hresp,
  output                        hready,
  output             [31:0]     hrdata, 

//SRAM side
  input              [7:0]      sram0_q,
  input              [7:0]      sram1_q,
  input              [7:0]      sram2_q,
  input              [7:0]      sram3_q,
  input              [7:0]      sram4_q,
  input              [7:0]      sram5_q,
  input              [7:0]      sram6_q,
  input              [7:0]      sram7_q,
  output                        sram_we,
  output             [12:0]     sram_addrout,    //for an 8K SRAM, address width 13 is needed
  output             [31:0]     sram_wdata,
  output             [3:0]      sram_bank0_sel,  //sram0 to 3 is bank zero
  output             [3:0]      sram_bank1_sel   //sram4 to 7 is bank one
);

//AHB BUS Tranfer state defination
parameter IDLE     = 2'b00;
parameter BUSY     = 2'b01;
parameter SEQ      = 2'b10;
parameter NONSEQ   = 2'b11;

//AHB BUS Transfer Length defination
parameter BYTE     = 3'b000;
parameter HALFWORD = 3'b001;
parameter WORD     = 3'b010;

//===================================================================
//AHB BUS signals registered
//===================================================================
reg          hwrite_t;
reg          hwrite_r;
reg  [1:0]   htrans_t;
reg  [1:0]   htrans_r;
reg  [2:0]   hsize_t;
reg  [2:0]   hsize_r;
reg  [31:0]  haddr_t;
reg  [31:0]  haddr_r;
reg  [31:0]  hwdata_r;

always @(posedge hclk or negedge hrst_n) begin
  if (!hrst_n) begin
    hwrite_t <= 1'b0;
    hwrite_r <= 1'b0;
    htrans_t <= 2'b0;
    htrans_r <= 2'b0;
    hsize_t  <= 3'b0;
    hsize_r  <= 3'b0;
    haddr_t  <= 3'b0;
    haddr_r  <= 32'b0;
    hwdata_r <= 32'b0;
  end else if (hsel) begin
    hwrite_t <= hwrite;
    hwrite_r <= hwrite_t;
    htrans_t <= htrans;
    htrans_r <= htrans_t;
    hsize_t  <= hsize;
    hsize_r  <= hsize_t;
    haddr_t  <= haddr;
    haddr_r  <= haddr_t;
    hwdata_r <= hwdata;
  end
end

//=====================================================================
//Slave response
//=====================================================================
//set default
assign hresp  = 1'b0;
assign hready = 1'b1;

//=====================================================================
//SRAM WRITE siganls
//=====================================================================
//asure read and write operation did not occured together
wire        sram_read;
wire        sram_write;
wire        sram_en;

assign sram_write = (htrans_r == SEQ || htrans_r == NONSEQ) & hwrite_r;
assign sram_read  = (htrans == SEQ || htrans == NONSEQ) & !hwrite;
assign sram_en    = sram_write || sram_read;
assign sram_we    = sram_write;

//sram address
wire [15:0] sram_addr;
wire        bank_sel;     //choose which bank to transfer
reg  [3:0]  sram_sel;     //choose which sram(s) in a bank to transfer
wire [31:0] sram_rdata;
assign sram_addr    = sram_write ? haddr_r[15:0] : haddr[15:0];
assign bank_sel     = sram_addr[15];
assign sram_addrout = sram_addr[12:0];
assign sram_wdata   = hwdata_r;
assign sram_rdata   = bank_sel ? {sram7_q, sram6_q, sram5_q, sram4_q} :
                                 {sram3_q, sram2_q, sram1_q, sram0_q};
assign hrdata = sram_rdata;
//sram selection
always @(*) begin
  if (sram_write) begin
    case (hsize_r) 
      BYTE     : sram_sel = sram_addr[14] ? (sram_addr[13] ? 4'b1000 : 4'b0100) :
                                            (sram_addr[13] ? 4'b0010 : 4'b0001);
      HALFWORD : sram_sel = sram_addr[14] ? 4'b1100 : 4'b0011;
      WORD     : sram_sel = 4'b1111;
      default  : sram_sel = 4'b0000;
    endcase
  end else if (sram_read) begin
    case (hsize)
      BYTE     : sram_sel = sram_addr[14] ? (sram_addr[13] ? 4'b1000 : 4'b0100) :
                                            (sram_addr[13] ? 4'b0010 : 4'b0001);
      HALFWORD : sram_sel = sram_addr[14] ? 4'b1100 : 4'b0011;
      WORD     : sram_sel = 4'b1111;
      default  : sram_sel = 4'b0000;
    endcase
  end else begin
    sram_sel = 4'b0000;
  end
end

assign sram_bank0_sel = (!bank_sel && sram_en) ? sram_sel : 4'b0000;
assign sram_bank1_sel = (bank_sel && sram_en) ? sram_sel : 4'b0000;  


endmodule
