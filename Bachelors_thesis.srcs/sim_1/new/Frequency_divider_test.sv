`timescale 1ns / 1ps
module Frequency_divider_SCLK_test();

reg CLK = 0;

wire SCLK;

Frequency_divider_SCLK Frequency_divider_SCLK_test(
.CLK(CLK),
.SCLK(SCLK)
);

always#5 CLK=!CLK;

endmodule