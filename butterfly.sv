`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module butterfly (
   input   DATA_BUS      add_up,
   input   DATA_BUS      add_down,
   input   DATA_BUS      sub_up,
   input   DATA_BUS      sub_down,
   input   DATA_BUS      twiddle,
   input                 clk,
   input                 rst_n,
   output  DATA_BUS   add_out,
   output  DATA_BUS   mult_out
);

   DATA_SAMPLE add_opa, add_opb, sub_opa, sub_opb, mult_opa, mult_opb;
   DATA_SAMPLE add_out_pre, sub_out_pre, mult_out_pre, sub_out;
   logic mult_valid;
   assign #1 add_opa = (add_up.valid == 1) ? add_up.data   : 0;
   assign #1 add_opb = (add_down.valid == 1) ? add_down.data : 0;
   assign #1 sub_opa = (sub_up.valid == 1) ? sub_up.data   : 0;
   assign #1 sub_opb = (sub_down.valid == 1) ? sub_down.data : 0;
   assign #1 mult_opa = (mult_valid == 1)? sub_out : 0;
   assign #1 mult_opb = (twiddle.valid == 1)? twiddle.data : 0;
     

   cmult m1 (
      .opa(mult_opa),
      .opb(mult_opb),
      .out(mult_out_pre)
   ); 

   cadd a1 (
      .opa(add_opa),
      .opb(add_opb),
      .out(add_out_pre)
   ); 

   csub s1 (
      .opa(sub_opa),
      .opb(sub_opb),
      .out(sub_out_pre)
   ); 

   always_ff @(posedge clk) begin
      if (rst_n == 0) begin
         mult_out.data <= 0;
         sub_out  <= 0;
         add_out.data  <= 0;
         add_out.valid <= 0;
         mult_out.valid <= 0;
         mult_valid <= 0;
      end
      else begin
         mult_out.data <=#1 mult_out_pre;
         sub_out  <=#1 sub_out_pre;
         add_out.data  <=#1 add_out_pre;
         add_out.valid <=#1 (add_up.valid && add_down.valid);
         mult_out.valid <=#1 (mult_valid && twiddle.valid);
         mult_valid <=#1 (sub_up.valid && sub_down.valid);
      end
   end 

endmodule
