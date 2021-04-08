`timescale 1 ns / 1 ps
`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module FFT_top #
(      parameter C_S_AXI_DATA_WIDTH = 32, C_S_AXI_ADDR_WIDTH = 9, C_M_AXIS_TDATA_WIDTH	= 32, C_S_AXIS_TDATA_WIDTH = 32
        
)
(
   input   S_AXI_ACLK,
   input   S_AXI_ARESETN,
   input  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
   input  [2 : 0] S_AXI_AWPROT,
   input   S_AXI_AWVALID,
   output logic  S_AXI_AWREADY,
   input  [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
   input  [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
   input   S_AXI_WVALID,
   output logic  S_AXI_WREADY,
   output logic [1 : 0] S_AXI_BRESP,
   output logic  S_AXI_BVALID,
   input   S_AXI_BREADY,
   input  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
   input  [2 : 0] S_AXI_ARPROT,
   input   S_AXI_ARVALID,
   output logic  S_AXI_ARREADY,
   output logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
   output logic [1 : 0] S_AXI_RRESP,
   output logic  S_AXI_RVALID,
   input   S_AXI_RREADY,

   input   clk,
   input   rst_n,

   input   M_AXIS_ACLK,
   input   M_AXIS_ARESETN,
   output logic  M_AXIS_TVALID,
   output logic [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
   output logic [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
   output logic  M_AXIS_TLAST,
   input         M_AXIS_TREADY,

   input   S_AXIS_ACLK,
   input   S_AXIS_ARESETN,
   output logic  S_AXIS_TREADY,
   input  [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
   input  [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
   input   S_AXIS_TLAST,
   input   S_AXIS_TVALID
);

   logic [31:0]input_config, input_command, status;
   logic [1:0]config_valid;  
   logic       last;
   lite_slave ls1 (.*);

   logic ready_from_cont;
  
   DATA_BUS  RX_to_IP;

   RX_TO_CONT rx_to_cont;

   stream_slave ss1(.*, .is_ready(ready_from_cont), .data_out(RX_to_IP));

   logic ready_to_OB;
   DATA_BUS OB_to_TX;

   stream_master sm1(.*, .is_ready(ready_to_OB), .data_in(OB_to_TX), .last_out(last));

   CONT_TO_COMP cont_to_comp;
   CONT_TO_TX   cont_to_tx;
   TX_TO_CONT   tx_to_cont;

   FFT_cont Fc1 (.*, .is_ready(ready_from_cont));

   DATA_BUS  IP_to_OB;

   FFT_compute Fcm (.*, .in(RX_to_IP), .out(IP_to_OB));
  
   output_buffer ob (.*, .data_in(IP_to_OB), .data_out(OB_to_TX), .is_ready(ready_to_OB));
 
endmodule









