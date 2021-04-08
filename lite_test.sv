`timescale 1 ns / 1 ps

module lite_test #
(
   parameter C_S_AXI_DATA_WIDTH	= 32, 
             C_S_AXI_ADDR_WIDTH = 9
)
(
   input                                        clk,
   output logic                                 S_AXI_WVALID,
   output logic                                 S_AXI_AWVALID,
   output logic                                 S_AXI_ARVALID,
   output logic    [C_S_AXI_ADDR_WIDTH - 1 : 0] S_AXI_AWADDR,
   output logic    [C_S_AXI_ADDR_WIDTH - 1 : 0] S_AXI_ARADDR,
   output logic    [C_S_AXI_DATA_WIDTH - 1 : 0] S_AXI_WDATA,
   output logic                                 S_AXI_BREADY,
   output logic                                 S_AXI_RREADY

);


    initial S_AXI_WVALID  = 0;
    initial S_AXI_AWVALID = 0;
    initial S_AXI_ARVALID = 0;
    initial S_AXI_AWADDR  = 0;
    initial S_AXI_ARADDR  = 0;
    initial S_AXI_WDATA   = 0;
    initial S_AXI_BREADY  = 0;
    initial S_AXI_RREADY  = 0;

    task input_config();
        input [C_S_AXI_ADDR_WIDTH - 3     : 0] addr;
        input [C_S_AXI_DATA_WIDTH - 1 : 0] data;
 //       input [C_S_AXI_DATA_WIDTH / 2 - 1 : 0] data_I;
        begin
            @(posedge clk)
            #2
            S_AXI_WVALID = 1;
            S_AXI_AWVALID = 1;
            S_AXI_AWADDR = {addr,{2'b0}};
            @(posedge clk)
            #2
            S_AXI_AWADDR = 0;
            S_AXI_WDATA = data;
            @(posedge clk)
            #2
            S_AXI_WVALID = 0;
            S_AXI_AWVALID = 0;
            S_AXI_BREADY = 1;
            S_AXI_WDATA = 0;
            @(posedge clk)
            #2
            S_AXI_BREADY = 0;
        end
    endtask : input_config

    task FFT_config ();
       input           ifft;        // 1
       input   [3:0]   point;       // 4
       input   [4:0]   final_shift; // 5
       input   [17:0]  scaling;     // 18
       begin
          input_config (0, {ifft, point, final_shift, scaling, 4'b0});
       end
    endtask : FFT_config 
    
    task FFT_command ();
       input   [1:0]   command;       // 2
       begin
          input_config (1, {30'b0, command});
       end
    endtask : FFT_command 

    initial begin
       delay_cycle (`RESET_CYCLE + 3);
       FFT_config (0, 9, 0, 18'b010101010101010101);
       delay_cycle (7);
       FFT_command (1);
       delay_cycle (1000);
       FFT_command (2);
    end


endmodule
