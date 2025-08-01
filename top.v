`timescale 1ns / 1ps
module top
#(
  parameter DSIZE = 32,
  parameter ASIZE = 6,
  parameter ALMOST_FULL_THRESH  = (1<<ASIZE)-2, // Threshold for almost full
  parameter ALMOST_EMPTY_THRESH = 2             // Threshold for almost empty
)
(
  output [DSIZE-1:0] rdata,
  output             wfull,
  output             rempty,
  output             almost_full,
  output             almost_empty,
  input  [DSIZE-1:0] wdata,
  input              winc, wclk, wrst_n,
  input              rinc, rclk, rrst_n
);

  wire   [ASIZE-1:0] waddr, raddr;
  wire   [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;
  wire   [ASIZE:0]   wbin, rbin;

  sync_r2w  sync_r2w(
    .wq2_rptr(wq2_rptr),
    .rptr(rptr),
    .wclk(wclk),
    .wrst_n(wrst_n)
  );

  sync_w2r  sync_w2r(
    .rq2_wptr(rq2_wptr),
    .wptr(wptr),
    .rclk(rclk),
    .rrst_n(rrst_n)
  );

  fifo_mem #(DSIZE, ASIZE) fifo_mem(
    .rdata(rdata),
    .wdata(wdata),
    .waddr(waddr),
    .raddr(raddr),
    .wclken(winc & ~wfull),
    .wfull(wfull),
    .wclk(wclk)
  );

  rptr_empty #(ASIZE, ALMOST_EMPTY_THRESH) rptr_empty(
    .rempty(rempty),
    .almost_empty(almost_empty),
    .raddr(raddr),
    .rptr(rptr),
    .rbin(rbin),
    .rq2_wptr(rq2_wptr),
    .rinc(rinc & ~rempty),
    .rclk(rclk),
    .rrst_n(rrst_n)
  );

  wptr_full #(ASIZE, ALMOST_FULL_THRESH) wptr_full(
    .wfull(wfull),
    .almost_full(almost_full),
    .waddr(waddr),
    .wptr(wptr),
    .wbin(wbin),
    .wq2_rptr(wq2_rptr),
    .winc(winc & ~wfull),
    .wclk(wclk),
    .wrst_n(wrst_n)
  );
endmodule
