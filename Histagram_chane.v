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
	
	 
////////////////////////////// Fram FIFO Logic //////////////////////////////
reg [LENGTH_SIZE-3:0] FramMemAdd;
always @(posedge clk or negedge rstn)
	if (!rstn) FramMemAdd <= 0;
	 else if (Valid) FramMemAdd <= FramMemAdd + 1;
reg FIFOFull;
wire FirstFIFOFull = (!FIFOFull && (FramMemAdd == LENGTH/4-1)) ? 1'b1 : 1'b0;
always @(posedge clk or negedge rstn)
	if (!rstn) FIFOFull <= 1'b0;
	 else if (!FIFOFull)  
		if (FirstFIFOFull && Valid) FIFOFull <= 1'b1;
	 else if (FremMemRD) FIFOFull <= 1'b0;
	 
////////////////// Frame FIFO //////////////////
wire FramMem_WRen   = Valid;
wire [LENGTH_SIZE-3:0] FramMem_WRadd  = FramMemAdd;
wire [DATA_SIZE-1:0] FramMem_WRdata = Data;
wire FramMem_RDen   = ((Valid && FIFOFull)||FremMemRD) ? 1'b1 : 1'b0;
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
wire HisRDAdd = Valid;	
reg  HisWRAdd;	
reg[1:0]  HisRDSub;	
reg  HisWRSub;
always @(posedge clk or negedge rstn)
	if (!rstn) HisWRAdd <= 1'b0;	
	 else HisWRAdd <= HisRDAdd;	

always @(posedge clk or negedge rstn)
	if (!rstn) begin
		 HisRDSub <= 2'b00;
         HisWRSub <= 1'b0;
			end
	 else begin
			HisRDSub <= {HisRDSub[0],(Valid && FIFOFull)};
			HisWRSub <= HisRDSub[1];
			 end
	 
////////////////// Histogram Logic //////////////////
wire [LENGTH_SIZE-1:0] HisIncre;
wire [LENGTH_SIZE-1:0] HisDecre;

wire HisMem_WRen   = HisWRAdd || HisWRSub;
wire [DATA_SIZE-1:0] HisMem_WRadd  = (HisWRAdd) ? Data :
                                     (HisWRSub) ? FramMem_out : 0;
wire [LENGTH_SIZE-1:0] HisMem_WRdata = (HisWRAdd) ? HisIncre : 
                                       (HisWRSub) ? HisDecre : 0;
wire HisMem_RDen   = (HisRDAdd || HisRDSub[1] || HisMemRD) ? 1'b1 : 1'b0;
wire [DATA_SIZE-1:0] HisMem_RDadd  = (HisRDAdd) ? Data : 
                                     (HisRDSub[1]) ? FramMem_out : 
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
