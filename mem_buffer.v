`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2025 13:28:03
// Design Name: 
// Module Name: mem_buffer
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


module mem_buffer(
    input clk,
    input reset,
    input [5:0] num_samples,
    input [767:0] fifo_data,
    input data_ready
    );


    reg [23:0]mem_buffer[0:3749];
    integer i;
    reg [12:0] last_index = 0;
    reg done_flag = 0;
    reg [23:0] temp_sample;
    integer bit_index;
    always @(posedge clk or posedge reset) begin 
        if (reset) begin 
            for (i = 0; i < 3750; i = i + 1)
                mem_buffer[i] <= 24'd0;
        end else if (data_ready) begin 
            for (i = 0; i < num_samples; i = i + 1) begin 
                
                bit_index = 767 - 24*i;
                if (bit_index >= 23)
                    temp_sample = fifo_data[bit_index -: 24];
                
//                temp_sample = fifo_data[(767 - 24*i - 1) -: 24];
                mem_buffer[last_index + i] = temp_sample[23:0];
            end
            if (i == num_samples) begin 
                last_index <= last_index + num_samples;
                i = 0;
            end
        end
    end
endmodule
