`timescale 1ns / 1ps
module Load_data #(
    parameter voltage_amplitude_bits = 14,
    parameter cap_choose_bits = 2
)(
    input CLK,// [voltage_amplitude_bits - 1 : 0] VOLTAGE_amplitude_plus,
               //[voltage_amplitude_bits - 1 : 0] VOLTAGE_amplitude_minus,
               //[9 : 0] retention_time_Bt,
               //[9 : 0] retention_time_At,
               //[9 : 0] time_of_the_replicator_pause,
               //[9 : 0] period,
               //[cap_choose_bits - 1 : 0] CAP_choose,
    output  reg [15 : 0] DATA_At, DATA_Bt, DATA_ziro
);

reg [9 : 0] retention_time_Bt_test = 400;
reg [9 : 0] retention_time_At_test = 400;
reg [9 : 0] time_of_the_replicator_pause_test = 10;
reg [9 : 0] period_test = 500;
reg [15 : 0] data_output_At = 0;
reg [15 : 0] data_output_Bt = 0;
reg [15 : 0] data_output_ziro = 0;
reg [1 : 0] cap_choose_test = 2'b10;
reg [13 : 0] voltage_amplitude_At_test = 14'b1101000_0000001; 
reg [13 : 0] voltage_amplitude_Bt_test = 14'b1011000_0000001;
reg [13 : 0] voltage_amplitude_ziro_test = 14'b1100000_0000001;

assign DATA_At = data_output_At;
assign DATA_Bt = data_output_Bt;
assign DATA_ziro = data_output_ziro;

always @(posedge CLK) begin
    data_output_At = {cap_choose_test , voltage_amplitude_At_test};
    data_output_Bt = {cap_choose_test , voltage_amplitude_Bt_test};
    data_output_ziro = {cap_choose_test , voltage_amplitude_ziro_test};
end

endmodule