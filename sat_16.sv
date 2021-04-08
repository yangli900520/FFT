// saturation for 16 bit
// trigger is overflow, sign is sign bit
`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module sat_16(
  // input                                  sign_a,
  // input                                  trigger,
   input         [`DATA_WIDTH     : 0]  result_pre,
   output logic  [`DATA_WIDTH - 1 : 0]  result
);
  logic trigger;


   assign #1 trigger = result_pre[`DATA_WIDTH] ^ result_pre[`DATA_WIDTH - 1];
   always_comb begin
      if (trigger == 1) begin
         if (result_pre[`DATA_WIDTH] == 0) begin
            result = 16'h7fff;
         end
         else begin
            result = 16'h8000;
         end
      end
      else begin
         result = result_pre;
      end
   end
endmodule
   
