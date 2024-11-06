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
#2600;
@(posedge clk350);#1;
force Frotaegis_Top_inst.Collect = 1'b0;
end
always #2.5   clk200 = ~clk200;
always #1.428 clk350 = ~clk350;
initial begin 
force Frotaegis_Top_inst.StartColl   = 1'b0;
force Frotaegis_Top_inst.clk200 = clk200;
force Frotaegis_Top_inst.clk350 = clk350;
force Frotaegis_Top_inst.rstn   = rstn;
@(posedge rstn);
#150;
@(posedge clk200);#1;
force Frotaegis_Top_inst.StartColl   = 1'b1;
#1000000;
@(posedge clk200);#1;
force Frotaegis_Top_inst.StartColl   = 1'b0;

end

Frotaegis_Top Frotaegis_Top_inst(
);

endmodule
