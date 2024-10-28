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
                
    input Valid ,
    input [DATA_SIZE-1:0] Data,

	input Stop4calc

    );
////////////////// Split Data to two Channels //////////////////   
reg [1:0] Split;
reg [3:0] WriteData;
reg [DATA_SIZE-1:0] RegData[0:3];

always @(posedge clk200 or negedge rstn)
    if (!rstn) Split <= 2'b00;
     else if (Valid) Split <= Split +1;	

genvar i;
generate 
	for (i=0;i<4;i=i+1) begin 
		always @(posedge clk200 or negedge rstn)
			if (!rstn) begin 
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
    .Data  (RegData[i])
    );
	end	
endgenerate 






	 
endmodule
