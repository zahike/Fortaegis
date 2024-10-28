`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 08:54:45 AM
// Design Name: 
// Module Name: Histagram_chane
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Histagram_chane
#(
parameter DATA_SIZE   =  4,
parameter DATA_NUM    = 16,
parameter LENGTH      = 64,
parameter LENGTH_SIZE =  6
)
(
    input clk200,
    input clk   ,
    input rstn  ,
                
    input Valid ,
    input [DATA_SIZE-1:0] Data,
	
	input                  FremMemRD    ,
	input  [LENGTH_SIZE-3:0] FremMemRDAdd ,
	output [DATA_SIZE-1:0]   FremMemRDData,

	input                  HisMemRD    ,
	input  [DATA_SIZE-1:0]  HisMemRDAdd ,
	output [LENGTH_SIZE-1:0]   HisMemRDData
	
    );
	
//----------- INPUT CLOCK Synchronize ---// INST_TAG
wire [11:0] dout;
wire empty;
wire rd_en = !empty;
fifo_generator_0 fifo_generator_0 (
  .wr_clk(clk200),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din({{12-DATA_SIZE{1'b0}},Data}),        // input wire [11 : 0] din
  .wr_en(Valid),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(dout),      // output wire [11 : 0] dout
  .full(),      // output wire full
  .empty(empty)    // output wire empty
);
wire [DATA_SIZE-1:0] SynFIFOdata = dout[DATA_SIZE-1:0];
reg SynFIFOval;
always @(posedge clk or negedge rstn)
	if (!rstn) SynFIFOval <= 1'b0;
	 else SynFIFOval <= rd_en;
	 
/////////////////////// Fram FIFO ///////////////////////
reg [LENGTH_SIZE-3:0] F0WRMem;
reg [LENGTH_SIZE-3:0] F0RDMem;
wire [LENGTH_SIZE-3:0] FullAdd = F0RDMem-1;
wire FIFOFull_rd = (F0WRMem == FullAdd) ? 1'b1 : 1'b0;
reg  FIFOFull_wr;
always @(posedge clk or negedge rstn)
	if (!rstn)  FIFOFull_wr <= 1'b0;
     else if (SynFIFOval && FIFOFull_rd) FIFOFull_wr <= 1'b1;

always @(posedge clk or negedge rstn)
	if (!rstn) begin 
		F0WRMem <= 0;
		F0RDMem <= 0;
			end
	 else if (SynFIFOval) begin 
			F0WRMem <= F0WRMem + 1; 
			if (FIFOFull_wr) begin
			         F0RDMem <= F0RDMem + 1;
		                   end
			end
wire [DATA_SIZE-1:0] WR_F0MemData = dout[DATA_SIZE-1:0];
wire WR_F0Mem = SynFIFOval;
wire RD_F0Mem = SynFIFOval && FIFOFull_wr;
////////////////// Frame FIFO //////////////////
wire[LENGTH_SIZE-3:0] CalcReadAddr = F0RDMem + FremMemRDAdd;
reg [DATA_SIZE-1:0] F0Mem [0:(LENGTH/4)-1];
reg [DATA_SIZE-1:0] F0Mem_out;
always @(posedge clk)
	if (WR_F0Mem) F0Mem[F0WRMem] <= WR_F0MemData;
always @(posedge clk)
	if (RD_F0Mem) F0Mem_out <= F0Mem[F0RDMem];
	 else if (FremMemRD) F0Mem_out <= F0Mem[CalcReadAddr];

reg[DATA_SIZE-1:0]FremMemRDDataReg;
always @(posedge clk or negedge rstn)
	if (!rstn) FremMemRDDataReg <= 0;
	 else FremMemRDDataReg <= F0Mem_out;	
assign FremMemRDData = FremMemRDDataReg;
////////////////// End Of Frame FIFO //////////////////
reg [DATA_SIZE-1:0]Subdata;
reg[2:0] Subvalid;
always @(posedge clk or negedge rstn)
	if (!rstn) begin
	   Subdata  <= 0;
	   Subvalid <= 3'b000;
	       end
	 else begin
	   Subdata  <= F0Mem_out;
	   Subvalid <= {Subvalid[1:0],RD_F0Mem};
        end
//////////////////////////// Histagram Mem //////////////////////////// 	 
wire RD_AddH0Mem = WR_F0Mem;
reg  WR_AddH0Mem;
wire RD_SubH0Mem = Subvalid[2];
reg  WR_SubH0Mem  ;
always @(posedge clk or negedge rstn)
	if (!rstn) begin 
		WR_AddH0Mem  <= 1'b0;
		WR_SubH0Mem  <= 1'b0;
			end
	 else  begin 
		WR_AddH0Mem <= RD_AddH0Mem;
		WR_SubH0Mem <= RD_SubH0Mem;
		   end 
	 
////////////////// Histegram MEM //////////////////
reg [LENGTH_SIZE-1:0] H0Mem [0:DATA_NUM-1];
  generate
begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < DATA_NUM; ram_index = ram_index + 1)
          H0Mem[ram_index] = {DATA_NUM{1'b0}};
    end
  endgenerate
reg [LENGTH_SIZE-1:0] H0Mem_out;
always @(posedge clk)
	if (WR_AddH0Mem) H0Mem[WR_F0MemData] <= H0Mem_out + 1;
	 else if (WR_SubH0Mem) H0Mem[Subdata] <= H0Mem_out - 1;
always @(posedge clk)
	if (RD_AddH0Mem) H0Mem_out <= H0Mem[WR_F0MemData];
	 else if(RD_SubH0Mem) H0Mem_out <= H0Mem[Subdata];
	 else if(HisMemRD) H0Mem_out <= H0Mem[HisMemRDAdd];

reg[LENGTH_SIZE-1:0]HisMemRDDataReg;
always @(posedge clk or negedge rstn)
	if (!rstn) HisMemRDDataReg <= 0;
	 else HisMemRDDataReg <= H0Mem_out;		
assign HisMemRDData = HisMemRDDataReg;	  
////////////////// Histegram MEM //////////////////
	
endmodule
