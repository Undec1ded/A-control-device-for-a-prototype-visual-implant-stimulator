`timescale 1ns / 1ps
module Load_data #(
    parameter voltage_amplitude_bits = 14,
    parameter cap_choose_bits = 2
)(
    input CLK,  logic PACKETS_download, 
                logic [79 : 0] DATA_Vl, DATA_Tm, DATA_Ip,
    output  logic [15 : 0] DATA_At_first_channel, DATA_Bt_first_channel, DATA_ziro_first_channel,
            logic [15 : 0] DATA_Bt_second_channel, DATA_ziro_second_channel,
            logic [15 : 0] DATA_At_second_channel, DATA_time_first_pulse, DATA_time_second_pulse,
            logic [15 : 0] DATA_time_third_pulse, DATA_time_fourth_pulse, DATA_time_relax,
            logic [15 : 0] DATA_num_pack, DATA_num_of_frames
);

localparam data_size = 79;

reg [15 : 0] data_output_At_first_channel   = 0;
reg [15 : 0] data_output_Bt_first_channel   = 0;
reg [15 : 0] data_output_ziro_first_channel = 0;

reg [15 : 0] data_output_At_second_channel   = 0;
reg [15 : 0] data_output_Bt_second_channel   = 0;
reg [15 : 0] data_output_ziro_second_channel = 0;

reg [15 : 0] time_first_pulse  = 0;
reg [15 : 0] time_second_pulse = 0;
reg [15 : 0] time_third_pulse  = 0;
reg [15 : 0] time_fourth_pulse = 0;

reg [15 : 0] time_relax    = 0;
reg [15 : 0] num_pack      = 0;
reg [15 : 0] num_of_frames = 0;

reg [1 : 0] cap_choose_first_channel = 2'b11;
reg [1 : 0] cap_choose_second_channel = 2'b10;
reg [13 : 0] voltage_amplitude_ziro = 14'b1000000_0000000;


assign DATA_At_first_channel = data_output_At_first_channel;
assign DATA_Bt_first_channel = data_output_Bt_first_channel;
assign DATA_ziro_first_channel = data_output_ziro_first_channel;

assign DATA_At_second_channel = data_output_At_second_channel;
assign DATA_Bt_second_channel = data_output_Bt_second_channel;
assign DATA_ziro_second_channel = data_output_ziro_second_channel;

assign DATA_time_first_pulse = time_first_pulse;
assign DATA_time_second_pulse = time_second_pulse;
assign DATA_time_third_pulse = time_third_pulse;
assign DATA_time_fourth_pulse = time_fourth_pulse;
assign DATA_time_relax = time_relax;

assign DATA_num_pack = num_pack;
assign DATA_num_of_frames = num_of_frames;

always @(posedge CLK) begin
    if (PACKETS_download != 0) begin
        data_output_At_first_channel    = {cap_choose_first_channel  , DATA_Vl[data_size - 18 : data_size - 31]};
        data_output_At_second_channel   = {cap_choose_second_channel , DATA_Vl[data_size - 18 : data_size - 31]};
        data_output_Bt_first_channel    = {cap_choose_first_channel  , DATA_Vl[data_size - 50 : data_size - 63]};
        data_output_Bt_second_channel   = {cap_choose_second_channel , DATA_Vl[data_size - 50 : data_size - 63]};
        data_output_ziro_first_channel  = {cap_choose_first_channel  , voltage_amplitude_ziro};
        data_output_ziro_second_channel = {cap_choose_second_channel , voltage_amplitude_ziro};

        time_first_pulse  = DATA_Tm[data_size - 16 : data_size - 31];
        time_second_pulse = DATA_Tm[data_size - 32 : data_size - 47];
        time_third_pulse  = DATA_Tm[data_size - 48 : data_size - 63];
        time_fourth_pulse = DATA_Tm[data_size - 64 : data_size - 79];

        time_relax    = DATA_Ip[data_size - 16 : data_size - 31];
        num_pack      = DATA_Ip[data_size - 32 : data_size - 47];
        num_of_frames = DATA_Ip[data_size - 48 : data_size - 63];
    end
    else begin
        data_output_At_first_channel  = 0;
        data_output_At_second_channel = 0;
        data_output_Bt_first_channel  = 0;
        data_output_Bt_second_channel = 0;

        time_first_pulse  = 0;
        time_second_pulse = 0;
        time_third_pulse  = 0;
        time_fourth_pulse = 0;

        time_relax    = 0;
        num_pack      = 0;
        num_of_frames = 0;        
    end
end

endmodule