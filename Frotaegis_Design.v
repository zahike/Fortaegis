`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2024 07:20:09 PM
// Design Name: 
// Module Name: Frotaegis_Design
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


module Frotaegis_Design
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

	input Collect,
	
    input Valid ,
    input [DATA_SIZE-1:0] Data

    );
////////////////// Split Data to two Channels //////////////////   
reg [1:0] Split;
reg [3:0] WriteData;
reg [DATA_SIZE-1:0] RegData[0:3];

wire                   FremMemRD    ;
wire [LENGTH_SIZE-3:0] FremMemRDAdd ;
wire [DATA_SIZE-1:0]   FremMemRDData[0:3];
wire                   HisMemRD     ;
wire [DATA_SIZE-1:0]   HisMemRDAdd  ;
wire [LENGTH_SIZE-1:0] HisMemRDData[0:3] ;

always @(posedge clk200 or negedge rstn)
    if (!rstn) Split <= 2'b00;
	 else if (!Collect) Split <= 2'b00;
     else if (Valid) Split <= Split +1;	
genvar i;
generate 
	for (i=0;i<4;i=i+1) begin 
		always @(posedge clk200 or negedge rstn)
			if (!rstn) begin 
				WriteData[i] <= 1'b0;
				RegData[i]   <=    0;
					end 
			 else if (!Collect) begin 
				WriteData[i] <= 1'b0;
				RegData[i]   <=    0;
					end 
			 else if (Valid && (Split == i)) begin 
					WriteData[i] <= 1'b1;
					RegData[i]   <= Data;
						end
				   else WriteData[i] <= 1'b0;
Histagram_chane
#(
.DATA_SIZE   (DATA_SIZE  ),
.DATA_NUM    (DATA_NUM   ),
.LENGTH      (LENGTH     ),
.LENGTH_SIZE (LENGTH_SIZE)
)
Histagram_chane_inst
(
    .clk200(clk200),
    .clk   (clk   ),
    .rstn  (rstn  ),

    .Valid (WriteData[i]),
    .Data  (RegData[i]),

	.FremMemRD    (FremMemRD    ),
	.FremMemRDAdd (FremMemRDAdd ),
	.FremMemRDData(FremMemRDData[i]),

	.HisMemRD     (HisMemRD     ),
	.HisMemRDAdd  (HisMemRDAdd  ),
	.HisMemRDData (HisMemRDData [i])
	
    );
	end	
endgenerate 

reg [15:0] DelCollect;
always @(posedge clk or negedge rstn)
    if (!rstn)  DelCollect <= 16'h0000;
	 else DelCollect <= {DelCollect[14:0],Collect};

reg [LENGTH_SIZE-1:0] ReadCounter;
reg                   ReadCounterOn;
always @(posedge clk or negedge rstn)
    if (!rstn) begin
			ReadCounter   <= 0;
			ReadCounterOn <= 1'b0;
				end
	 else if (ReadCounterOn) begin 
			ReadCounter <= ReadCounter + 1;
			if (ReadCounter == LENGTH-1)ReadCounterOn <= 1'b0;
			 else ReadCounterOn <= 1'b1;
				end
	 else begin 
		ReadCounter   <= 0;
		if (DelCollect == 16'hc000) ReadCounterOn <= 1'b1;
		 else ReadCounterOn <= 1'b0;
			end

assign FremMemRD    = {4{ReadCounterOn}};
assign FremMemRDAdd = ReadCounter[LENGTH_SIZE-1:2];
assign HisMemRD    = (ReadCounter[LENGTH_SIZE-1:DATA_SIZE] == 0) ? {4{ReadCounterOn}}      : 0;
assign HisMemRDAdd = (ReadCounter[LENGTH_SIZE-1:DATA_SIZE] == 0) ? ReadCounter[DATA_SIZE-1:0] : 0; 


reg [LENGTH_SIZE-1:0] DelReadCounter[0:3];
always @(posedge clk or negedge rstn)
    if (!rstn) begin
			DelReadCounter[0] <= 0;
			DelReadCounter[1] <= 0;
			DelReadCounter[2] <= 0;
			DelReadCounter[3] <= 0;
				end
	 else begin 
			DelReadCounter[0] <= ReadCounter;
			DelReadCounter[1] <= DelReadCounter[0];
			DelReadCounter[2] <= DelReadCounter[1];
			DelReadCounter[3] <= DelReadCounter[2];
				end
wire [1:0] SelectFrame = DelReadCounter[1][1:0];
reg [DATA_SIZE-1:0] Send_FeamData_Reg;
always @(posedge clk or negedge rstn)
    if (!rstn) Send_FeamData_Reg <= 0;
	 else Send_FeamData_Reg <= FremMemRDData[SelectFrame];
		

reg [LENGTH_SIZE-1:0] Send_His_Reg[0:2];
always @(posedge clk or negedge rstn)
    if (!rstn) begin 
			Send_His_Reg[0] <= 0;
			Send_His_Reg[1] <= 0;
			Send_His_Reg[2] <= 0;
				end
	  else begin 
			Send_His_Reg[0] <= HisMemRDData[0] + HisMemRDData[1];
			Send_His_Reg[1] <= HisMemRDData[2] + HisMemRDData[3];
			Send_His_Reg[2] <= Send_His_Reg[0] + Send_His_Reg[1];
			  end

reg [2:0] FremEn;
reg [3:0] HisEn ;
always @(posedge clk or negedge rstn)
    if (!rstn) begin
			FremEn <= 3'b000;
			HisEn  <= 4'b0000;
				end
	 else begin 
			FremEn <= {FremEn[2:0],FremMemRD};
			HisEn  <= {HisEn [3:0],HisMemRD };
		end

wire [DATA_SIZE-1:0]  FramData   = Send_FeamData_Reg;
wire [LENGTH_SIZE-1:0] FramAdd   = DelReadCounter[2];
wire FramEn                      = FremEn[2];
wire [LENGTH_SIZE-1:0] HistaData = Send_His_Reg[2];
wire [DATA_SIZE-1:0]   HistaAdd  = (HisEn[3]) ? DelReadCounter[3] : 0;
wire HistaEn                     = HisEn[3];
endmodule
