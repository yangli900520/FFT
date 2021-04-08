`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module PE_2_point (
   input              clk,
   input              rst_n,
   input DATA_BUS  par,
   input DATA_BUS  in,
   output DATA_BUS out,
   input              select, // 1 from par, 0 from input
   input  [1:0]       scaling
);

   DATA_BUS real_in, out_pre, out_w;

   assign real_in = (select == 1) ? par : in;

   DATA_BUS temp, temp_w;
   logic flag, flag_w;

   DATA_BUS add_up, add_down, sub_up, sub_down, twiddle, add_out, mult_out;

   butterfly b1 ( 
      .add_up(add_up),
      .add_down(add_down),
      .sub_up(sub_up),
      .sub_down(sub_down),
      .twiddle(twiddle),
      .clk(clk),
      .rst_n(rst_n),
      .add_out(add_out),
      .mult_out(mult_out)
   ); 
  

   always_comb begin
      temp_w = temp;
      flag_w = flag;

      twiddle.valid = 1;
      twiddle.data.data_r = {1'b0, 1'b1, 14'b0};
      twiddle.data.data_i = 0;

      add_up = 0;
      add_down = 0;
      sub_up = 0;
      sub_down = 0;
      if (real_in.valid == 1) begin
         if (flag == 0) begin
            temp_w = real_in;
            flag_w = 1;
         end
         else begin
            temp_w = 0;
            flag_w = 0;
            add_up = temp;
            add_down = real_in;    
            sub_up = temp;
            sub_down = real_in;
         end
      end
   end

   always_comb begin 
      if (add_out.valid == 1) begin
         out_pre = add_out;
      end
      else if (mult_out.valid == 1) begin
         out_pre = mult_out;
      end
      else begin
         out_pre = 0;
      end   
   end

  assign    out_w.valid = out_pre.valid;
  assign    out_w.data.data_r = out_pre.data.data_r >>> scaling;    
  assign    out_w.data.data_i = out_pre.data.data_i >>> scaling;   

  
  always_ff @(posedge clk) begin
      if (rst_n == 0) begin
         out <= 0;
         temp <= 0;
         flag <= 0;
      end
      else begin
         out <= #1 out_w;
         temp <= #1 temp_w;
         flag <= #1 flag_w;
      end
   end
endmodule 
