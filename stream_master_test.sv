`timescale 1 ns / 1 ps

module  stream_master_test #(
 parameter C_S_AXIS_TDATA_WIDTH = 32
)
(
   input            clk,
   output logic  [C_S_AXIS_TDATA_WIDTH-1 : 0]     S_AXIS_TDATA,
   output logic  [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
   output logic                                   S_AXIS_TLAST,
   output logic                                   S_AXIS_TVALID
);
   initial  S_AXIS_TDATA = 0;
   initial  S_AXIS_TSTRB = 0;
   initial  S_AXIS_TLAST = 0;
   initial  S_AXIS_TVALID = 0;
   
   integer dataFile;
   reg [31:0] wdat;
   integer ret;
   integer  rdat;
   integer  idat;
   
   task input_data(); 
      input  [C_S_AXIS_TDATA_WIDTH/2 - 1 : 0] R;
      input  [C_S_AXIS_TDATA_WIDTH/2 - 1 : 0] I;
      begin
         @(posedge clk)
         #2
         S_AXIS_TDATA  = {R,I};
         S_AXIS_TVALID = 1;
      end
   endtask
   
   task no_input();
      begin
         @(posedge clk)
         #2
         S_AXIS_TDATA = 0;
         S_AXIS_TVALID = 0; 
      end
   endtask


   initial begin
   
     delay_cycle (`RESET_CYCLE + 20);
    // data file read
//      dataFile = $fopen("../../../../tx_4000.txt","r");
        dataFile = $fopen("fft_input.dat","r");
        if (!dataFile) begin
            $display("Fail to find data file");
            $finish;
        end
   
/*      delay_cycle (`RESET_CYCLE + 20);
      for (integer i = 1; i < 65; i = i + 1) begin
      input_data  (i, 0);
      end
      for (integer i = 1; i < 65; i = i + 1) begin
      input_data  (i, 0);
      end
      no_input ();*/
      
      for (integer i=0; i<512; i=i+1) begin
            ret = $fscanf(dataFile, "%d %d", rdat, idat);
            input_data  (rdat, idat);
      end   
       no_input ();   
       
       $fclose(dataFile);
      
   end
   

endmodule
