`timescale 1ns / 1ps

module Generate_time#(

    parameter time_bits = 16

)(
    input CLK, [time_bits - 1 : 0] TIME_impulse_bits,
    output reg TIME_impulse
);

reg         mks1   = 1'b1;
reg [1 : 0] mks2   = 2'b10;
reg [1 : 0] mks3   = 2'b11;
reg [2 : 0] mks4   = 3'b100;
reg [2 : 0] mks5   = 3'b101;
reg [2 : 0] mks6   = 3'b110;
reg [2 : 0] mks7   = 3'b111;
reg [3 : 0] mks8   = 4'b1000;
reg [3 : 0] mks9   = 4'b1001;
reg [3 : 0] mks10  = 4'b1010;
reg [3 : 0] mks11  = 4'b1011;
reg [3 : 0] mks12  = 4'b1100;
reg [3 : 0] mks13  = 4'b1101;
reg [3 : 0] mks14  = 4'b1110;
reg [3 : 0] mks15  = 4'b1111;
reg [4 : 0] mks16  = 5'b10000;
reg [4 : 0] mks17  = 5'b10001;
reg [4 : 0] mks18  = 5'b10010;
reg [4 : 0] mks19  = 5'b10011;
reg [4 : 0] mks20  = 5'b10100;
reg [7 : 0] mks100 = 7'b1100100;
reg [8 : 0] mks400 = 9'b110010000;

reg [10 : 0] time_param = 0;

reg covert_to_1MGz = 0;

reg [25 : 0] time_counter = 0;
reg [10 : 0] MGz_timer = 0;

//convert 100MGz to 1kGz
always@(posedge CLK) begin

    if (time_counter != 100) begin
        time_counter = time_counter + 1;
        covert_to_1MGz = 0;
    end

    else begin
        time_counter = time_counter + 0;
        covert_to_1MGz = 1;
    end
    
end

always@(posedge CLK) begin
    case (TIME_impulse_bits)
        mks10 : time_param = 10;
        mks100 : time_param = 100;
        mks400 : time_param = 400; 
        default: begin 
            time_param = 0;
            MGz_timer = 0;
        end 
    endcase 
    
    if (MGz_timer != time_param) begin
        TIME_impulse = 1;
        MGz_timer = MGz_timer + 1;
    end
    else begin
        TIME_impulse = 0;
        MGz_timer = 0;
    end    
end
endmodule
