`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module cmult(
    input  DATA_SAMPLE              opa,
    input  DATA_SAMPLE              opb,
    output DATA_SAMPLE              out
    );
    
    logic signed [`DATA_WIDTH  - 1  : 0] aR, bR, aI, bI;
    logic signed [2*`DATA_WIDTH - 1 : 0] aRbR, aRbI, aIbR, aIbI;
    logic signed [2*`DATA_WIDTH     : 0] result_pre_R, result_pre_I;
    logic signed [2*`DATA_WIDTH     : 0] result_pre_R_t, result_pre_I_t;

    assign  aR = opa.data_r;
    assign  aI = opa.data_i;
    assign  bR = opb.data_r;
    assign  bI = opb.data_i;

    assign  result_pre_R_t = result_pre_R >>> `SHIFT_AMOUNT;
    assign  result_pre_I_t = result_pre_I >>> `SHIFT_AMOUNT;

    assign  aRbR = aR * bR;
    assign  aRbI = aR * bI;
    assign  aIbR = aI * bR;
    assign  aIbI = aI * bI;

    assign  result_pre_R = aRbR - aIbI;
    assign  result_pre_I = aIbR + aRbI;

   sat_32 sr(
      .in(result_pre_R_t),
      .out(out.data_r)
   );

   sat_32 si(
      .in(result_pre_I_t),
      .out(out.data_i)
   );
endmodule

