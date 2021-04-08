`ifndef sys_defs_header
`define sys_defs_header
    `include "sys_defs.vh"
`endif


module cadd(
    input  DATA_SAMPLE              opa,
    input  DATA_SAMPLE              opb,
    output DATA_SAMPLE              out
    );
    
    logic signed [`DATA_WIDTH  - 1  : 0] aR, bR, aI, bI;
    logic signed [`DATA_WIDTH     : 0] result_pre_R, result_pre_I;

    assign  aR = opa.data_r;
    assign  aI = opa.data_i;
    assign  bR = opb.data_r;
    assign  bI = opb.data_i;


    assign  result_pre_R = aR + bR;
    assign  result_pre_I = aI + bI;

   sat_16 sr(
      .result_pre(result_pre_R),
      .result(out.data_r)
   );

   sat_16 si(
      .result_pre(result_pre_I),
      .result(out.data_i)
   );
endmodule

