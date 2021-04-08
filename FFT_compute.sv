`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif

module FFT_compute (
   input  DATA_BUS   in,
   output DATA_BUS   out,
   input  CONT_TO_COMP cont_to_comp,
   input             clk,
   input             rst_n

);

   DATA_BUS  par[9:0];
   assign par[0] = 0;
   
   DATA_BUS  real_in, real_in_w;

   assign  out = par[9];

   assign  real_in_w.valid = in.valid;
   assign  real_in_w.data  = (cont_to_comp.ifft == 1) ? {in.data.data_i, in.data.data_r} : in.data;

   always_ff @ (posedge clk) begin
      if (rst_n == 0) begin
         real_in <= 0;
      end
      else begin
         real_in <= #1 real_in_w;
      end
   end

   logic [8:0] select;
   always_comb begin
      case (cont_to_comp.point)
         1: select = 9'b011111111;
         2: select = 9'b101111111;
         3: select = 9'b110111111;
         4: select = 9'b111011111;
         5: select = 9'b111101111;
         6: select = 9'b111110111;
         7: select = 9'b111111011;
         8: select = 9'b111111101;
         9: select = 9'b111111110;
         default: select = 0;  
      endcase
   end
   genvar i;

   generate 

      PE_2_point PE_2 (
         .clk(clk),
         .rst_n(rst_n),
         .par(par[8]),
         .in(real_in),
         .out(par[9]),
         .select(select[8]),
         .scaling(cont_to_comp.scaling[17:16])
      );

      for (i = 0; i < 8; i = i + 1) begin
      PE #(.POINT(512/(2**i)))  pp (
         .clk(clk),
         .rst_n(rst_n),
         .par(par[i]),
         .in(real_in),
         .out(par[i+1]),
         .select(select[i]),
         .scaling(cont_to_comp.scaling[2*i + 1: 2*i])
      );

      end 

   endgenerate

endmodule
