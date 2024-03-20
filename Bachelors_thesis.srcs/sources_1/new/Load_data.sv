`timescale 1ns / 1ps
module Load_data #(
    parametr voltage_amplitude_bits = 14,
    parameter cap_choose_bits = 2
)(
    input clk, [voltage_amplitude_bits - 1 : 0] voltage_amplitude, [cap_choose_bits - 1 : 0] cap_choose,
    output  DATA
);

reg [15 : 0] data_output = 0;
reg [1 : 0] cap_choose_test = 2'b11;
reg [13 : 0] voltage_amplitude_test = 14'b1110000_1110000; 


assign DATA = data_output;

always @(posedge clk) begin
    data_output = {cap_choose_test , voltage_amplitude_test};
end

endmodule