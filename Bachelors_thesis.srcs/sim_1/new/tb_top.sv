`timescale 1ns / 1ps
module tb_top();

reg CLK = 0;
reg [1 : 0] SW = 2'b00;

wire LDAC;
wire SCLK;
wire CS;
wire SDI;

Top tb_top(
.CLK(CLK),    
.SCLK(SCLK),
.SW(SW),
.LDAC(LDAC),
.CS(CS),
.SDI(SDI)
);

always#5 CLK = !CLK;
initial begin
    SW = 2'b00;
    #100
    SW = 2'b11;
    
end

endmodule