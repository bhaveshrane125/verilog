`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2025 22:47:47
// Design Name: 
// Module Name: i2c_master_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// ā
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module i2c_master_tb;

reg clk;
reg reset;
wire scl;
wire sda;
//wire sda_dir;
wire interupt;
wire led1;
wire led2;
wire led3;
reg start;

top dut(.clk(clk), .reset(reset), .start(start), .scl(scl), .sda(sda), .interupt(interupt), .led1(led1), .led2(led2), .led3(led3));

always #1 clk = !clk;

initial begin
    $dumpfile ("testbench.vcd");
    $dumpvars (0,i2c_master_tb);
    clk = 0;
    reset = 0 ;
    start = 1;
    #50000 $finish;    
end

endmodule
