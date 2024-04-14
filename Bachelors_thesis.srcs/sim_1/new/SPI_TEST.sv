`timescale 1ns / 1ps
module SPI_test();

reg SCLK = 0;
reg [15 : 0] DATA = 0;
reg SDI_flag = 0;

wire SDI;
wire END_spi;

SPI SPI_test(
.SCLK(SCLK),
.DATA(DATA),
.SDI_flag(SDI_flag),
.SDI(SDI),
.END_spi(END_spi)
);

always#10 SCLK=!SCLK;
initial begin
    SDI_flag = 0;
    #100;
    DATA = 16'b1100_1100_1100_1101;
    #500;
    SDI_flag = 1;
    #200;
    SDI_flag = 0;
end
endmodule