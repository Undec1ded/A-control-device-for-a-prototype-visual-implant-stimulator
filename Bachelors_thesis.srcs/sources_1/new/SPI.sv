`timescale 1ns / 1ps
module SPI#(
    parameter data_hier_bit = 16
)(
    input [data_hier_bit - 1 : 0] DATA, CS, SDI_flag,

    output SDI
);

reg SDI_transfer = 0;

reg [data_hier_bit - 1 : 0] data_amplitude;

assign SDI = SDI_transfer;

always @(posedge CS) begin
    if (SDI_flag == 0) begin
        data_amplitude = DATA;
    end
    else begin
        SDI_transfer = data_amplitude[data_hier_bit - 1];
        data_amplitude = data_amplitude << 1;
    end
end

endmodule
