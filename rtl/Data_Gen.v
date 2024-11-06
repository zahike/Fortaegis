`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2024 09:13:10 AM
// Design Name: 
// Module Name: Data_Gen
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


module Data_Gen
#(
parameter DATA_SIZE = 4
)
(
    input clk,
    input rstn,
    
    output Valid,
    output [DATA_SIZE-1:0] Data
    );

reg[23:0] DataValid;
reg [DATA_SIZE-1:0] Tcount;
always @(posedge clk or negedge rstn)
    if (!rstn)  DataValid <= 0;
     else DataValid <= {DataValid[22:0],rstn};        
always @(posedge clk or negedge rstn)
    if (!rstn) Tcount <= 0 ; 
     else if (DataValid[23]) Tcount <= Tcount + 1;
//     else if (DataValid[23]) begin 
//			Tcount <= Tcount - 1;
//			if (Tcount == 0) Tcount <= 14 ;
//			 end
			 
reg [15:0] lfsr;
wire lfsr_xnor;
always @(posedge clk or negedge rstn)
    if (!rstn) lfsr <=16'habcd;    
     else if (!DataValid[23]) lfsr <=16'habcd;   
     else lfsr    <= {lfsr_xnor,lfsr[15:1]};
assign lfsr_xnor = (lfsr[12] ^ lfsr[3] ^  lfsr[1]^ lfsr[0]) ? 1'd0 : 1'd1;  
			 			 
assign Valid = DataValid[23];
//assign Data  = Tcount;
assign Data  = lfsr[DATA_SIZE-1:0];
    
endmodule
