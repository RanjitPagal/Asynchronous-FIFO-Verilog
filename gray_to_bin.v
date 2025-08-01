`timescale 1ns / 1ps
module gray_to_bin #(
    parameter SIZE = 7
) (
    input  [SIZE-1:0] gray,
    output reg [SIZE-1:0] bin
);
    integer i;
    always @* begin
        bin[SIZE-1] = gray[SIZE-1];
        for (i = SIZE-2; i >= 0; i = i - 1)
            bin[i] = bin[i+1] ^ gray[i];
    end
endmodule
