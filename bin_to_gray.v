`timescale 1ns / 1ps
module bin_to_gray #(
    parameter SIZE = 7
) (
    input  [SIZE-1:0] bin,
    output [SIZE-1:0] gray
);
    assign gray = (bin >> 1) ^ bin;
endmodule
