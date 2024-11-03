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
    input [DATA_SIZE-1:0] Data,

	output [DATA_SIZE-1:0]  FramData,
	output [LENGTH_SIZE-1:0] FramAdd,
	output FramEn,                   

	output SortValid ,
    output [DATA_SIZE -1:0]  MaxCountData1,
    output [LENGTH_SIZE-1:0] MaxCount1,
    output [DATA_SIZE -1:0]  MaxCountData2,
    output [LENGTH_SIZE-1:0] MaxCount2,
    output [DATA_SIZE -1:0]  MaxCountData3,
    output [LENGTH_SIZE-1:0] MaxCount3

    );
////////////////// Split Data to two Channels //////////////////   
reg [1:0] Split;
reg       SplitValid;
reg [0:3]           WriteValid;
reg [DATA_SIZE-1:0] RegData[0:3];

wire                   FremMemRD    ;
wire [LENGTH_SIZE-3:0] FremMemRDAdd ;
wire [DATA_SIZE-1:0]   FremMemRDData[0:3];
wire                   HisMemRD     ;
wire [DATA_SIZE-1:0]   HisMemRDAdd  ;
wire [LENGTH_SIZE-1:0] HisMemRDData[0:3] ;

reg [2:0]DevValid200;
reg [3:0]DevValid350;
reg [1:0] Split200;
reg ExCollect;
always@(posedge clk200 or negedge rstn)
	if (!rstn) begin 
		Split200 <= 2'b00;
		ExCollect <= 1'b0;
			end
	 else if (Collect) begin
		Split200 <= Split200 + 1;
		ExCollect <= Collect;
			end		
	 else if (ExCollect) begin 
		Split200 <= Split200 + 1;
		if (Split200 == 2'b11) ExCollect <= 1'b0;
			end

always@(posedge clk200 or negedge rstn)
	if (!rstn) DevValid200 <= 3'b000;
	 else DevValid200 <= {DevValid200[1:0],((Collect || ExCollect) && Valid)};
always@(posedge clk or negedge rstn)
	if (!rstn) DevValid350 <= 3'b000;
	 else DevValid350 <= {DevValid350[1:0],DevValid200[2]};
//----------- INPUT CLOCK Synchronize ---// INST_TAG
wire [11:0] dout;
wire empty;
wire rd_en = !empty;
fifo_generator_0 fifo_generator_0 (
  .wr_clk(clk200),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din({{12-DATA_SIZE{1'b0}},Data}),        // input wire [11 : 0] din
  .wr_en(Valid && (Collect || ExCollect)),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(dout),      // output wire [11 : 0] dout
  .full(),      // output wire full
  .empty(empty)    // output wire empty
);

always @(posedge clk or negedge rstn)
    if (!rstn) begin 
			Split <= 2'b00;
			SplitValid <= 1'b0;
				end
	 else if (!DevValid350[1]) begin 
			SplitValid <= 1'b0;
				end
     else begin 
			SplitValid <= rd_en;
			if (SplitValid) Split <= Split +1;	
				end
genvar i;
generate 
	for (i=0;i<4;i=i+1) begin 
		always @(posedge clk or negedge rstn)
			if (!rstn) begin 
				WriteValid[i] <= 1'b0;
				RegData[i]    <=    0;
					end 
			 else if (!DevValid350[2]) begin 
				WriteValid[i] <= 1'b0;
				RegData[i]    <=    0;
					end 
			 else if (SplitValid && (Split == i)) begin 
					WriteValid[i] <= SplitValid;
					RegData[i]    <= dout[DATA_SIZE-1:0];
						end
				   else WriteValid[i] <= 1'b0;

Histagram_chane
#(
.DATA_SIZE   (DATA_SIZE  ),
.DATA_NUM    (DATA_NUM   ),
.LENGTH      (LENGTH     ),
.LENGTH_SIZE (LENGTH_SIZE)
)
Histagram_chane_inst
(
    .clk   (clk   ),
    .rstn  (rstn  ),

    .Valid (WriteValid[i]),
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

////////////////// Control Logic //////////////////
reg [19:0] DelCollect;
always @(posedge clk or negedge rstn)
    if (!rstn)  DelCollect <= 20'h00000;
	 else DelCollect <= {DelCollect[18:0],(Collect || ExCollect)};

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
		if (DelCollect == 20'hc0000) ReadCounterOn <= 1'b1;
		 else ReadCounterOn <= 1'b0;
			end

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

////////////////// Collect Fram  //////////////////
				
assign FremMemRD    = {4{ReadCounterOn}};
assign FremMemRDAdd = ReadCounter[LENGTH_SIZE-1:2];

wire [1:0] SelectFrame = DelReadCounter[1][1:0];
reg [DATA_SIZE-1:0] Send_FeamData_Reg;
always @(posedge clk or negedge rstn)
    if (!rstn) Send_FeamData_Reg <= 0;
	 else Send_FeamData_Reg <= FremMemRDData[SelectFrame];

reg [2:0] FremEn;
always @(posedge clk or negedge rstn)
    if (!rstn) FremEn <= 3'b000;
	 else FremEn <= {FremEn[2:0],FremMemRD};

assign FramData = Send_FeamData_Reg;
assign FramAdd  = DelReadCounter[2];
assign FramEn   = FremEn[2];

////////////////// Calculate Top Values //////////////////
assign HisMemRD    = (ReadCounter[LENGTH_SIZE-1:DATA_SIZE] == 0) ? {4{ReadCounterOn}}      : 0;
assign HisMemRDAdd = (ReadCounter[LENGTH_SIZE-1:DATA_SIZE] == 0) ? ReadCounter[DATA_SIZE-1:0] : 0; 

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

reg [4:0] HisEn ;
always @(posedge clk or negedge rstn)
    if (!rstn)  HisEn  <= 5'b00000;
	 else HisEn  <= {HisEn [3:0],HisMemRD };

wire [LENGTH_SIZE-1:0] HistaData = Send_His_Reg[2];
wire [DATA_SIZE-1:0]   HistaAdd  = (HisEn[3]) ? DelReadCounter[3] : 0;
wire                   HistaEn   = HisEn[3];

wire                   SortComper  [0:3];
wire [DATA_SIZE-1:0]   SortData    [0:3];
wire [LENGTH_SIZE-1:0] SortCountNum[0:3];
assign SortComper  [0] = 0;
assign SortData    [0] = 0;
assign SortCountNum[0] = 0;

wire DisableComper = (DelCollect[3:0] == 4'hF) ? 1'b1 : 1'b0;
generate 
   for (i=0;i<3;i=i+1) begin 
CompReg
#(
.DATA_SIZE   (DATA_SIZE  ),
.DATA_NUM    (DATA_NUM   ),
.LENGTH      (LENGTH     ),
.LENGTH_SIZE (LENGTH_SIZE)
)
CompReg_inst
(
    .clk(clk),
    .rst(DisableComper),
    
    .PreComper  (SortComper  [i]),
    .PreData    (SortData    [i]),
    .PreCountNum(SortCountNum[i]),
    .Data       (HistaAdd    ),
    .InCountNum (HistaData   ),
    .In_Valid   (HistaEn   ),
                
    .NeComper   (SortComper  [i+1]),
    .NeData     (SortData    [i+1]),
    .NeCountNum (SortCountNum[i+1])
    );
   end 
endgenerate

assign SortValid = (HisEn == 5'b10000) ? 1'b1 : 1'b0;

assign MaxCountData1 = SortData[1];
assign MaxCount1     = SortCountNum[1];
assign MaxCountData2 = SortData[2];
assign MaxCount2     = SortCountNum[2];
assign MaxCountData3 = SortData[3];
assign MaxCount3     = SortCountNum[3];

endmodule
