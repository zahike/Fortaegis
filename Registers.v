`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2024 04:34:54 PM
// Design Name: 
// Module Name: Registers
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


module Registers
#(
parameter DATA_ZISE  = 4,
parameter LENGTH_ADD = 5
)
(
 input FCLK_CLK1,
 input rstn,
 
input [31:0]APB_M_0_paddr,
input APB_M_0_penable,
output [31:0]APB_M_0_prdata,
output [0:0]APB_M_0_pready,
input [0:0]APB_M_0_psel,
output [0:0]APB_M_0_pslverr,
input [31:0]APB_M_0_pwdata,
input APB_M_0_pwrite,

output StartColl,
    input [DATA_ZISE -1:0] MaxCountData1,
    input [LENGTH_ADD-1:0] MaxCount1,
    input [DATA_ZISE -1:0] MaxCountData2,
    input [LENGTH_ADD-1:0] MaxCount2,
    input [DATA_ZISE -1:0] MaxCountData3,
    input [LENGTH_ADD-1:0] MaxCount3
   );
    
reg RegStartColl;
always @(posedge FCLK_CLK1 or negedge rstn)
    if (!rstn) RegStartColl <= 1'b1;
     else if (APB_M_0_penable && APB_M_0_psel && APB_M_0_pwrite && (APB_M_0_paddr[7:0] == 8'h00)) RegStartColl <= APB_M_0_pwdata[0]; 
assign StartColl = RegStartColl;     
reg [31:0]prdata;
always @(posedge FCLK_CLK1 or negedge rstn)
    if (!rstn) prdata <= 32'h00000000;
     else begin 
        case (APB_M_0_paddr[7:0])
             8'h00 : prdata <= {31'h00000000,StartColl};
             8'h04 : prdata <= {{(16-DATA_ZISE){1'b0}},MaxCountData1,{(16-LENGTH_ADD){1'b0}},MaxCount1};
             8'h08 : prdata <= {{(16-DATA_ZISE){1'b0}},MaxCountData2,{(16-LENGTH_ADD){1'b0}},MaxCount2};
             8'h0C : prdata <= {{(16-DATA_ZISE){1'b0}},MaxCountData3,{(16-LENGTH_ADD){1'b0}},MaxCount3};
           default : prdata <= 32'h00000000;
        endcase
       end

assign APB_M_0_prdata = prdata;

wire enReady = (APB_M_0_penable && APB_M_0_psel) ? 1'b1 : 1'b0;     
reg ready;
always @(posedge FCLK_CLK1 or negedge rstn)
    if (!rstn) ready <= 1'b0;
     else if (enReady) ready <= enReady;
     else  ready <= 1'b0;



     
assign APB_M_0_pready  = ready;
assign APB_M_0_pslverr = 1'b0;
     
endmodule
