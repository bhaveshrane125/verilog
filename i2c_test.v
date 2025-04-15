module i2c_test (
    clk,
    rst,
    scl,
    sda

);  
    
    input wire clk;
    input wire rst;
    output wire scl;
    output wire sda;


    assign sda = clk;
    assign scl = ~clk;

endmodule