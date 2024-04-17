`timescale 1ns / 1ps
module SPI#(
    parameter data_hier_bit = 16
)(
    input SCLK, SDI_flag, [data_hier_bit - 1 : 0] DATA, 

    output SDI, logic END_spi,
                logic [4 : 0] BITS_COUNTER_SPI,
                logic CS
);

reg SDI_transfer = 0;
reg [4 : 0] bits_counter_16 = 0;
reg [data_hier_bit - 1 : 0] data_amplitude = 0;
reg counter_flag = 1;
reg cs_flag = 1;

assign SDI = SDI_transfer;
assign END_spi = counter_flag;
assign BITS_COUNTER_SPI = bits_counter_16;
assign CS = cs_flag;

always @(posedge SCLK) begin
    if (SDI_flag == 0) begin
        data_amplitude <= DATA; 
        bits_counter_16 <= 0;
        counter_flag <= 1;
        cs_flag <= 1;
    end
    else begin
        if (bits_counter_16 != 16) begin
            bits_counter_16 <= bits_counter_16 + 1;
            counter_flag <= 0;
            cs_flag <= 0;
            SDI_transfer <= data_amplitude[data_hier_bit - 1];
            data_amplitude = data_amplitude << 1;
        end
        else begin
            bits_counter_16 <= 0;
            counter_flag <= 1;
            cs_flag <= 1;
        end
    end
end

endmodule
