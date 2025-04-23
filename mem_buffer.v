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
    inout data_ready


    );


    // output reg acquired = 0;
    // reg [23:0]mem_buffer[0:3749];
    reg [89999:0]mem_buffer = 0;
    integer i = 767;
    reg [23:0] last_index = 23'd89999;
    reg done_flag = 0;
    reg [23:0] temp_sample;
    integer bit_index;
    reg [23:0] temp;
    reg acquired = 0;
    always @(posedge clk or posedge reset) begin 
        if (reset) begin 
            for (i = 0; i < 3750; i = i + 1)
                mem_buffer[i] <= 24'd0;

        end
        else if (data_ready && ~acquired) begin 
            

            if (last_index >= 0 && i >= 767-num_samples*24 && ~done_flag) begin 
                mem_buffer[last_index] = fifo_data[i];
                if (mem_buffer[last_index] == 0)
                    $monitor("test : %d", last_index);
                last_index = last_index - 1;
                i = i - 1;

                if (i <= 767-num_samples*24) begin 
                    done_flag <= 1;
                end
            
                
            end
            if(last_index < 0) begin 
                acquired <= 1;
                done_flag <= 1;
                
            end
            

        end

    end

    always @(posedge data_ready) begin
        i<=767;
        done_flag <= 0;
    end
    
    // assign data_ready = ~done_flag;
endmodule 
