`timescale 1ns / 1ps
module sync_r2w
#(
    parameter ADDRSIZE = 6
)
(
    output reg [ADDRSIZE:0] wq2_rptr,   // Read pointer synchronized to write clock domain
    input      [ADDRSIZE:0] rptr,       // Gray-coded read pointer from read domain
    input                   wclk, wrst_n
);

reg [ADDRSIZE:0] wq1_rptr;

// Two-stage synchronizer for metastability mitigation
always @(posedge wclk or negedge wrst_n)   
    if (!wrst_n) begin
        wq1_rptr <= 0;          
        wq2_rptr <= 0;
    end else begin        
        wq1_rptr <= rptr;
        wq2_rptr <= wq1_rptr;
    end          

endmodule
