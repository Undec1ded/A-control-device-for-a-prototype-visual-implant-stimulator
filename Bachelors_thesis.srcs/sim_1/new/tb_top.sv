`timescale 1ns / 1ps
module tb_top();

reg CLK = 0;
reg [1 : 0] SW = 2'b00;
reg UART_data = 1;

wire UART_Tx_test;
wire UART_Rx_test;
wire UART_Tx_data;
wire [3 : 0] LEDs;
wire LDAC;
wire SCLK;
wire CS;
wire SDI;

Top tb_top(
.UART_Tx_test(UART_Tx_test),
.UART_Rx_test(UART_Rx_test),
.UART_Rx_data(UART_data),
.UART_Tx_data(UART_Tx_data),
.LEDs(LEDs),
.CLK(CLK),    
.SCLK(SCLK),
.SW(SW),
.LDAC(LDAC),
.CS(CS),
.SDI(SDI)
);
//vl - 16bits start parametrs, 16bits negativ vl, 16bits ziro, 16bits positiv vl, 16bits ziro
reg [89 : 0] test_upload_parametr        = {1'b0 , 8'b01101010, 1'b0 , 8'b00110010, 1'b0  , 8'b10000000 , 1'b0 ,
                                            8'b00101111 , 1'b0 , 8'b0 , 1'b0 , 8'b0 , 1'b0 , 8'b10000000 , 1'b0 ,
                                            8'b00101111 , 1'b0 , 8'b0 , 1'b0 , 8'b0};// b00000001_11110100 - 10000000, 00101111 b00000001_11110100 - 10000000, 00101111
//time - 16bits start parametrs, 16bits negative time, 16bits pause time, 16bits positive time, 16bits init time
reg [89 : 0] test_upload_parametr_time   = {1'b0 , 8'b00101010 , 1'b0 , 8'b10110010 , 1'b0 , 8'b10000000 , 1'b0 , 8'b00001001 ,
                                            1'b0 , 8'b00000000 , 1'b0 , 8'b00100110 , 1'b0 , 8'b10000000 , 1'b0 , 8'b00001001 ,
                                            1'b0 , 8'b10000000 , 1'b0 , 8'b00101111};
//  b00000001_10010000 - 10000000, 00001001 | b00000000_01100100 - 00000000, 00100110 | b00000001_10010000 - 10000000, 00001001 | b00000001_11110100 - 10000000, 00101111
//num - 16bits start parametrs, 16bits relax time , 16bits numpack, 16bits num frames, 16bits ziro
reg [89 : 0] test_upload_parametr_num    = {1'b0 , 8'b10010010 , 1'b0 , 8'b00001010 , 1'b0 , 8'b11000000 , 1'b0 , 8'b00010111 ,
                                            1'b0 , 8'b00000000 , 1'b0 , 8'b01010000 , 1'b0 , 8'b00000000 , 1'b0 , 8'b11000000 ,
                                            1'b0 , 8'b0 , 1'b0 , 8'b0};
//b00000011_11101000 - 11000000, 00010111 | b00000000_00001010 - 00000000, 01010000 | b00000000_00000011 - 00000000, 11000000                                             
//start sim - 16bits start parametrs, 16*4bits ziro
reg [89 : 0] test_upload_parametr_start  = {1'b0 , 8'b11001010, 1'b0 , 8'b00101010, 1'b0 , 8'b0 , 1'b0 ,  8'b0 , 1'b0 , 8'b0 ,
                                            1'b0 , 8'b0 , 1'b0 , 8'b0 , 1'b0 , 8'b0 , 1'b0 , 8'b0 , 1'b0 ,  8'b0};

always#5 CLK = !CLK;
initial begin
    SW = 2'b00;
    UART_data = 1;
    #10;
    
    // Send array of 80 zero bits
    for (int i = 1 ; i <= 10 ; i ++) begin
        repeat (9) begin
            UART_data = 0; // Data bit
            #8680;
        end
        UART_data = 1;
        #8680;
    end
    // Stop bit
    UART_data = 1;
    //1
    #1000000;
    for (int i = 1 ; i <= 10 ; i ++) begin
        repeat (9) begin
            UART_data  = test_upload_parametr[89];
            test_upload_parametr = test_upload_parametr << 1;
            #8680;
        end
        UART_data = 1;
        #8680;
    end   
    //2
    #1000000;
    for (int i = 1 ; i <= 10 ; i ++) begin
        repeat (9) begin
            UART_data  = test_upload_parametr_time[89];
            test_upload_parametr_time = test_upload_parametr_time <<  1;
            #8680;
        end
        UART_data = 1;
        #8680;
    end   
    //3
    #1000000;
    for (int i = 1 ; i <= 10 ; i ++) begin
        repeat (9) begin
            UART_data  = test_upload_parametr_num[89];
            test_upload_parametr_num= test_upload_parametr_num <<  1;
            #8680;
        end
        UART_data = 1;
        #8680;
    end   
    
    #1000000;
     for (int i = 1 ; i <= 10 ; i ++) begin
        repeat (9) begin
            UART_data  = test_upload_parametr_start[89];
            test_upload_parametr_start = test_upload_parametr_start << 1;
            #8680;
        end
        UART_data = 1;
        #8680;
    end   
    SW = 2'b11;
    #1000000;
    // Add more test stimuli as needed
    end
endmodule
