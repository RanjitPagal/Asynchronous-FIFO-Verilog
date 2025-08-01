`timescale 1ns / 1ps
module rptr_empty #(
    parameter ADDRSIZE = 6,
    parameter ALMOST_EMPTY_THRESH = 2
) (
    output reg  rempty,
    output reg  almost_empty,
    output      [ADDRSIZE-1:0] raddr,
    output reg [ADDRSIZE:0] rptr,
    output reg [ADDRSIZE:0] rbin,
    input      [ADDRSIZE:0] rq2_wptr,
    input      rinc, rclk, rrst_n
);

  wire [ADDRSIZE:0] rgraynext, rbinnext;
  wire [ADDRSIZE:0] rq2_wptr_bin;

  // Binary-to-Gray code converter
  bin_to_gray #(.SIZE(ADDRSIZE+1)) bin_to_gray_inst (
    .bin(rbinnext),
    .gray(rgraynext)
  );

  // Gray-to-Binary code converter for synchronized write pointer
  gray_to_bin #(.SIZE(ADDRSIZE+1)) gray_to_bin_inst (
    .gray(rq2_wptr),
    .bin(rq2_wptr_bin)
  );

  // Read pointer update
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n) begin
      rbin <= 0;
      rptr <= 0;
    end else begin
      rbin <= rbinnext;
      rptr <= rgraynext;
    end

  assign raddr     = rbin[ADDRSIZE-1:0];
  assign rbinnext  = rbin + (rinc & ~rempty);
   
  wire rempty_val = (rgraynext == rq2_wptr);
  
  // Empty flag logic
  always @(posedge rclk or negedge rrst_n)
      if (!rrst_n)
        rempty <= 1'b1;
      else
        rempty <= rempty_val;
        
  wire [ADDRSIZE:0] fill_level = rq2_wptr_bin - rbinnext;
  
  // Almost empty flag logic
  always @(posedge rclk or negedge rrst_n)
      if (!rrst_n)
        almost_empty <= 1'b0;  
      else
        almost_empty <= ((fill_level <= ALMOST_EMPTY_THRESH) && (fill_level != 0));
        
endmodule
