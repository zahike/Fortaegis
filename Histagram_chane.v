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
	
	input                    FremMemRD    ,
	input  [LENGTH_SIZE-3:0] FremMemRDAdd ,
	output [DATA_SIZE-1:0]   FremMemRDData,

	input                    HisMemRD    ,
	input  [DATA_SIZE-1:0]   HisMemRDAdd ,
	output [LENGTH_SIZE-1:0] HisMemRDData
	
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
	 
////////////////////////////// Fram FIFO Logic //////////////////////////////
reg [LENGTH_SIZE-3:0] FramMemAdd;
always @(posedge clk or negedge rstn)
	if (!rstn) FramMemAdd <= 0;
	 else if (SynFIFOval) FramMemAdd <= FramMemAdd + 1;
reg FIFOFull;
reg FirstRep;
wire FirstFIFOFull = (!FIFOFull && (FramMemAdd == LENGTH/4-1)) ? 1'b1 : 1'b0;
always @(posedge clk or negedge rstn)
	if (!rstn) begin
			FIFOFull <= 1'b0;
			FirstRep <= 1'b0;
				end
	 else if (!FIFOFull) begin 
		if (FirstFIFOFull && SynFIFOval) FirstRep <= 1'b1;
	    if (FirstRep && rd_en) begin 
							FIFOFull <= 1'b1;
							FirstRep <= 1'b0;
								end
						end
	 else if (FremMemRD) FIFOFull <= 1'b0;
	 
////////////////// Frame FIFO //////////////////
wire FramMem_WRen   = SynFIFOval;
wire [LENGTH_SIZE-3:0] FramMem_WRadd  = FramMemAdd;
wire [DATA_SIZE-1:0] FramMem_WRdata = SynFIFOdata;
wire FramMem_RDen   = ((SynFIFOval && FIFOFull)||FremMemRD) ? 1'b1 : 1'b0;
wire [LENGTH_SIZE-3:0] FramMem_RDadd  = (FremMemRD) ? FremMemRDAdd + FramMemAdd : FramMemAdd;

   (* ram_style="block" *)
reg [DATA_SIZE-1:0] FramMem [0:(LENGTH/4)-1];
reg [DATA_SIZE-1:0] FramMem_out;
always @(posedge clk)
	if (FramMem_WRen) FramMem[FramMem_WRadd] <= FramMem_WRdata;
always @(posedge clk)
	if (FramMem_RDen) FramMem_out <= FramMem[FramMem_RDadd];
//////////////// End Frame FIFO ////////////////

reg[DATA_SIZE-1:0]FremMemRDDataReg;
always @(posedge clk or negedge rstn)
	if (!rstn) FremMemRDDataReg <= 0;
	 else FremMemRDDataReg <= FramMem_out;	
assign FremMemRDData = FremMemRDDataReg;

////////////////////////////// Histogram Logic //////////////////////////////
wire HisRDAdd = SynFIFOval;	
reg  HisWRAdd;	
reg  HisRDSub;	
reg  HisWRSub;
always @(posedge clk or negedge rstn)
	if (!rstn) begin
         HisWRAdd <= 1'b0;	
		 HisRDSub <= 1'b0;	
         HisWRSub <= 1'b0;
			end
	 else begin 
        HisWRAdd <= HisRDAdd;	
		 if (FIFOFull) begin
			HisRDSub <= HisWRAdd;
			HisWRSub <= HisRDSub;
			 end
		  end
	 
////////////////// Histogram Logic //////////////////
wire [LENGTH_SIZE-1:0] HisIncre;
wire [LENGTH_SIZE-1:0] HisDecre;

wire HisMem_WRen   = HisWRAdd || HisWRSub;
wire [DATA_SIZE-1:0] HisMem_WRadd  = (HisWRAdd) ? SynFIFOdata :
                                     (HisWRSub) ? FramMem_out : 0;
wire [LENGTH_SIZE-1:0] HisMem_WRdata = (HisWRAdd) ? HisIncre : 
                                       (HisWRSub) ? HisDecre : 0;
wire HisMem_RDen   = (HisRDAdd || HisRDSub || HisMemRD) ? 1'b1 : 1'b0;
wire [DATA_SIZE-1:0] HisMem_RDadd  = (HisRDAdd) ? SynFIFOdata : 
                                     (HisRDSub) ? FramMem_out : 
                                     (HisMemRD) ? HisMemRDAdd : 0;
   (* ram_style="block" *)
reg [LENGTH_SIZE-1:0] HisMem [0:DATA_NUM-1];
reg [LENGTH_SIZE-1:0] HisMem_out;
  generate
begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < DATA_NUM; ram_index = ram_index + 1)
          HisMem[ram_index] = {LENGTH_SIZE{1'b0}};
    end
  endgenerate
always @(posedge clk)
	if (HisMem_WRen) HisMem[HisMem_WRadd] <= HisMem_WRdata;
always @(posedge clk)
	if (HisMem_RDen) HisMem_out <= HisMem[HisMem_RDadd];

assign HisIncre = HisMem_out + 1;
assign HisDecre = HisMem_out - 1;
	
//////////////// End Histogram Logic ////////////////

reg[LENGTH_SIZE-1:0]HisMemRDDataReg;
always @(posedge clk or negedge rstn)
	if (!rstn) HisMemRDDataReg <= 0;
	 else HisMemRDDataReg <= HisMem_out;		
assign HisMemRDData = HisMemRDDataReg;	  
	
endmodule
