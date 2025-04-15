`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2025 15:23:43
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
       input clk,
       input reset,
       input start,
       output scl,
       inout sda,
       input interupt,
       output led1,
       output led2,
       output led3,
       output led4,
       output red_clock
    );
 
//    wire scl;
//    wire sda;
    wire sda_dir;
    wire [768:0] fifo_data;
    wire[5:0] num_samples;
    wire data_ready;
    wire debug;
    reg [25:0] counter =0;
    reg c = 0;
    i2c_master i2c_master(.start(start), .clk(clk), .reset(reset), .scl(scl), .sda(sda), .sda_dir(sda_dir) , .fifo_data(fifo_data), .num_samples(num_samples), .data_ready(data_ready), .debug(debug));
    
    assign led1 = data_ready;
    assign led2 = sda_dir;
    assign led4 = debug;    
    always @(posedge scl) begin
        counter <= counter + 1;
        if (counter == 10000000) 
         c <= 1;
        if (counter == 20000000) begin
            c <= 0;
            counter <= 0;
        end
    end
    assign led3 = c;
    assign red_clock = scl;
endmodule
