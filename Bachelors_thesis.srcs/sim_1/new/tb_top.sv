`timescale 1ns / 1ps
module tb_top();

reg CLK = 0;
reg [1 : 0] SW = 2'b00;
reg UART_data = 1;

wire UART_Tx_data;
wire [3 : 0] LEDs;
wire LDAC;
wire SCLK;
wire CS;
wire SDI;

Top tb_top(
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
reg [79 : 0] test_upload_parametr        = {16'b01010110_01001100 , 16'b0000000_111110100 , 16'b0, 16'b0000000_111110100 , 16'b0};
//time - 16bits start parametrs, 16bits negative time, 16bits pause time, 16bits positive time, 16bits init time
reg [79 : 0] test_upload_parametr_time   = {16'b01010100_01001101 , 16'b0000000_110010000 , 16'b00000000_01100100 ,
                                            16'b00000001_10010000 , 16'b0000000_111110100};
//num - 16bits start parametrs, 16bits relax time , 16bits numpack, 16bits num frames, 16bits ziro
reg [79 : 0] test_upload_parametr_num    = {16'b01001001_01010000 , 16'b0000001_111101000 , 16'b00000000_00001010 , 
                                            16'b00000000_00000011 , 16'b0};
//start sim - 16bits start parametrs, 16*4bits ziro
reg [79 : 0] test_upload_parametr_start  = {16'b01010011_01010100 , 64'b0};

always#5 CLK = !CLK;
initial begin
    SW = 2'b00;
    UART_data = 1;
    #10;

    // Send array of 80 zero bits
    repeat (80) begin
        UART_data = 0; // Data bit
        #8680;
    end

    // Stop bit
    UART_data = 1;
    #1000000;

    // Add more test stimuli as needed
    for (int i = 1; i <= 80 ; i++) begin
      #8680;
      UART_data  = test_upload_parametr[79];
      test_upload_parametr = test_upload_parametr << 1; 
    end
      #8680;
      UART_data = 1;
#1000000;
      for (int i = 1; i <= 80 ; i++) begin
      #8680;
      UART_data  = test_upload_parametr_time[79];
      test_upload_parametr_time = test_upload_parametr_time << 1; 
    end
      #8680;
      UART_data = 1;
#1000000;
    for (int i = 1; i <= 80 ; i++) begin
      #8680;
      UART_data  = test_upload_parametr_num[79];
      test_upload_parametr_num = test_upload_parametr_num << 1; 
    end
      #8680;
      UART_data = 1;
#1000000;
    for (int i = 1; i <= 80 ; i++) begin
      #8680;
      UART_data  = test_upload_parametr_start[79];
      test_upload_parametr_start = test_upload_parametr_start << 1; 
    end
      #8680;
      UART_data = 1;
#1000000;        
    // End simulation
    #1000000;
    #100
    SW = 2'b11;
    
end

endmodule