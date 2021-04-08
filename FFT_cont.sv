`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module FFT_cont (
   output  CONT_TO_COMP  cont_to_comp,
   output  CONT_TO_TX    cont_to_tx,
   input   TX_TO_CONT    tx_to_cont,
   input   RX_TO_CONT    rx_to_cont,
   output logic          is_ready, // to input
   
   input  [31:0]         input_config,
   input  [31:0]         input_command,
   output logic [31:0]   status,   // indicating if it's ok to start again
   input  [1:0]          config_valid,
   input                 clk,
   input                 rst_n 

);
   // counter
   logic full, empty;
   logic [10:0]  local_count, local_count_w;

   assign full = (local_count == 1024)?1:0;
   assign empty = (local_count == 0)?1:0;

   always_comb begin
      case ({tx_to_cont.valid, rx_to_cont.valid}) 
         2'b10: local_count_w = local_count - 1;
         2'b01: local_count_w = local_count + 1;
         default: local_count_w = local_count;
      endcase
   end
   
   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         local_count <= 0;
      end
      else begin
         local_count <= #1 local_count_w;
      end
   end


   // internal state and status

   logic [1:0]  current_state, current_state_w;

   always_comb begin
      current_state_w = current_state;
      case (current_state)
      0: begin // waiting for input command to say ok
         if (config_valid == 2 && input_command == 1) begin // start signal
            current_state_w = 1;
         end
      end
      1: begin // running, waiting for host to go soft stop
         if (config_valid == 2 && input_command == 2) begin // soft stop signal
            current_state_w = 2;
         end
      end
      2: begin // waiting for IP to clear out remaining packet
         if (empty == 1) begin
            current_state_w = 0;
         end
      end
      default: begin
      end
      endcase
   end
   
   assign status = (current_state == 0);

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         current_state <= 0;
      end
      else begin
         current_state <= #1 current_state_w;
      end
   end


   // a gate at the input interface
   
   logic is_ready_w;
   assign #1 is_ready_w = (current_state == 1) && (full == 0);

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         is_ready <= 0;
      end
      else begin
         is_ready <= #1 is_ready_w;
      end
   end
   // settings
   logic [31:0] setting_w, setting;
   assign  cont_to_tx.ifft = setting[31];
   assign  cont_to_comp.ifft = setting[31];
   assign  cont_to_comp.point = setting[30:27];
   assign  cont_to_tx.point = setting[30:27];
   assign  cont_to_tx.final_shift = setting [26:22];
   assign  cont_to_comp.scaling = setting [21:4];

   always_comb begin
      if (current_state == 0 && config_valid == 1) begin
         setting_w = input_config;
      end
      else begin
         setting_w = setting;
      end
   end

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         setting <= 0;
      end
      else begin
         setting <= #1 setting_w;
      end
   end
endmodule
