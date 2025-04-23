
module i2c_master_debug(
    input start,
    input clk,
    input reset,
    output scl,
    input sda_i,
    output sda_o, 
    input interupt,
    output sda_dir,
    output reg [767:0]fifo_data,
    output reg [5:0]num_samples,
    inout data_ready,
    output reg [4:0]debug,
    output reg [7:0] fifo_rd_ptr,
    output reg [7:0] fifo_wr_ptr
    // output reg [23:0] total_data[0:3749]

    );

    // reg [4:0] debug;
    reg [3:0] counter = 4'b0;
    reg clk_reg = 1'b0;
    reg temp_data_ready;
    // reg [768:0]fifo_data = 0;
    always @ (posedge clk or posedge reset )
    if (reset) begin
        counter = 4'b0;
        clk_reg = 1'b0;
    end
    else
        if (counter == 9)begin
            counter <= 4'b0;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    assign scl = clk_reg;
    
    
       
    parameter [7:0] sensor_address_read = 8'b10101111;
    parameter [7:0] sensor_address_write= 8'b10101110;
    parameter [7:0] wr_ptr = 8'b00000100;
    parameter [7:0] rd_ptr = 8'b00000110;

// STATES
    localparam [5:0] POWER_UP                    = 6'd0, //
                     START                       = 6'd1, // 14, 23
                     SEND_ADDRESS_WR_INT         = 6'd34,
                     REC_ACK_WR_INT              = 6'd35,
                     SEND_INT_PTR                = 6'd38,
                     REC_ACK_INT_PTR             = 6'd39,
                     REPEATED_START5             = 6'd40,
                     SEND_ADDRESS_RD_INT         = 6'd41,
                     REC_ACK_RD_INT              = 6'd42,
                     READ_RD_INT                 = 6'd36,
                     SEND_NACK_RD_INT             = 6'd37,
                     REPEATED_START6             = 6'd43,
                     SEND_ADDRESS_WR_WR          = 6'd2, // 24, 184
                     REC_ACK_WR_WR               = 6'd3, // 184, 203
                     SEND_WR_PTR                 = 6'd4,// 204, 364
                     REC_ACK_WR_PTR              = 6'd5, // 364, 384(1)
                     REPEATED_START1             = 6'd6,//  394(0) 403
                     SEND_ADDRESS_RD_WR          = 6'd7,//  404 564
                     REC_ACK_RD_WR               = 6'd8,//  564 584
                     READ_WR_PTR                 = 6'd9,//  584 744
                     SEND_ACK_WR_PTR             = 6'd10,// 744 764(1)
                     START_RD_PTR                = 6'd11,// 774(0) 784
                     SEND_ADDRESS_WR_RD          = 6'd12,// 784 944
                     REC_ACK_WR_RD               = 6'd13,// 944 964
                     SEND_RD_PTR                 = 6'd14,// 964 1124
                     REC_ACK_RD_PTR              = 6'd15,// 1124 1144(1)
                     REPEATED_START2             = 6'd16,// 1154(0) 1164
                     SEND_ADDRESS_RD_RD          = 6'd17,// 1164 1324
                     REC_ACK_RD_RD               = 6'd18,// 1324 1344
                     READ_RD_PTR                 = 6'd19,// 1344 1504
                     SEND_ACK_RD_PTR             = 6'd20,// 1504 1524(1)
                     REPEATED_START3             = 6'd21,// 1534(0) 1544
                     SEND_ADDRESS_WR_FIFO        = 6'd22,// 1544 1704
                     REC_ACK_WR_FIFO             = 6'd23,// 1704 1724
                     SEND_FIFO_PTR               = 6'd24,// 1724 1884
                    REC_ACK_FIFO_PTR             = 6'd25,// 1884 1904(1)
                     REPEATED_START4             = 6'd26,// 1914(0) 1924
                    SEND_ADDRESS_RD_FIFO         = 6'd27,// 1924 2084
                    REC_ACK_RD_FIFO              = 6'd28,// 2084 2104
                     START_FIFO_LOOP             = 6'd29,// 2104
                     SEND_AM                     = 6'd30,
                     SEND_NACK                   = 6'd31,
                     REC_NACK                    = 6'd32,
                     STOP                        = 6'd33;
                     
                     




    reg[13:0] count =  14'd2000;
    reg [5:0] state_reg = POWER_UP;
                        
    reg [13:0] timing = 14'd2000;
    reg [13:0] t_timing = 14'd2000;
    integer i;
    integer j;
    reg o_bit = 1'b1;
    // reg i_bit = 1'b0;

    //  reg [5:0] num_samples = 5'b0;
    reg [23 : 0] r_data   = 24'b0;
    reg [5:0] t_num_samples = 5'b0;
    // reg [24:0] fifo_data [31:0];
    reg [7:0] int_ptr = 8'b0;
    always @(posedge clk or  posedge reset) begin
        
        if (reset) begin
            state_reg <= START;
            count <= 14'd2000;
            temp_data_ready <= 0;
            fifo_data <= 0;

        end
        else if (start) begin
            count <= count + 1;
            debug[4] <= interupt;
            
            case(state_reg) 
                POWER_UP : begin
                    if (start) begin
                        state_reg <= START; 
                    end
                end
                 START : begin
                    
                    if (count == 14'd2014)begin
                        o_bit <= 1'b0;
                        fifo_data <= 0;

                    end
                    if (count == 14'd2023)begin
                        state_reg <= SEND_ADDRESS_WR_INT;
                        timing <= 14'd2024;
                        t_timing <= 14'd2024;
                        i <= 7;
                    end
                 end
                 
                 SEND_ADDRESS_WR_INT : begin 
                    if (count == t_timing) begin 
                        if (i>-1) begin 
                            o_bit <= sensor_address_write[i];
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_WR_INT;
                        timing <= count + 1;
                    end
                 end
                 
                 REC_ACK_WR_INT : begin 
                 
                    if (count == timing + 19) begin 
                        state_reg <= SEND_INT_PTR;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i <= 7;
                        
                    end
                 end
                 
                 SEND_INT_PTR : begin 
                    if (count == t_timing) begin 
                        if (i > -1) begin 
                            o_bit <= int_ptr[i];
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end
                    end                 
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_INT_PTR;
                        timing <= count + 1;
                    end
                end
                
                REC_ACK_INT_PTR : begin 
                    
                    
                    if (count == timing + 19) begin 
                        state_reg <= REPEATED_START5;
                        timing <= count + 1;
                        o_bit <= 1;
                    end
                end
                
                REPEATED_START5 : begin 
                    if (count == timing + 10) begin 
                        o_bit <= 0;
                    end
                    
                    if (count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_RD_INT;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i <= 7;
                    end
                end
                
                SEND_ADDRESS_RD_INT : begin 
                
                    if ( count == t_timing) begin 
                        if (i > -1) begin 
                            o_bit <= sensor_address_read[i];        
                            i = i-1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_RD_INT;
                        timing <= count + 1;
                    end
                    
                end
                
                REC_ACK_RD_INT : begin 
             // NEXT       
                    if (count == timing + 19) begin
                        state_reg <= READ_RD_INT;
                        timing <= count + 1;
                        t_timing <= count + 1;
                    end
                end
                 
                 READ_RD_INT : begin 
                    if (count  == t_timing) begin 
                    
                        if (i > -1) begin
                            if (i_bit == 1)
                                debug[3]=1;
                            if (i_bit == 0)
                                debug[2] = 1;
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= SEND_NACK_RD_INT;
                        timing <= count +1 ;
                        o_bit <= 1;
                    end
                    
                 end
                 
                 SEND_NACK_RD_INT : begin  
                    if (count == timing) begin
                        o_bit <= 1;                    
                    end
                    
                    if (count == timing + 20) begin 
                        state_reg <= REPEATED_START6;
                        timing <= count + 1;
                        o_bit <= 1;
                    end
                    
                 end
                 
                 REPEATED_START6 : begin 
                    if ( count == timing + 10) begin 
                           o_bit <= 0;
                    end 
                    if (count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_WR_WR;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i<= 7;
                        
                    end
                 end
                 
                 SEND_ADDRESS_WR_WR : begin 
                    if (count == t_timing) begin 
                        if (i > -1) begin
                            o_bit <= sensor_address_write[i];
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end                
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_WR_WR;
                        timing <= count + 1 ;
                    end
                 end
                 
                 REC_ACK_WR_WR : begin 
                    
                    
                    if (count == timing + 19) begin 
                        state_reg <= SEND_WR_PTR;
                        i <= 7;
                        timing <= count + 1;
                        t_timing <= count +1;
                    end
                 end
                 
                 SEND_WR_PTR : begin 
                    if (count == t_timing ) begin 
                        if (i > -1) begin 
                            o_bit <= wr_ptr[i];
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159 ) begin 
                         state_reg <= REC_ACK_WR_PTR;
                         timing <= count + 1;
                    end 
                 end
                 
                 REC_ACK_WR_PTR : begin 
                    
                    
                    if (count == timing + 19) begin 
                        state_reg <= REPEATED_START1;
                        timing <= count + 1;
                        o_bit <= 1;
                    end
                 end
                 
                 REPEATED_START1 : begin 
                    if (count == timing + 10) begin 
                        o_bit <= 0;
                    end
                    if(count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_RD_WR;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i <= 7;
                    end
                 end
             
                SEND_ADDRESS_RD_WR : begin 
                    if (count == t_timing) begin 
                        if (i > -1) begin 
                            o_bit <= sensor_address_read[i];
                            i = i - 1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_RD_WR;
                        timing <= count + 1;
                    end
                end
                
                REC_ACK_RD_WR : begin 

                    if (count == timing + 19) begin 
                        state_reg  <= READ_WR_PTR;
                        i<= 7;
                        timing <= count + 1;
                        t_timing <= count + 1;
                    end
                end
                
                READ_WR_PTR : begin 
                    if (count == t_timing) begin 
                        if( i> -1) begin 
                            fifo_rd_ptr[i] <= i_bit;
                            
                            i = i-1;
                            t_timing = t_timing + 20;
                        end
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= SEND_ACK_WR_PTR;
                        timing <= count + 1;
                    end
                end
                
                SEND_ACK_WR_PTR : begin 
                    if (count == timing) begin 
                        o_bit <= 1;
                    end
                    if (count == timing + 19) begin 
                        state_reg <= START_RD_PTR;
                        o_bit <= 0;
                        timing <= count + 1;
                    end
                end
                START_RD_PTR : begin 
                    if (count == timing + 10) begin 
                        o_bit <= 1;
                    end
                    if (count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_WR_RD;
                        i <= 7;
                        timing <= count + 1;
                        t_timing <= count + 1;
                    end
                end
                
                SEND_ADDRESS_WR_RD : begin 
                    if (count == t_timing ) begin 
                        o_bit <= sensor_address_read[i];
                        i = i - 1;
                        t_timing = t_timing + 20;
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_WR_RD;
                        timing <= count + 1;
                    end
                end
                
                REC_ACK_WR_RD : begin 
                    if (count == timing + 19) begin 
                        state_reg <= SEND_RD_PTR;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i<= 7;
                        
                    end
                end
                
                SEND_RD_PTR : begin 
                    if (count == t_timing) begin 
                        o_bit <= rd_ptr[i];
                        i = i - 1;
                        t_timing = t_timing + 20;
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_RD_PTR;
                        timing <= count + 1;
                    end
                end
                
                REC_ACK_RD_PTR : begin 
                    if (count == timing + 19) begin 
                        state_reg <= REPEATED_START2;
                        timing <= count + 1;
                        o_bit <= 1;
                    end
                end
                
                REPEATED_START2 : begin
                    if (count == timing + 10) begin 
                        o_bit <= 0;
                    end
                    
                    if (count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_RD_RD;
                        timing <= count +1 ;
                        t_timing <= count + 1;
                        i <= 7;
                    end
                    
                end
                
                SEND_ADDRESS_RD_RD : begin 
                    if (count == t_timing) begin 
                        o_bit <= sensor_address_read[i];
                        i = i -1;
                        t_timing = t_timing + 20;
                    end
                    
                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_RD_RD;
                        timing <= count + 1;
                    end
                end
                
                REC_ACK_RD_RD : begin 
                    if (count == timing + 19) begin 
                        state_reg <= READ_RD_PTR;
                        i <= 7;
                        timing <= count + 1;
                        t_timing <= count + 1;
                    end
                end
                
                READ_RD_PTR : begin
                    if (count == t_timing) begin 
                        fifo_rd_ptr[i] <= i_bit;
                        i = i -1;
                        t_timing = t_timing + 20;
                    end
                    
                    if (count == timing +159) begin 
                        state_reg <= SEND_ACK_RD_PTR;
                        timing <= count + 1;
                        
                    end
                end
                
                SEND_ACK_RD_PTR : begin
                    if (count == timing + 19) begin 
                        state_reg <= REPEATED_START3;
                        timing <= count + 1;
                        o_bit  <= 1;
                    end
                end
                
                REPEATED_START3 : begin 
                    if (count == timing + 10) begin  
                          o_bit<= 0;
                    end
                    if (count == timing + 19) begin
                        state_reg <= SEND_ADDRESS_WR_FIFO;
                        t_timing <= count +1 ;
                        timing <= count +1;
                        i <= 7;
                    end
                end
                
                SEND_ADDRESS_WR_FIFO : begin 
                    if (count == t_timing) begin 
                        o_bit <= sensor_address_write[i];
                        i = i -1;
                        t_timing = t_timing + 20;
                    end
                    if (count == timing + 159) begin  
                        state_reg <= REC_ACK_WR_FIFO;
                        timing <= count + 1;
                    end 
                end
                
                REC_ACK_WR_FIFO : begin 
                    if (count == timing + 19) begin 
                        state_reg <= SEND_FIFO_PTR;
                        timing <= count +1;
                        t_timing <= count + 1;
                        i <=  7; 
                    end
                end
                SEND_FIFO_PTR : begin  
                      if (count == t_timing ) begin 
                        o_bit <= fifo_rd_ptr[i];
                        i = i - 1;
                        t_timing = t_timing + 20;
                      end
                      if (count == timing + 159) begin 
                          state_reg <= REC_ACK_FIFO_PTR;
                          timing <= count + 1;
                      end
                end
                REC_ACK_FIFO_PTR : begin 
                    if (count == timing + 19) begin 
                        state_reg <= REPEATED_START4;
                        timing <= count +1;
                        o_bit <= 1;
                    end
                end
                
                REPEATED_START4 : begin 
                    if (count == timing + 10) begin 
                        o_bit <= 0;
                    end
                    if (count == timing + 19) begin 
                        state_reg <= SEND_ADDRESS_RD_FIFO;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i<=7;
                    end
                end
                SEND_ADDRESS_RD_FIFO : begin 
                    if (count == t_timing ) begin
                        o_bit <= sensor_address_read[i];
                        i = i-1;
                        t_timing <= t_timing + 20;
                    end

                    if (count == timing + 159) begin 
                        state_reg <= REC_ACK_RD_FIFO;
                        timing <= count + 1;

                    end

                end

                REC_ACK_RD_FIFO : begin 
                    if (count == timing + 19) begin 
                        state_reg <= START_FIFO_LOOP;
                        t_timing <= count + 1;
                        timing <= count + 1;
                        i = 23;
                        // t_num_samples <= fifo_wr_ptr - fifo_rd_ptr;
                        // num_samples <= fifo_wr_ptr - fifo_rd_ptr;
                        t_num_samples <= rd_ptr - wr_ptr;
                        num_samples <= rd_ptr - wr_ptr;
                        j = 767;
                        fifo_data <= 24'd0;
                        temp_data_ready <= 0;

                    end

                end
                
                START_FIFO_LOOP : begin 
                    if (t_num_samples < 1) begin
                            state_reg <= REC_NACK;
                    end
                    else begin
                        if (count == t_timing ) begin
                            if (i >= 0) begin
                                // r_data[i] <= i_bit;
                                fifo_data[j] <= 1;
                                // fifo_data = fifo_data + 1;
                                r_data = r_data + 1;
                                i = i - 1;
                                j = j - 1;
                                t_timing = t_timing + 20;
                            end
                        end
                        if (count == timing + 159) begin
                            // i = 7;
                            if (i > -1) begin
                                state_reg <= SEND_AM;
                                timing <= count + 1;
                            end
                            else if (i < 0) begin
                                state_reg <= SEND_NACK;
                                timing <= count + 1;
                            end

                        end
                    end

                end

                SEND_AM : begin 
                    if (count == timing) begin
                        o_bit <= 0;
                    end
                    if (count == timing + 19) begin 
                        state_reg <= START_FIFO_LOOP;
                        timing <= count + 1;
                        t_timing <= count + 1;

                    end
                    
                end

                SEND_NACK : begin 
                    if(count == timing && t_num_samples > 1) begin 
                            o_bit <= 0;

                    end
                    if (count == timing && t_num_samples == 1) begin 
                        state_reg <= REC_NACK;
                        timing <= count + 1;
                    end

                    if (count == timing + 19 && t_num_samples > 1) begin 
                        state_reg <= START_FIFO_LOOP;
                        t_num_samples <= t_num_samples - 1;
                        timing <= count + 1;
                        t_timing <= count + 1;
                        i <= 23;

                    end

                end
                
                REC_NACK : begin
                   
                    if (count == timing+17) begin
                        state_reg <= STOP;
                        timing <= count+1;
                        o_bit <= 0;
                        temp_data_ready <= 1;
                        
                    end
                end

                
                 
                 STOP: begin 
                    if (count == timing + 10) begin 
                        o_bit <= 1;
                    end
                    // $monitor("fifo_we_ptr : %d",fifo_wr_ptr);
                    if(count == timing + 19) begin 
                        state_reg <= REPEATED_START6;
                        timing <= count + 1;
                        count <= 14'd2000;
                        timing <= 12'd2001;
                        
                    end
                 end


            endcase
            
        end
    end 

    
    assign sda_dir = (state_reg == POWER_UP || 
                  state_reg == START ||
                  state_reg == SEND_ADDRESS_WR_INT ||
                  state_reg == SEND_INT_PTR ||
                  state_reg == REPEATED_START5 ||
                  state_reg == REPEATED_START6 ||
                  state_reg == SEND_ADDRESS_RD_INT ||
                  
                  state_reg == SEND_NACK_RD_INT ||
                  state_reg == SEND_ADDRESS_WR_WR ||
                  state_reg == SEND_WR_PTR ||
                  state_reg == REPEATED_START1 || 
                  state_reg == SEND_ADDRESS_RD_WR ||
                  state_reg == SEND_ACK_WR_PTR ||
                  state_reg == START_RD_PTR ||
                  state_reg == SEND_ADDRESS_WR_RD ||
                  state_reg == SEND_RD_PTR ||
                  state_reg == REPEATED_START2 ||
                  state_reg == SEND_RD_PTR ||
                  state_reg == REPEATED_START2 ||
                  state_reg == SEND_ADDRESS_RD_RD ||
                  state_reg == SEND_ACK_RD_PTR ||
                  state_reg == REPEATED_START3 ||
                  state_reg == SEND_ADDRESS_WR_FIFO ||
                  state_reg == SEND_FIFO_PTR ||
                  state_reg == REPEATED_START4 ||
                  state_reg == SEND_ADDRESS_RD_FIFO ||
                  state_reg == SEND_AM ||
                  state_reg == SEND_NACK ||
                  state_reg == STOP) ? 1 : 0;


    assign sda_o = sda_dir ? o_bit : 1'bz;
    assign i_bit = sda_i;
    assign data_ready = temp_data_ready;


    // always @(posedge scl) begin
    //     $monitor ("I : %d", j);
    // end
endmodule