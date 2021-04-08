`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module output_buffer (
   input               clk,
   input               rst_n, 
   input   DATA_BUS    data_in,    // from IP
   output  DATA_BUS    data_out,   // to output interface
   output  logic       last,

   input   CONT_TO_TX  cont_to_tx,  // ifft, points, final shift
   output  TX_TO_CONT  tx_to_cont,    // to controller, when pop one data controller count -1
   input               is_ready    // from output interface
);


   logic [8:0] num, thre;
   assign thre = num - 1;
   // point translation
   always_comb begin
      case (cont_to_tx.point)
         1: num = 2;
         2: num = 4;
         3: num = 8;
         4: num = 16;
         5: num = 32;
         6: num = 64;
         7: num = 128;
         8: num = 256;
         9: num = 512;
         default:      num = 0; 
      endcase
   end

   DATA_BUS real_data_in_w, real_data_in;
   // do IFFT stuff before sending into buffer
   assign  real_data_in_w.valid = data_in.valid;
   assign  real_data_in_w.data  = (cont_to_tx.ifft == 1) ? {data_in.data.data_i >>> num, data_in.data.data_r >>> num} : data_in.data;

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         real_data_in <= 0;
      end
      else begin
         real_data_in <= #1 real_data_in_w;
      end
   end


   logic [8:0] mem_counter, mem_counter_w;
   logic [8:0] read_counter, read_counter_w;
   logic [8:0] step, step_pre;
   logic [8:0] addr_out;  // address to output buffer
   // bit reverse order, max is 512
   assign  step_pre = {mem_counter[0], mem_counter[1], mem_counter[2], mem_counter[3], mem_counter[4], mem_counter[5], mem_counter[6], mem_counter[7], mem_counter[8]};

   always_comb begin
      case(cont_to_tx.point)
         1: step = step_pre >> 8;
         2: step = step_pre >> 7;
         3: step = step_pre >> 6;
         4: step = step_pre >> 5;
         5: step = step_pre >> 4;
         6: step = step_pre >> 3;
         7: step = step_pre >> 2;
         8: step = step_pre >> 1;
         9: step = step_pre;
         default:      step = 0; 
      endcase
   end

   // assigning IO for buffer

   logic [8:0]        addr_0, addr_1;
  
   DATA_SAMPLE     data_in_0,  data_in_1;
   DATA_SAMPLE     data_out_0, data_out_1;

   logic           rd_0, rd_1, wr_0, wr_1;
   logic           rd, wr;

   ram #(.DATA_WIDTH(32), .MEM_SIZE(512)) ob0 (
      .clk(clk),
      .enable_write(wr_0),
      .enable_read (rd_0),
      .ctrl_write(wr_0),
      .addr(addr_0),
      .data_write(data_in_0),
      .data_read(data_out_0)
    );
   ram #(.DATA_WIDTH(32), .MEM_SIZE(512)) ob1 (
      .clk(clk),
      .enable_write(wr_1),
      .enable_read (rd_1),
      .ctrl_write(wr_1),
      .addr(addr_1),
      .data_write(data_in_1),
      .data_read(data_out_1)
    );
   // some flags for read and write

   logic      wr_flag_0_w, wr_flag_0;
   logic      rd_flag_0_w, rd_flag_0;
   logic      wr_flag_1_w, wr_flag_1;
   logic      rd_flag_1_w, rd_flag_1;
   
   logic           finish_write_0, finish_write_1;
   logic           finish_read_0,  finish_read_1;

   always_comb begin
      wr_flag_0_w = wr_flag_0;
      if (finish_write_0 == 1) begin
         wr_flag_0_w = 0;
      end
      else if (finish_read_0) begin
         wr_flag_0_w = 1;
      end 
   end
   always_comb begin
      wr_flag_1_w = wr_flag_1;
      if (finish_write_1 == 1) begin
         wr_flag_1_w = 0;
      end
      else if (finish_read_1) begin
         wr_flag_1_w = 1;
      end 
   end

   always_comb begin
      rd_flag_0_w = rd_flag_0;
      if (finish_write_0 == 1) begin
         rd_flag_0_w = 1;
      end
      else if (finish_read_0) begin
         rd_flag_0_w = 0;
      end 
   end

   always_comb begin
      rd_flag_1_w = rd_flag_1;
      if (finish_write_1 == 1) begin
         rd_flag_1_w = 1;
      end
      else if (finish_read_1) begin
         rd_flag_1_w = 0;
      end 
   end

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         wr_flag_0 <= 1;
         wr_flag_1 <= 1;
         rd_flag_0 <= 0;
         rd_flag_1 <= 0;
      end
      else begin
         wr_flag_0 <= #1 wr_flag_0_w;
         wr_flag_1 <= #1 wr_flag_1_w;
         rd_flag_0 <= #1 rd_flag_0_w;
         rd_flag_1 <= #1 rd_flag_1_w;
      end
   end

   // ping-pong, giving write priority

   always_comb begin
      addr_0 = 0;
      data_in_0 = 0;
      if (wr_0 == 1) begin
         addr_0 = step;
         data_in_0 = real_data_in.data;
      end
      else if (rd_0 == 1) begin
         addr_0 = read_counter;
      end
   end  

   always_comb begin
      addr_1 = 0;
      data_in_1 = 0;
      if (wr_1 == 1) begin
         addr_1 = step;
         data_in_1 = real_data_in.data;
      end
      else if (rd_1 == 1) begin
         addr_1 = read_counter;
      end
   end 

   // writing into output buffer according to wr_flag, doesn't control flag
 
   always_comb begin
      wr_0 = 0;
      wr_1 = 0;
      mem_counter_w = mem_counter;
      finish_write_0 = 0;
      finish_write_1 = 0;
      if (real_data_in.valid == 1) begin
         if (wr_flag_0 == 1) begin
            wr_0 = 1;
            if (mem_counter == thre) begin
               mem_counter_w = 0;
               finish_write_0 = 1;
            end 
            else begin
               mem_counter_w = mem_counter + 1;
            end
         end
         else if (wr_flag_1 == 1) begin
            wr_1 = 1;
            if (mem_counter == thre) begin
               mem_counter_w = 0;
               finish_write_1 = 1;
            end 
            else begin
               mem_counter_w = mem_counter + 1;
            end
         end
      end
   end

   TX_TO_CONT tx_to_cont_w;
   logic      last_w, last_d;

   always_comb begin
      tx_to_cont_w.valid = 0;
      rd_0 = 0;
      rd_1 = 0;
      finish_read_0 = 0; 
      finish_read_1 = 0;
      last_w = 0;
      read_counter_w = read_counter; 
      if (is_ready == 1) begin
         if (rd_flag_0 == 1) begin
            tx_to_cont_w.valid = 1;
            rd_0 = 1;
            if (read_counter == thre) begin
               read_counter_w = 0;
               finish_read_0 = 1;
               last_w        = 1;
            end
            else begin
               read_counter_w = read_counter + 1;
            end
         end
         else if (rd_flag_1 == 1) begin
            tx_to_cont_w.valid = 1;
            rd_1 = 1;
            if (read_counter == thre) begin
               read_counter_w = 0;
               finish_read_1 = 1;
               last_w        = 1;
            end
            else begin
               read_counter_w = read_counter + 1;
            end
         end
      end
   end

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         mem_counter <= 0;
         read_counter <= 0;
         tx_to_cont <= 0;
         last_d         <= 0;
         last         <= 0;
      end
      else begin
         mem_counter <= #1 mem_counter_w;
         read_counter <= #1 read_counter_w;
         tx_to_cont <= #1 tx_to_cont_w;
         last_d <= #1 last_w;
         last <= #1 last_d;
      end
   end

   // output data

   logic [1:0]  read_pattern, read_pattern_w;
   assign  read_pattern_w = {rd_1, rd_0};
   
   DATA_BUS  data_out_w;
   assign  data_out_w.valid = (read_pattern != 0) ? 1 : 0;

   always_comb begin
      if (read_pattern == 2) data_out_w.data = data_out_1 <<< cont_to_tx.final_shift;
      else if (read_pattern == 1) data_out_w.data = data_out_0 <<< cont_to_tx.final_shift;
      else data_out_w.data = 0;
   end 

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         read_pattern <= 0;
         data_out     <= 0;
      end
      else begin
         read_pattern <= #1 read_pattern_w;
         data_out     <= #1 data_out_w;
      end
   end


 
endmodule  

