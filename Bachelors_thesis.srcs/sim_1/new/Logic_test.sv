`timescale 1ns / 1ps
module tb_Logic_test();

reg SCLK = 0;
reg CLK = 0;
reg SW = 0;
reg TIME_IMPULSE = 0;
reg END_spi;
reg [15 : 0] DATA_IN_At;
reg [15 : 0] DATA_IN_Bt;;

wire LDAC;
wire START_SPI;
wire CS;
wire [15 : 0] DATA_OUT;

Logic Logic_test(
.CLK(CLK),    
.SCLK(SCLK),
.SW(SW),
.TIME_IMPULSE(TIME_IMPULSE),
.END_spi(END_spi),
.DATA_IN_At(DATA_IN_At),
.DATA_IN_Bt(DATA_IN_At),

.LDAC(LDAC),
.START_SPI(START_SPI),
.CS(CS),
.DATA_OUT(DATA_OUT)
);

always#5 CLK = !CLK;
always#10 SCLK = !SCLK;
initial begin
    SW = 0;
    DATA_IN_At = 16'b11_11_1001_0110;
    DATA_IN_Bt = 16'b11_00_0101_0101;
    TIME_IMPULSE = 0;
    END_spi = 1;

    #100
    SW = 1;
    TIME_IMPULSE = 1;
    
end
endmodule