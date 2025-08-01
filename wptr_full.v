`timescale 1ns / 1ps
module wptr_full #(
    parameter ADDRSIZE = 6,
    parameter ALMOST_FULL_THRESH = 62
) (
    output reg wfull,
    output reg almost_full,
    output      [ADDRSIZE-1:0] waddr,
    output reg [ADDRSIZE:0] wptr,
    output reg [ADDRSIZE:0] wbin,
    input      [ADDRSIZE:0] wq2_rptr,
    input      winc, wclk, wrst_n
);

    wire [ADDRSIZE:0] wgraynext, wbinnext;
    wire [ADDRSIZE:0] wq2_rptr_bin;

    // Binary-to-Gray code converter
    bin_to_gray #(.SIZE(ADDRSIZE+1)) bin_to_gray_inst (
        .bin(wbinnext),
        .gray(wgraynext)
    );

    // Gray-to-Binary code converter for synchronized read pointer
    gray_to_bin #(.SIZE(ADDRSIZE+1)) gray_to_bin_inst (
        .gray(wq2_rptr),
        .bin(wq2_rptr_bin)
    );

    assign wbinnext  = wbin + (winc & ~wfull);
    assign waddr     = wbin[ADDRSIZE-1:0];

    wire wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});
    wire [ADDRSIZE:0] fill_level= wbinnext - wq2_rptr_bin;

    // Write Pointer update
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n)
            {wbin, wptr} <= 0;
        else
            {wbin, wptr} <= {wbinnext, wgraynext};

    //Full flag logic
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n)
            wfull <= 1'b0;
        else
            wfull <= wfull_val;

    // Almost_Full flag logic
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n)
            almost_full <= 1'b0;
        else
            almost_full <= ((fill_level >= ALMOST_FULL_THRESH) && !wfull_val);

endmodule
