`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module stream_slave # (
   parameter integer C_S_AXIS_TDATA_WIDTH	= 32
)
(
   input   S_AXIS_ACLK,
// AXI4Stream sink: Reset
   input   S_AXIS_ARESETN,
// Ready to accept data in
   output logic  S_AXIS_TREADY,
// Data in
   input  [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
// Byte qualifier
   input  [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
// Indicates boundary of last packet
   input   S_AXIS_TLAST,
// Data is in valid
   input   S_AXIS_TVALID,

   input   is_ready,
   output  DATA_BUS data_out,
   output  RX_TO_CONT rx_to_cont 
);
   assign  rx_to_cont.valid = data_out.valid;
   assign  S_AXIS_TREADY = is_ready;

   DATA_BUS  data_out_w;
 
   assign    data_out_w.valid = is_ready && S_AXIS_TVALID;

   assign  data_out_w.data  = (data_out_w.valid == 1) ? S_AXIS_TDATA : 0; 

   always_ff @ (posedge S_AXIS_ACLK) begin
      if (S_AXIS_ARESETN == 0) begin
         data_out <= 0;
      end
      else begin
         data_out <= #1 data_out_w;
      end
   end 


endmodule
