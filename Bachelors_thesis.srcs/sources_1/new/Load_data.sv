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
    output  logic [15 : 0] DATA_At_first_channel, DATA_Bt_first_channel, DATA_ziro_first_channel, DATA_At_second_channel,
            logic [15 : 0] DATA_Bt_second_channel, DATA_ziro_second_channel 
);

reg [9 : 0] retention_time_Bt_test = 400;
reg [9 : 0] retention_time_At_test = 400;
reg [9 : 0] time_of_the_replicator_pause_test = 10;
reg [9 : 0] period_test = 500;

reg [15 : 0] data_output_At_first_channel = 0;
reg [15 : 0] data_output_Bt_first_channel = 0;
reg [15 : 0] data_output_ziro_first_channel = 0;

reg [15 : 0] data_output_At_second_channel = 0;
reg [15 : 0] data_output_Bt_second_channel = 0;
reg [15 : 0] data_output_ziro_second_channel = 0;

reg [1 : 0] cap_choose_first_channel_test = 2'b11;
reg [13 : 0] voltage_amplitude_At_first_channel_test   = 14'b0100000_0000000; 
reg [13 : 0] voltage_amplitude_Bt_first_channel_test   = 14'b1100000_0000000;
reg [13 : 0] voltage_amplitude_ziro_first_channel_test = 14'b1000000_0000000;

reg [1 : 0] cap_choose_second_channel_test = 2'b10;
reg [13 : 0] voltage_amplitude_At_second_channel_test   = 14'b0100000_0000000; 
reg [13 : 0] voltage_amplitude_Bt_second_channel_test   = 14'b1100000_0000000;
reg [13 : 0] voltage_amplitude_ziro_second_channel_test = 14'b1000000_0000000;


assign DATA_At_first_channel = data_output_At_first_channel;
assign DATA_Bt_first_channel = data_output_Bt_first_channel;
assign DATA_ziro_first_channel = data_output_ziro_first_channel;

assign DATA_At_second_channel = data_output_At_second_channel;
assign DATA_Bt_second_channel = data_output_Bt_second_channel;
assign DATA_ziro_second_channel = data_output_ziro_second_channel;

always @(posedge CLK) begin
    data_output_At_first_channel = {cap_choose_first_channel_test , voltage_amplitude_At_first_channel_test};
    data_output_Bt_first_channel = {cap_choose_first_channel_test , voltage_amplitude_Bt_first_channel_test};
    data_output_ziro_first_channel = {cap_choose_first_channel_test , voltage_amplitude_ziro_first_channel_test};

    data_output_At_second_channel = {cap_choose_second_channel_test , voltage_amplitude_At_second_channel_test};
    data_output_Bt_second_channel = {cap_choose_second_channel_test , voltage_amplitude_Bt_second_channel_test};
    data_output_ziro_second_channel = {cap_choose_second_channel_test , voltage_amplitude_ziro_second_channel_test};
end

endmodule