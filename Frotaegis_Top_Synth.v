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
parameter DATA_SIZE   =  12,
parameter DATA_NUM    = 4096,
parameter LENGTH      = 32768,
parameter LENGTH_SIZE =  15
)
(
  inout [14:0]DDR_addr,
  inout [2:0]DDR_ba,
  inout DDR_cas_n,
  inout DDR_ck_n,
  inout DDR_ck_p,
  inout DDR_cke,
  inout DDR_cs_n,
  inout [3:0]DDR_dm,
  inout [31:0]DDR_dq,
  inout [3:0]DDR_dqs_n,
  inout [3:0]DDR_dqs_p,
  inout DDR_odt,
  inout DDR_ras_n,
  inout DDR_reset_n,
  inout DDR_we_n,
  inout FIXED_IO_ddr_vrn,
  inout FIXED_IO_ddr_vrp,
  inout [53:0]FIXED_IO_mio,
  inout FIXED_IO_ps_clk,
  inout FIXED_IO_ps_porb,
  inout FIXED_IO_ps_srstb
//    input clk200,
//    input clk350,
//    input rstn
    );

    wire clk200;
    wire clk350;
    wire rstn  ;

  wire [31:0]APB_M_0_paddr;
  wire APB_M_0_penable;
  wire [31:0]APB_M_0_prdata;
  wire [0:0]APB_M_0_pready;
  wire [0:0]APB_M_0_psel;
  wire [0:0]APB_M_0_pslverr;
  wire [31:0]APB_M_0_pwdata;
  wire APB_M_0_pwrite;
  wire FCLK_CLK0;
  wire FCLK_CLK1;
  wire [31:0]S_AXIS_S2MM_0_tdata;
  wire [3:0]S_AXIS_S2MM_0_tkeep;
  wire S_AXIS_S2MM_0_tlast;
  wire S_AXIS_S2MM_0_tready;
  wire S_AXIS_S2MM_0_tvalid;
  wire [0:0]peripheral_aresetn;

  Frotaegis_BD Frotaegis_BD_i
       (.APB_M_0_paddr(APB_M_0_paddr),
        .APB_M_0_penable(APB_M_0_penable),
        .APB_M_0_prdata(APB_M_0_prdata),
        .APB_M_0_pready(APB_M_0_pready),
        .APB_M_0_psel(APB_M_0_psel),
        .APB_M_0_pslverr(APB_M_0_pslverr),
        .APB_M_0_pwdata(APB_M_0_pwdata),
        .APB_M_0_pwrite(APB_M_0_pwrite),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_CLK0(clk200),
        .FCLK_CLK1(clk350),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .S_AXIS_S2MM_0_tdata(S_AXIS_S2MM_0_tdata),
        .S_AXIS_S2MM_0_tkeep(S_AXIS_S2MM_0_tkeep),
        .S_AXIS_S2MM_0_tlast(S_AXIS_S2MM_0_tlast),
        .S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready),
        .S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid),
        .peripheral_aresetn(rstn));

wire SortValid ;
wire StartColl;
wire [DATA_SIZE -1:0]  MaxCountData1;
wire [LENGTH_SIZE-1:0] MaxCount1    ;
wire [DATA_SIZE -1:0]  MaxCountData2;
wire [LENGTH_SIZE-1:0] MaxCount2    ;
wire [DATA_SIZE -1:0]  MaxCountData3;
wire [LENGTH_SIZE-1:0] MaxCount3    ;

Registers
#(
.DATA_ZISE (DATA_SIZE ),
.LENGTH_ADD(LENGTH_SIZE)
)
Registers_inst
(
 .FCLK_CLK1(clk350),
 .rstn     (rstn     ),
 
.APB_M_0_paddr  (APB_M_0_paddr  ),
.APB_M_0_penable(APB_M_0_penable),
.APB_M_0_prdata (APB_M_0_prdata ),
.APB_M_0_pready (APB_M_0_pready ),
.APB_M_0_psel   (APB_M_0_psel   ),
.APB_M_0_pslverr(APB_M_0_pslverr),
.APB_M_0_pwdata (APB_M_0_pwdata ),
.APB_M_0_pwrite (APB_M_0_pwrite ),

.StartColl    (StartColl    ),
.MaxCountData1(MaxCountData1),
.MaxCount1    (MaxCount1    ),
.MaxCountData2(MaxCountData2),
.MaxCount2    (MaxCount2    ),
.MaxCountData3(MaxCountData3),
.MaxCount3    (MaxCount3    )
   );

wire Collect = 1'b1;
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

wire [DATA_SIZE-1:0]   FramData     ;
wire [LENGTH_SIZE-1:0] FramAdd      ;
wire                   FramEn       ;

assign S_AXIS_S2MM_0_tdata  = {{32-DATA_SIZE{1'b0}},FramData};
assign S_AXIS_S2MM_0_tkeep  = 4'hF;
assign S_AXIS_S2MM_0_tlast  = (FramAdd == LENGTH-1) ? 1'b1 : 1'b0;
//assign S_AXIS_S2MM_0_tready ;
assign S_AXIS_S2MM_0_tvalid = FramEn;


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

    .Collect(StartColl),
	
    .Valid (Valid),
    .Data  (Data),
	
	.FramData     (FramData     ),
	.FramAdd      (FramAdd      ),
	.FramEn       (FramEn       ),
	
	.SortValid    (SortValid),
    .MaxCountData1(MaxCountData1),
    .MaxCount1    (MaxCount1    ),
    .MaxCountData2(MaxCountData2),
    .MaxCount2    (MaxCount2    ),
    .MaxCountData3(MaxCountData3),
    .MaxCount3    (MaxCount3    )
	
    );
    
endmodule
