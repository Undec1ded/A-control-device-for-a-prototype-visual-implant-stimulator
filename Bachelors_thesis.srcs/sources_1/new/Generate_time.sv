`timescale 1ns / 1ps

module Generate_time#(

    parameter time_bits = 16

)(
    input CLK, [time_bits - 1 : 0] time_impulse_bits,
    output reg time_impulse
);

reg ms1 = 1'b1;
reg [1 : 0] ms2 = 2'b10;
reg [1 : 0] ms3 = 2'b11;
reg [2 : 0] ms4 = 3'b100;
reg [2 : 0] ms5 = 3'b101;
reg [2 : 0] ms6 = 3'b110;
reg [2 : 0] ms7 = 3'b111;
reg [3 : 0] ms8 = 4'b1000;
reg [3 : 0] ms9 = 4'b1001;
reg [3 : 0] ms10 = 4'b1010;

reg [10 : 0] time_param = 0;

reg covert_to_1kGz = 0;

reg [25 : 0] time_counter = 0;
reg [10 : 0] kGz_timer = 0;

//convert 100MGz to 1kGz
always@(posedge CLK) begin

    if (time_counter != 100_000) begin
        time_counter = time_counter + 1;
        covert_to_1kGz = 0;
    end

    else begin
        time_counter = time_counter + 0;
        covert_to_1kGz = 1;
    end
end

always@(posedge CLK) begin
    case (time_impulse_bits)
        ms1 : time_param = 1;
        ms2 : time_param = 2;
        ms3 : time_param = 3;
        ms4 : time_param = 4;
        ms5 : time_param = 5;
        ms6 : time_param = 6;
        ms7 : time_param = 7;
        ms8 : time_param = 8;
        ms9 : time_param = 9;
        ms10 : time_param = 10;
        default: begin 
            time_param = 0;
            kGz_timer = 0;
        end 
    endcase 

    if (kGz_timer != time_param) begin
        time_impulse = 1;
        kGz_timer = kGz_timer + 1;
    end
    else begin
        time_impulse = 0;
        kGz_timer = 0;
    end    
end
endmodule
