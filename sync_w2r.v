`timescale 1ns / 1ps
module sync_w2r
#(
    parameter ADDRSIZE = 6
)
(
    output reg [ADDRSIZE:0] rq2_wptr,   // Write pointer synchronized to read clock domain
    input      [ADDRSIZE:0] wptr,       // Gray-coded write pointer from write domain
    input                   rclk, rrst_n
);

reg [ADDRSIZE:0] rq1_wptr;

// Two-stage synchronizer for metastability mitigation
always @(posedge rclk or negedge rrst_n)   
    if (!rrst_n) begin
        rq1_wptr <= 0;
        rq2_wptr <= 0;
    end else begin
        rq1_wptr <= wptr;
        rq2_wptr <= rq1_wptr;
    end

endmodule
