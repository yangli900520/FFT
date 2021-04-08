`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module PE #(parameter POINT = 4) (
   input              clk,
   input              rst_n,
   input DATA_BUS  par,
   input DATA_BUS  in,
   output DATA_BUS out,
   input              select, // 1 from par, 0 from input
   input  [1:0]       scaling
);
   localparam STEP = 512/POINT;
   DATA_BUS real_in, out_pre, out_w;

   assign real_in = (select == 1) ? par : in;

   DATA_BUS temp, temp_w;
   logic flag, flag_w;
   logic mem_flag, mem_flag_w;

   DATA_BUS add_up, add_down, sub_up, sub_down, twiddle, add_out, mult_out;

   logic ctrl_write_in, ctrl_read_in, ctrl_write_out, ctrl_read_out;
   DATA_SAMPLE data_write_in, data_write_out;
   logic [$clog2(POINT) - 2 : 0] addr_in, addr_in_w, addr_out, addr_out_w;
   logic [31:0] data_read_in, data_read_out; 
   logic [7:0] index, index_w, index_p;
   logic ctrl_read_in_p, ctrl_read_out_p;
   DATA_BUS in_p;
   logic lut_valid;
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

   lut l1 (
      .clk(clk),
      .rst_n(rst_n),
      .index(index_p),
      .valid(lut_valid),
      .twiddle(twiddle)
   );  

   ram #(.DATA_WIDTH(32), .MEM_SIZE(POINT/2)) input_buffer (
      .clk(clk),
      .enable_write(ctrl_write_in),
      .enable_read (ctrl_read_in),
      .ctrl_write(ctrl_write_in),
      .addr(addr_in),
      .data_write(data_write_in),
      .data_read(data_read_in)
    );

   ram #(.DATA_WIDTH(32), .MEM_SIZE(POINT/2)) output_buffer (
      .clk(clk),
      .enable_write(ctrl_write_out),
      .enable_read (ctrl_read_out),
      .ctrl_write(ctrl_write_out),
      .addr(addr_out),
      .data_write(data_write_out),
      .data_read(data_read_out)
    );
    DATA_BUS in_p_p, in_p_p_p;
    logic [31:0] data_read_in_p, data_read_in_p_p;
    logic ctrl_read_in_p_p, ctrl_read_in_p_p_p;
   always_comb begin
      temp_w = temp;
      flag_w = flag;

      data_write_out = mult_out.data;
      add_up.data = data_read_in_p_p;
      add_up.valid = ctrl_read_in_p_p_p;
      add_down = in_p_p_p;
      sub_up.valid = ctrl_read_in_p;
      sub_up.data = data_read_in;
      sub_down = in_p;
      lut_valid = ctrl_read_in_p;
      ctrl_write_in = 0;
      ctrl_read_in = 0;
      ctrl_read_out = 0;
      ctrl_write_out = 0;
      index_w = index; 
      addr_in_w = addr_in;
      addr_out_w = addr_out;
      mem_flag_w = mem_flag;
      if (real_in.valid == 1) begin
         if (flag == 0) begin
            ctrl_write_in = 1;
            data_write_in = real_in.data;
            if(addr_in == POINT/2 - 1) begin
               addr_in_w = 0;
               flag_w = 1;
            end
            else begin
               addr_in_w = addr_in + 1;
            end
         end
         else begin
            ctrl_read_in = 1;
          
            if(addr_in == POINT/2 - 1) begin
               addr_in_w = 0;
               flag_w = 0;
               index_w = 0;
            end
            else begin
               addr_in_w = addr_in + 1;
               index_w = index + STEP;
            end
            
         end
      end

      if (add_out.valid == 1) begin
         out_pre = add_out;
      end
      else if (ctrl_read_out_p == 1) begin
         out_pre.data = data_read_out;
         out_pre.valid = ctrl_read_out_p;
      end
      else begin
         out_pre = 0;
      end
        
      if (mem_flag == 0) begin
         if (mult_out.valid == 1) begin
            ctrl_write_out = 1;
            if (addr_out == POINT/2 - 1) begin
               addr_out_w = 0;
               mem_flag_w = 1;
            end
            else begin
               addr_out_w = addr_out + 1;
            end
         end
      end
      else begin
         ctrl_read_out = 1;
         if (addr_out == POINT/2 - 1) begin
            addr_out_w = 0;
            mem_flag_w = 0;
         end
         else begin
            addr_out_w = addr_out + 1;
         end
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
         ctrl_read_in_p <= 0;
         ctrl_read_in_p_p <= 0;
         ctrl_read_out_p <= 0;
         in_p <= 0;
         in_p_p <= 0;
         data_read_in_p <= 0;
         addr_in <= 0;
         addr_out <= 0;
         index <= 0;
         index_p <= 0;
         mem_flag <= 0;
         ctrl_read_in_p_p_p <= 0;
         in_p_p_p <= 0;
         data_read_in_p_p <= 0;
      end
      else begin
         out <= #1 out_w;
         temp <= #1 temp_w;
         flag <= #1 flag_w;
         ctrl_read_in_p <= #1 ctrl_read_in;
         ctrl_read_out_p <= #1 ctrl_read_out;
         in_p <=#1  real_in;
         addr_in <= #1 addr_in_w;
         addr_out <= #1 addr_out_w;
         index <= #1 index_w;
         index_p <= #1 index;
         mem_flag <= #1 mem_flag_w;
         ctrl_read_in_p_p <= #1 ctrl_read_in_p;
         in_p_p <= #1 in_p;
         data_read_in_p <= #1 data_read_in;
         ctrl_read_in_p_p_p <= #1 ctrl_read_in_p_p;
         in_p_p_p <= #1 in_p_p;
         data_read_in_p_p <= #1 data_read_in_p;
      end
   end
endmodule 
