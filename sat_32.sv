`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module sat_32 (
   input [`P_PRODUCT_WIDTH   : 0] in,
   output logic [`DATA_WIDTH - 1 : 0] out
);

   logic trig_0;

   assign #1 trig_0 = (in[`P_PRODUCT_WIDTH - 1 : `DATA_WIDTH - 1] == 0) || (in[`P_PRODUCT_WIDTH - 1 : `DATA_WIDTH - 1] == 17'h1ffff);

   always_comb begin
      if (in == 33'h100000000) begin
         out = 16'h7fff;
      end
      else begin
      if (trig_0 == 1) begin
         out = in[15:0];
      end
      else begin
         if (in[31] == 0) begin
            out = 16'h7fff;
         end
         else begin
            out = 16'h8000;
         end
      end
      end
   end
endmodule
