`timescale 1ns / 1ps
module Generate_impulse#(
//test parametres 
parameter time_impulse_test = 40_000,
parameter time_second_impulse_test = 40_000,
parameter time_pulse_interval_test = 1_000,
parameter tipe_pulse_packatge_interval = 50_000
)( 
    input CLK, sw_test, START,
                    logic TIME_IMPULSE,
                    logic TIME_SECOND_IMPULSE,
                    logic TIME_PULSE_INTERVAL,
                    logic TIME_PULSE_PACKATGE_INTERVAL,
    output reg [3 : 0] IMPULSE_RESOLUTION
    );

reg [20 : 0] counter_time = 0;

reg [4 : 0] state_impulse = 1'b1;
reg first_impulse = 1'b1;
reg [1 : 0] pulse_interval = 2'b10; 
reg [1 : 0] second_impulse = 2'b11;
reg [2 : 0] pulse_packatge_interval = 3'b100;

always @(posedge clk) begin
    case (state_impulse)
    first_impulse : begin
        if (counter_time =! time_impulse_test & sw_test == 1 & START == 1) begin
            counter_time = counter_time + 1;
            IMPULSE_RESOLUTION = 1;
        end
        else begin
            if (sw_test == 1 & START == 1) begin
                counter_time = 0;
                IMPULSE_RESOLUTION = 1;
                state_impulse <= pulse_interval;    
            end
            else begin
                state_impulse <= first_impulse;
            end    
        end
    end 
    pulse_interval : begin
        if (counter_time != time_pulse_interval_test) begin
            counter_time = counter_time + 1;
            IMPULSE_RESOLUTION = 2;
        end
        else begin
            counter_time = 0;
            IMPULSE_RESOLUTION = 2;
            state_impulse <= second_impulse;
        end
    end
    second_impulse : begin
        if (counter_time =! time_second_impulse_test) begin
            counter_time = counter_time + 1;
            IMPULSE_RESOLUTION = 3;
        end
        else begin
            counter_time = 0;
            IMPULSE_RESOLUTION = 3;
            state_impulse <= pulse_interval;
        end
    end
    pulse_packatge_interval : begin
        if (counter_time != tipe_pulse_packatge_interval) begin
            counter_time = counter_time + 1;
            IMPULSE_RESOLUTION = 4;
        end
        else begin
            counter_time = 0;
            IMPULSE_RESOLUTION = 4;
            state_impulse <= default;
        end
    end 
        default: begin
           IMPULSE_RESOLUTION = 0;
           if (sw_test == 0) begin
                state_impulse = 0;
           end 
           else begin
                state_impulse = first_impulse;
           end 
        end
    endcase
end

endmodule