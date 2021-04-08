`timescale 1ns / 1ps

module stream_master # (
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32
)
(
		input   M_AXIS_ACLK,
		input   M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output logic  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output logic [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output logic [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output logic  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input         M_AXIS_TREADY,

                output logic  is_ready,
                input         last_out,
                input  DATA_BUS  data_in
);
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
        localparam FIFO_WIDTH = 32;      
 
        logic [FIFO_WIDTH - 1 : 0][31:0]       buffer, buffer_w;
        logic [FIFO_WIDTH - 1 : 0]       last_buffer, last_buffer_w;

        logic [$clog2(FIFO_WIDTH) - 1 : 0]             ptr_read_w, ptr_read, ptr_write, ptr_write_w;
        logic                   valid_w, last, last_w;
        logic [31:0]            data_w;

        assign data_w = valid_w? buffer[ptr_read]:0;
        assign last_w = valid_w? last_buffer[ptr_read]:0;
//        assign M_AXIS_TLAST     = last;
        assign M_AXIS_TLAST     = last_w;
        always_comb begin
//           valid_w = 0;
           ptr_read_w = last? 0 : ptr_read;
           if (M_AXIS_TREADY == 1 && ptr_read != ptr_write) begin
              ptr_read_w = ptr_read + 1;
//              valid_w = 1;
           end
        end
        assign valid_w = (ptr_read != ptr_write);
        always_comb begin
           buffer_w = buffer;
           last_buffer_w = last_buffer;
           ptr_write_w = last? 0 : ptr_write;
           if (data_in.valid == 1) begin
              ptr_write_w = ptr_write + 1;
              buffer_w[ptr_write] = data_in.data;
              last_buffer_w[ptr_write] = last_out;
           end
        end
 
        logic is_ready_w;

/*        always_comb begin
           is_ready_w = 0;
           if (ptr_read == 0) begin
              is_ready_w = (ptr_write != FIFO_WIDTH - 2);
           end
           else if (ptr_read == 1) begin
              is_ready_w = (ptr_write != FIFO_WIDTH - 1);
           end
           else begin
              is_ready_w = (ptr_write != (ptr_read - 2));
           end

        end*/
        
        always_comb begin
            is_ready_w = is_ready;
            if(ptr_write + 1'd1 == ptr_read)begin //fifo is full
                is_ready_w = 0;
            end
            if(ptr_write == ptr_read)begin //fifo is empty
                is_ready_w = 1;
            end
        end

        assign M_AXIS_TVALID = valid_w;
        assign M_AXIS_TDATA = data_w;
        
        always_ff @ (posedge M_AXIS_ACLK) begin
           if (M_AXIS_ARESETN == 0) begin
              buffer <= 0;
              ptr_write <= 0;
              ptr_read <= 0;
//              M_AXIS_TVALID <= 0;
              last_buffer <= 0;
//              M_AXIS_TDATA  <= 0; 
              is_ready      <= 0;
              last <= 0;
           end
           else begin
              buffer <= #1 buffer_w;
              last_buffer <= #1 last_buffer_w;
              ptr_write <= #1 ptr_write_w;
              ptr_read <= #1 ptr_read_w;
//              M_AXIS_TVALID <= #1 valid_w;
//              M_AXIS_TDATA  <= #1 data_w;
              last  <=  #1 last_w; 
//              is_ready      <= M_AXIS_TREADY;
              is_ready      <= #1 is_ready_w;
           end
        end

endmodule
