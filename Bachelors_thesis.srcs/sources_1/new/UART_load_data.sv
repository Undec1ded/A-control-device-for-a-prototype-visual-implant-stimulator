`timescale 1ns / 1ps
module UART_load_data(
    input   logic UART_data, CLK, PULSE_END,
    output  logic UART_Tx,
            logic [79 : 0] DATA_time, DATA_amplitude, DATA_num,
            logic START,
            logic PACKETS_download,
            logic [1 : 0] LEDs 
    );
localparam clkMGz = 100_000_000;
localparam baud_rage = 115200;
localparam one_bit_time = clkMGz / baud_rage;
localparam data_16bits = 15;

//UART_Tx
reg uart_tx_flag = 1;

//test parametrs
reg led_red = 0;
reg led_green = 0;
reg start_flag = 0;
reg packets_download_flag = 0;

reg [6 : 0]  counter_data = 0; //7'b1010000 - 80 bits
reg [79 : 0] connection_data = 0;
reg [15 : 0] start_load_parametrs_bits = 0;
reg [9 : 0]  counter_one_bit = 0;
reg [9 : 0]  counter_one_bit_answer = 0;
reg [4 : 0]  counter_16bits_answer = 0; 

//time pulses
reg [79 : 0]  time_data = 0;

//amplitude pulses
reg [79 : 0]  amplitude_data = 0;

//num 
reg [79 : 0]  num_data = 0;

//stages DATA
reg Idle_16bits = 1'b1;
reg [1 : 0] Vl_packet_answer      = 2'b10;
reg [1 : 0] Tm_packet_answer      = 2'b11;
reg [2 : 0] Ip_packet_answer      = 3'b100;
reg [3 : 0] Simulation_end_answer = 3'b101;
reg [3 : 0] Stages_of_16bits_data = 1'b1;

//stahes UART
reg Idle = 1'b1;
reg [1 : 0] Connected = 2'b10;
reg [2 : 0] Mistake_connect = 2'b11;
reg [3 : 0] Connection_response = 3'b100;
reg [3 : 0] Wait_signal = 3'b101;
reg [3 : 0] Load_data = 3'b110;
reg [3 : 0] Half_period = 3'b111;
reg [4 : 0] Start_simulation = 4'b1000;
reg [4 : 0] Simulation_end = 4'b1001;
reg [5 : 0] States_of_data = 1'b1;


reg [15 : 0] vl_packet_start  = 16'b01010110_01001100;
reg [15 : 0] vl_packet_answer = 16'b01010110_01001100; //0x56,0x4c

reg [15 : 0] tm_packet_start  = 16'b01010100_01001101;
reg [15 : 0] tm_packet_answer = 16'b01010100_01001101; //0x54,0x4d

reg [15 : 0] ip_packet_start  = 16'b01001001_01010000;
reg [15 : 0] ip_packet_answer = 16'b01001001_01010000; //0x49,0x50

reg [15 : 0] start_data       = 16'b01010011_01010100; //0x53,0x54
reg [15 : 0] end_sim_answer   = 16'b0; // 0xcf

assign LEDs[0] = led_red;
assign LEDs[1] = led_green;
assign START = start_flag;
assign DATA_time = time_data;
assign DATA_amplitude = amplitude_data;
assign DATA_num = num_data;
assign PACKETS_download = packets_download_flag;
assign UART_Tx = uart_tx_flag;

always @(posedge CLK) begin
    case (States_of_data)
        Idle : begin
            start_flag <= 0; //test parametr
            States_of_data <= (UART_data == 0) ? Connected : Idle;
        end 
        Connected : begin
            if (counter_one_bit != one_bit_time) begin
            counter_one_bit <= counter_one_bit + 1;
            end         
            else begin
            counter_one_bit <= 0;
            if (counter_data < 7'b1001111) begin
                connection_data = connection_data + UART_data;
                connection_data = connection_data << 1;
                counter_data = counter_data + 1;
            end
            else if (connection_data != 0) begin
                counter_data <= 0;
                States_of_data <= Mistake_connect;
            end
            else begin
                counter_data <= 0;
                States_of_data = Connection_response;
            end
            end
        end
        Mistake_connect : begin
            States_of_data <= Idle;
            led_red <= 1; //test parametr
        end
        Connection_response : begin
            States_of_data <= Wait_signal;
            led_green <= 1;
        end
        Wait_signal : begin
            States_of_data <= (UART_data == 0) ? Half_period : Wait_signal;
            counter_data <= 0;
            connection_data <= 0;
        end
        Half_period : begin
            if (counter_one_bit != (one_bit_time/2 + one_bit_time)) begin
                counter_one_bit <= counter_one_bit + 1;
            end
            else begin
                States_of_data <= Load_data;
                counter_one_bit <= 0;
            end    
        end
        Load_data : begin
            Stages_of_16bits_data <= Idle_16bits;
            start_flag <= 0;
            if (counter_one_bit != one_bit_time) begin
                counter_one_bit <= counter_one_bit + 1;
            end         
            else begin
                counter_one_bit <= 0;
                if (counter_data < 7'b1001111) begin
                    counter_data <= counter_data + 1;
                    connection_data = connection_data << 1;
                    connection_data = connection_data + UART_data;
                end
                else if (connection_data[79 : 79 - data_16bits] == vl_packet_start) begin
                    packets_download_flag = 0;
                    amplitude_data = connection_data;
                    Stages_of_16bits_data <= Vl_packet_answer;
                    States_of_data <= Wait_signal;
                end
                else if (connection_data[79 : 79 - data_16bits] == tm_packet_start) begin
                    time_data = connection_data;
                    Stages_of_16bits_data <= Tm_packet_answer;
                    States_of_data <= Wait_signal;
                end
                else if (connection_data[79 : 79 - data_16bits] == ip_packet_start) begin
                    num_data = connection_data;
                    Stages_of_16bits_data <= Ip_packet_answer;
                    States_of_data <= Wait_signal;
                    packets_download_flag = 1;
                end
                else if (connection_data[79 : 79 - data_16bits] == start_data) begin
                    States_of_data <= Start_simulation;
                end
                else begin
                    connection_data <= 0;
                    States_of_data <= Wait_signal;
                end
            end    
        end
        Start_simulation : begin
            if (PULSE_END == 1) begin
                start_flag <= 1;
                counter_data <= 0;
            end
            else begin
                counter_data <= 0;
                States_of_data <= Simulation_end;
            end
        end
        Simulation_end : begin
           if (PULSE_END == 0) begin
               States_of_data <= Simulation_end;
           end
           else begin
               start_flag <= 0;
               States_of_data <= Wait_signal;
               Stages_of_16bits_data <= Simulation_end_answer;
           end
        end
    endcase
end

always @(posedge CLK) begin
    case (Stages_of_16bits_data)
        Idle_16bits : begin
            uart_tx_flag = 1;
            counter_one_bit_answer <= 0;
            counter_16bits_answer <= 0;
            vl_packet_answer = 16'b01010110_01001100;
            tm_packet_answer = 16'b01010100_01001101;
            ip_packet_answer = 16'b01001001_01010000;
        end
        Vl_packet_answer : begin
            if (counter_one_bit_answer != one_bit_time) begin
                counter_one_bit_answer <= counter_one_bit_answer + 1;
            end
            else begin
                counter_one_bit_answer <= 0;
                if (counter_16bits_answer < 5'b10000) begin
                    uart_tx_flag = vl_packet_answer[15];
                    vl_packet_answer = vl_packet_answer << 1;
                    counter_16bits_answer = counter_16bits_answer + 1;
                end
                else begin
                    uart_tx_flag = 1;
                end
            end
        end
        Tm_packet_answer : begin
            if (counter_one_bit_answer != one_bit_time) begin
                counter_one_bit_answer <= counter_one_bit_answer + 1;
            end
            else begin
                counter_one_bit_answer <= 0;
                if (counter_16bits_answer < 5'b10000) begin
                    uart_tx_flag = tm_packet_answer[15];
                    tm_packet_answer = tm_packet_answer << 1;
                    counter_16bits_answer = counter_16bits_answer + 1;
                end
                else begin
                    uart_tx_flag = 1;
                end
            end
        end
        Ip_packet_answer : begin
            if (counter_one_bit_answer != one_bit_time) begin
                counter_one_bit_answer <= counter_one_bit_answer + 1;
            end
            else begin
                counter_one_bit_answer <= 0;
                if (counter_16bits_answer < 5'b10000) begin
                    uart_tx_flag = ip_packet_answer[15];
                    ip_packet_answer = ip_packet_answer << 1;
                    counter_16bits_answer = counter_16bits_answer + 1;
                end
                else begin
                    uart_tx_flag = 1;
                end
            end
        end
        Simulation_end_answer : begin
            if (counter_one_bit_answer != one_bit_time) begin
                counter_one_bit_answer <= counter_one_bit_answer + 1;
            end
            else begin
                counter_one_bit_answer <= 0;
                if (counter_16bits_answer < 5'b10000) begin
                    uart_tx_flag = end_sim_answer[15];
                    end_sim_answer = end_sim_answer << 1;
                    counter_16bits_answer = counter_16bits_answer + 1;
                end
                else begin
                    uart_tx_flag = 1;
                end
            end
        end
    endcase
end
endmodule
