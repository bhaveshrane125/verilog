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
       output led5
    );
 
    // wire scl;
    // wire sda;
    wire sda_dir;
    wire [767:0] fifo_data;
    wire[5:0] num_samples;
    wire data_ready;
    wire [4:0] debug;
    reg [25:0] counter =0;
    reg c = 0;
    reg d =0;
    reg e = 0;
    wire [7:0] fifo_rd_ptr;
    wire [7:0] fifo_wr_ptr;
    reg clk2 = 0;
    wire [23:0] total_data[0:3749];
    wire [12:0] last_index;
    i2c_master_debug i2c_master(.start(start), .clk(clk2), .reset(reset), .scl(scl), .sda_i(sda_i), .sda_o(sda_o), .interupt(interupt), .sda_dir(sda_dir) , .fifo_data(fifo_data), .num_samples(num_samples), .data_ready(data_ready), .debug(debug), .fifo_rd_ptr(fifo_rd_ptr), .fifo_wr_ptr(fifo_wr_ptr) );
    mem_buffer mem_buffer (.clk(clk2), .reset(reset), .num_samples(num_samples), .fifo_data(fifo_data), .data_ready(data_ready));
    
    assign led1 = debug[0];
//    assign led2 = debug[1];
    assign led3 = debug[2];
    assign led4 = data_ready;
    assign led5 = interupt;   
    assign sda = sda_dir ? sda_o : sda_i;
    assign led2 = (last_index >= 3748) ? 1'b1 : 1'b0;


always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        clk2 <= 0;
    end else begin
        counter <= counter + 1;
        if (counter == 50) begin
            clk2 <= ~clk2;
            counter <= 0;
        end
    end
end


 


endmodule
