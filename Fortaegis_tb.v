`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2024 09:20:47 AM
// Design Name: 
// Module Name: Fortaegis_tb
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


module Fortaegis_tb();
reg clk200;
reg clk350;
reg rstn  ;
initial begin 
clk200 = 1'b0;
clk350 = 1'b0;
rstn   = 1'b0;
#100;
rstn   = 1'b1;
end
always #5     clk200 = ~clk200;
always #2.857 clk350 = ~clk350;

initial begin 
force Frotaegis_Top_inst.Stop4calc = 1'b0;
#3000;
force Frotaegis_Top_inst.Stop4calc = 1'b1;
end

Frotaegis_Top Frotaegis_Top_inst(
    .clk200(clk200),
    .clk350(clk350),
    .rstn  (rstn  )
);

wire [3:0] ADD;
wire [3:0] SUB;
initial begin 
force ADD = Frotaegis_Top_inst.Frotaegis_Design_inst.genblk1[0].Histagram_chane_inst.WR_F0MemData ;
force SUB = Frotaegis_Top_inst.Frotaegis_Design_inst.genblk1[0].Histagram_chane_inst.Subdata      ;
#2000;
force Frotaegis_Top_inst.Coll = 1'b0;
end 

wire Check = (ADD == SUB) ? 1'b1 :1'b0;
endmodule
