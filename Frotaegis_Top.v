`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2024 07:13:19 PM
// Design Name: 
// Module Name: Frotaegis_Top
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


module Frotaegis_Top
#(
parameter DATA_SIZE   =  4,
parameter DATA_NUM    = 16,
parameter LENGTH      = 64,
parameter LENGTH_SIZE =  6
)
(
    input clk200,
    input clk350,
    input rstn
    );

wire Collect;
wire [DATA_SIZE-1:0] Data;
wire Valid;
Data_Gen
#(
.DATA_SIZE(DATA_SIZE)
)
Data_Gen_inst
(
    .clk(clk200),
    .rstn(rstn),
    
    .Valid(Valid),
    .Data (Data )
    );

Frotaegis_Design
#(
.DATA_SIZE  (DATA_SIZE  ),
.DATA_NUM   (DATA_NUM   ),
.LENGTH     (LENGTH     ),
.LENGTH_SIZE(LENGTH_SIZE)

)
Frotaegis_Design_inst
(
    .clk200(clk200),
    .clk   (clk350),
    .rstn  (rstn),

    .Collect(Collect),
	
    .Valid (Valid),
    .Data  (Data)
    );
    
endmodule
