`timescale 1ns / 1ps
module fifo_mem
#(
    parameter DATASIZE = 32,  // Data word width               
    parameter ADDRSIZE = 6    // Address width (FIFO depth = 2^ADDRSIZE)
)
(
    output [DATASIZE-1:0] rdata, 
    input  [DATASIZE-1:0] wdata, 
    input  [ADDRSIZE-1:0] waddr, raddr, 
    input                 wclken, wfull, wclk
);

localparam DEPTH = 1 << ADDRSIZE;
reg [DATASIZE-1:0] mem [0:DEPTH-1];

// Read is combinational
assign rdata = mem[raddr];

// Write is synchronous to wclk
always @(posedge wclk)  
    if (wclken && !wfull)
        mem[waddr] <= wdata;

endmodule
