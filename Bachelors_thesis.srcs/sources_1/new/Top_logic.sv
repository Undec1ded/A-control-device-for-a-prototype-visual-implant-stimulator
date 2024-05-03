`timescale 1ns / 1ps
module Top( 
    input logic CLK, UART_Rx_data, 
                logic [1 : 0] SW,
    output logic SCLK, SDI, CS, LDAC, UART_Tx_data,
                logic [3 : 0] LEDs
    );

//UART_Rx_data paramaters
wire start_bit_wire;
wire uart_tx_wire;
wire pakets_download_wire;
wire [79 : 0] data_time_wire;
wire [79 : 0] data_amplitude_wire;
wire [79 : 0] data_num_wire;

//Frequency_divider_SCLK parametrs
wire sclk_wire;

//Load_data parametrs
wire [15 : 0] data_At_wire_first_channel;
wire [15 : 0] data_Bt_wire_first_channel;
wire [15 : 0] data_ziro_wire_first_channel;

wire [15 : 0] data_At_wire_second_channel;
wire [15 : 0] data_Bt_wire_second_channel;
wire [15 : 0] data_ziro_wire_second_channel;

wire [15 : 0] time_first_pulse_wire;
wire [15 : 0] time_second_pulse_wire;
wire [15 : 0] time_third_pulse_wire;
wire [15 : 0] time_fourth_pulse_wire;
wire [15 : 0] time_relax_wire;
wire [15 : 0] num_pack_wire;
wire [15 : 0] num_of_frames_wire;


//Logic parametrs
wire start_sdi_wire;
wire [15 : 0] data_out_wire;

//Generate_impulse parametrs
wire [3 : 0] pulse_resolution_wire;
wire pulse_end_wire;

//SPI parametrs
wire end_spi_flag;
wire [4 : 0] bits_counter_spi_wire;

assign SCLK = sclk_wire;

UART_load_data UART_load_data(
    //input
    .CLK(CLK), .UART_data(UART_Rx_data), .PULSE_END(pulse_end_wire),
    //output
    .LEDs(LEDs[1 : 0]), .START(start_bit_wire), .UART_Tx(UART_Tx_data), .DATA_time(data_time_wire),
    .DATA_amplitude(data_amplitude_wire), . DATA_num(data_num_wire), .PACKETS_download(pakets_download_wire));

Frequency_divider_SCLK frequency_divider_SCLK(
    .CLK(CLK),
    //output
    .SCLK(sclk_wire));
Load_data Load_data (
    //input
    .CLK(CLK), .DATA_Vl(data_amplitude_wire),.DATA_Tm(data_time_wire), .DATA_Ip(data_num_wire), .PACKETS_download(pakets_download_wire),
    //output
    .DATA_At_first_channel(data_At_wire_first_channel), .DATA_Bt_first_channel(data_Bt_wire_first_channel),
    .DATA_ziro_first_channel(data_ziro_wire_first_channel), .DATA_At_second_channel(data_At_wire_second_channel),
    .DATA_Bt_second_channel(data_Bt_wire_second_channel), .DATA_ziro_second_channel(data_ziro_wire_second_channel),
    .DATA_time_first_pulse(time_first_pulse_wire), .DATA_time_second_pulse(time_second_pulse_wire),
    .DATA_time_third_pulse(time_third_pulse_wire), .DATA_time_fourth_pulse(time_fourth_pulse_wire), 
    .DATA_time_relax(time_relax_wire), .DATA_num_pack(num_pack_wire), .DATA_num_of_frames(num_of_frames_wire));
Generate_impulse Generate_impulse(
    //input
    .CLK(CLK), .sw_test(SW), .START(start_bit_wire), .TIME_first_pulse(time_first_pulse_wire),
    .TIME_second_pulse(time_second_pulse_wire), .TIME_third_pulse(time_third_pulse_wire),
    .TIME_fourth_pulse(time_fourth_pulse_wire), .TIME_relax(time_relax_wire), .NUM_pack(num_pack_wire),
    .NUM_of_frames(num_of_frames_wire),
    //output
    .IMPULSE_RESOLUTION(pulse_resolution_wire), .LEDs(LEDs[3 : 2]), .PULSE_END(pulse_end_wire));
SPI SPI (
    //input
    .CLK(CLK), .SCLK(sclk_wire), .SDI_flag(start_sdi_wire), .DATA(data_out_wire), 
    //output
    .END_spi(end_spi_flag), .SDI(SDI), .CS(CS), .BITS_COUNTER_SPI(bits_counter_spi_wire));
 Logic Logic (
    //input
    .CLK(CLK), .SCLK(sclk_wire), .SW(SW), .END_spi(end_spi_flag), .DATA_IN_At_first_channel(data_At_wire_first_channel),
    .DATA_IN_Bt_first_channel(data_Bt_wire_first_channel), .DATA_IN_ziro_first_channel(data_ziro_wire_first_channel),
    .TIME_IMPULSE(pulse_resolution_wire), .BITS_COUNTER_SPI(bits_counter_spi_wire),
    .DATA_IN_At_second_channel(data_At_wire_second_channel), .DATA_IN_Bt_second_channel(data_Bt_wire_second_channel),
    .DATA_IN_ziro_second_channel(data_ziro_wire_second_channel),
    //output
    .LDAC(LDAC), .DATA_OUT(data_out_wire), .START_SPI(start_sdi_wire));

endmodule