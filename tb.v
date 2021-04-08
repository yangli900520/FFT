`timescale 1ns/1ps

module test;
   // universal
   logic clk, rst_n;
 
   clk_gen cg1 (.clk(clk), .rst_n(rst_n));

parameter C_S_AXI_DATA_WIDTH	= 32;
parameter C_S_AXI_ADDR_WIDTH	= 9;
parameter C_S_AXIS_TDATA_WIDTH = 32;
parameter C_M_AXIS_TDATA_WIDTH = 32;
logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR;
logic [2 : 0] S_AXI_AWPROT, S_AXI_ARPROT;
logic S_AXI_AWVALID, S_AXI_WVALID, S_AXI_BREADY, S_AXI_ARVALID, S_AXI_RREADY;
logic S_AXI_AWREADY, S_AXI_WREADY, S_AXI_BVALID, S_AXI_ARREADY, S_AXI_RVALID;
logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA;
logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB;
logic [1 : 0] S_AXI_BRESP,  S_AXI_RRESP;
logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR;
logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA;

logic [C_S_AXIS_TDATA_WIDTH-1 : 0]          S_AXIS_TDATA;
logic [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]      S_AXIS_TSTRB;
logic S_AXIS_TREADY, S_AXIS_TLAST, S_AXIS_TVALID;
logic M_AXIS_TVALID, M_AXIS_TLAST, M_AXIS_TREADY;
logic [3:0] M_AXIS_TSTRB;
logic [31:0]  M_AXIS_TDATA;
   logic S_AXI_ACLK, S_AXI_ARESETN;
logic M_AXIS_ACLK, M_AXIS_ARESETN, S_AXIS_ACLK, S_AXIS_ARESETN; 

assign S_AXI_ACLK = clk;
assign S_AXIS_ACLK = clk;
assign M_AXIS_ACLK = clk;

assign S_AXI_ARESETN = rst_n;
assign S_AXIS_ARESETN = rst_n;
assign M_AXIS_ARESETN = rst_n;

assign S_AXI_WSTRB  = 4'hf;

FFT_top Ft1 (.*);
lite_test lt1 (.*);
stream_master_test smt1 (.*);
stream_slave_test slt1 (.*);
   initial begin
      # (50000*`CLK_CYCLE)
      
      $finish();
   
   end 

endmodule



