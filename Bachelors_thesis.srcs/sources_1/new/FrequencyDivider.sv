`timescale 1ns / 1ps
module Frequency_divider_CS #(
    parameter DIVIDER = 2
)(
    input clk, 
    output reg SCLK 
);

reg [25:0] count = 0; 
                      
reg sclk_flag = 0;

assign CS = sclk_flag;

always @(posedge clk) begin
    count <= count + 1; 
    if (count == DIVIDER - 1) begin 
        count <= 0; 
        sclk_flag <= ~sclk_flag; 
    end
end

endmodule
