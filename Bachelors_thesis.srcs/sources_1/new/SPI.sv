`timescale 1ns / 1ps
module SPI#(
    parameter data_hier_bit = 16
)(
    input [data_hier_bit - 1 : 0] DATA, CS, SDI_flag,

    output SDI, END_spi
);

reg SDI_transfer = 0;
reg [4 : 0] 16bits_counter = 0;
reg [data_hier_bit - 1 : 0] data_amplitude;
reg counter_flag = 0;
reg END_spi = 0;

assign SDI = SDI_transfer;
assign END_spi = counter_flag;

always @(SCLK) begin
    if (SDI_flag == 0) begin
        data_amplitude = DATA;
        16bits_counter = 0;
    end
    else begin
        if (16bits_counter != 16) begin
            16bits_counter = 16bits_counter + 1;
            counter_flag = 0;
        end
        else begin
            16bits_counter = 0;
            counter_flag = 1;
        end
        SDI_transfer = data_amplitude[data_hier_bit - 1];
        data_amplitude = data_amplitude << 1;
    end
end

endmodule
