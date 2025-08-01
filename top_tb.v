`timescale 1ns / 1ps

module top_tb();
reg  [31:0] wdata;
reg         winc, wclk, wrst_n; 
reg         rinc, rclk, rrst_n;
wire [31:0] rdata;  
wire        wfull;  
wire        rempty;  
wire        almost_full;
wire        almost_empty;

// Instantiate the FIFO
top fifo (
    .rdata(rdata),  
    .wfull(wfull),  
    .rempty(rempty),  
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .wdata(wdata),  
    .winc(winc), 
    .wclk(wclk), 
    .wrst_n(wrst_n), 
    .rinc(rinc), 
    .rclk(rclk), 
    .rrst_n(rrst_n)
);

localparam CYCLE  = 20;
localparam CYCLE1 = 40;

// Write clock generation
initial begin
    wclk = 0;
    forever #(CYCLE/2) wclk = ~wclk;
end

// Read clock generation
initial begin
    rclk = 0;
    forever #(CYCLE1/2) rclk = ~rclk;
end

// Write reset generation
initial begin
    wrst_n = 1;
    #2;
    wrst_n = 0;
    #(CYCLE*3);
    wrst_n = 1;
end

// Read reset generation
initial begin
    rrst_n = 1;
    #2;
    rrst_n = 0;
    #(CYCLE*3);
    rrst_n = 1;
end

// Random write data generation
always #30 wdata = $random;

// Main stimulus: parallel write and read
initial begin
    winc = 0;
    rinc = 0;
    // Wait for both resets to deassert
    wait(wrst_n && rrst_n);
    #10; // Small delay for clocks to stabilize

    winc = 1;
    rinc = 1;

    // Run for at least 3000ns to observe FULL (given FIFO depth and write>read rate)
    #3000;

    winc = 0;
    rinc = 0;
    #100;
    $finish;
end

// Monitor status flags
always @(posedge wclk) begin
    if (wfull)
        $display("Time %0t: FIFO is FULL!", $time);
    if (almost_full)
        $display("Time %0t: FIFO is ALMOST FULL!", $time);
end

always @(posedge rclk) begin
    if (rempty)
        $display("Time %0t: FIFO is EMPTY!", $time);
    if (almost_empty)
        $display("Time %0t: FIFO is ALMOST EMPTY!", $time);
end

// Optional: Print enables and flags for debug
always @(posedge wclk) begin
    $display("Time %0t: winc=%b, wfull=%b, almost_full=%b", $time, winc, wfull, almost_full);
end
always @(posedge rclk) begin
    $display("Time %0t: rinc=%b, rempty=%b, almost_empty=%b", $time, rinc, rempty, almost_empty);
end

endmodule
