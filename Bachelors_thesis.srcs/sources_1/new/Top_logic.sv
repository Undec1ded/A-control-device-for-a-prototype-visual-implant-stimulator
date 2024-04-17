`timescale 1ns / 1ps
module Top(
    input CLK, SW,
    output SCLK, SDI, CS, LDAC 
    );


//Frequency_divider_SCLK parametrs
wire sclk_wire;

//Load_data parametrs
wire [15 : 0] data_At_wire;
wire [15 : 0] data_Bt_wire;
wire [15 : 0] data_ziro_wire;

//Logic parametrs
wire start_sdi_wire;
wire [15 : 0] data_out_wire;

//Generate_impulse parametrs
wire [3 : 0] pulse_resolution_wire;

//SPI parametrs
wire end_spi_flag;
wire [4 : 0] bits_counter_spi_wire;

assign SCLK = sclk_wire;

Frequency_divider_SCLK frequency_divider_SCLK(
    .CLK(CLK),
    //output
    .SCLK(sclk_wire));
Load_data Load_data (
    //input
    .CLK(CLK),
    //output
    .DATA_At(data_At_wire), .DATA_Bt(data_Bt_wire), .DATA_ziro(data_ziro_wire));
Generate_impulse Generate_impulse(
    //input
    .CLK(CLK), .sw_test(SW), 
    //output
    .IMPULSE_RESOLUTION(pulse_resolution_wire));
SPI SPI (
    //input
    .SCLK(sclk_wire), .SDI_flag(start_sdi_wire), .DATA(data_out_wire), 
    //output
    .END_spi(end_spi_flag), .SDI(SDI), .CS(CS), .BITS_COUNTER_SPI(bits_counter_spi_wire));
 Logic Logic (
    //input
    .CLK(CLK), .SCLK(sclk_wire), .SW(SW), .END_spi(end_spi_flag), .DATA_IN_At(data_At_wire), .DATA_IN_Bt(data_Bt_wire), .DATA_IN_ziro(data_ziro_wire), .TIME_IMPULSE(pulse_resolution_wire), .BITS_COUNTER_SPI(bits_counter_spi_wire),
    //output
    .LDAC(LDAC), .DATA_OUT(data_out_wire), .START_SPI(start_sdi_wire));

endmodule