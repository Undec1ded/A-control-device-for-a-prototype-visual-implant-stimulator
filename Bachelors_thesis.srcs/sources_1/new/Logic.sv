`timescale 1ns / 1ps

module Logic(
    input CLK, SCLK
               reg [15 : 0] DATA_IN,
               reg CS,
               reg IMPULSE, 
    output reg LDAC, 
           reg [15 : 0] DATA_OUT,
           reg start_sdi  

);

reg [15 : 0] data = 0;
reg [15 : 0] counter_for_open_LDAC = _99_;//посчитать
reg [10 : 0] counter_16bits_for_CS = 0;

always@(posedge CLK) begin
    data = DATA_IN;
end

always@(posedge SCLK) begin

    if (counter_16bits_for_CS != 16 & ) begin
        counter_16bits_for_CS = counter_16bits_for_CS + 1;
        CS = 1;
    end
    else begin
        counter_16bits_for_CS = 0;
        CS = 0;
    end

    if (IMPULSE == 1 ) begin
        start_sdi <= 1;
        if (counter_for_open_LDAC != _1000_) begin //не забыть поменять
            counter_for_open_LDAC = counter_for_open_LDAC + 1;
            LDAC = 0;
        end
        else begin
            counter_for_open_LDAC = 0;
            LDAC = 1;
        end
    end
    else begin
        start_sdi <= 0;
    end
end

endmodule
