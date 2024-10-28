`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 07:18:17 PM
// Design Name: 
// Module Name: CompReg
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


module CompReg
#(
parameter DATA_SIZE   =  4,
parameter DATA_NUM    = 16,
parameter LENGTH      = 64,
parameter LENGTH_SIZE =  6
)
(
    input clk,
    input rst,

    input  PreComper,
    input [DATA_SIZE-1:0] PreData,
    input [LENGTH_SIZE-1:0]  PreCountNum,
    input [DATA_SIZE-1:0] Data,
    input [LENGTH_SIZE-1:0]  InCountNum,
    input  In_Valid,

    output NeComper,
    output [DATA_SIZE-1:0] NeData,
    output [LENGTH_SIZE-1:0]  NeCountNum
    );
reg [DATA_SIZE-1:0] CurrData;
reg [LENGTH_SIZE-1:0]  CurrCount;
wire Comper = (In_Valid && (InCountNum > CurrCount)) ? 1'b1 : 1'b0;

always @(posedge clk or posedge rst)
    if (rst) begin 
        CurrData  <= 0;
        CurrCount <= 0;
            end            
     else if (PreComper) begin 
                  CurrData  <= PreData;
                  CurrCount <= PreCountNum;
                    end
     else if (Comper) begin 
                  CurrData  <= Data;
                  CurrCount <= InCountNum;
                    end
              
assign NeComper = PreComper || Comper;
assign  NeData     = CurrData ;
assign  NeCountNum = CurrCount;
	
endmodule
