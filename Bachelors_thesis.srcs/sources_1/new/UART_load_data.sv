`timescale 1ns / 1ps
module UART_load_data(
    input   logic UART_data, CLK, PULSE_END, 
    output  logic UART_Tx, UART_Tx_test, UART_Rx_test,
            logic [79 : 0] DATA_time, DATA_amplitude, DATA_num,
            logic START, 
            logic PACKETS_download,
            logic [3 : 0] LEDs 
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
reg [10 : 0] counter_one_bit = 0;
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
reg [3 : 0] Start_simulation = 4'b1000;
reg [3 : 0] Simulation_end = 4'b1001;
reg [3 : 0] Half_period_first = 4'b1010;
reg [3 : 0] Revers_data = 4'b1011;
reg [3 : 0] Check_data = 4'b1101;
reg [5 : 0] States_of_data = 1'b1;


reg [15 : 0] vl_packet_start  = 16'b__01010110____01001100;
reg [18 : 0] vl_packet_answer = 19'b0_01101010_10_00110010; //0x56,0x4c 

reg [15 : 0] tm_packet_start  = 16'b01010100_01001101;
reg [18 : 0] tm_packet_answer = 19'b0_00101010_10_10110010; //0x54,0x4d 

reg [15 : 0] ip_packet_start  = 16'b01001001_01010000;
reg [18 : 0] ip_packet_answer = 19'b0_10010010_10_00001010; //0x49,0x50 

reg [15 : 0] start_data       = 16'b01010011_01010100; //0x53,0x54
reg [8 : 0] end_sim_answer   = 9'b0_11110011;; // 0xcf

reg [3 : 0] counter_packetdge = 0;

reg [1 : 0] wait_start = 0;

reg [9 : 0] uart_clk = 0;
reg [7 : 0] byte_data = 0; 

assign LEDs[0] = led_red;
assign LEDs[1] = led_green;
assign LEDs[3 : 2] = wait_start; 
assign START = start_flag;
assign DATA_time = time_data;
assign DATA_amplitude = amplitude_data;
assign DATA_num = num_data;
assign PACKETS_download = packets_download_flag;
assign UART_Tx = uart_tx_flag;
assign UART_Tx_test = uart_tx_flag;
assign UART_Rx_test = UART_data;

always @(posedge CLK) begin
    case (States_of_data)
        Idle : begin
            counter_data <= 0;
            if (counter_packetdge < 4'b1010) begin
                States_of_data <= (UART_data == 0) ? Half_period : Idle;    
            end
            else begin
                States_of_data <= Check_data;
            end
        end

        Half_period : begin
            Stages_of_16bits_data <= Idle_16bits; 
            if (counter_one_bit != (434)) begin
                counter_one_bit <= counter_one_bit + 1;
            end
            else begin
                States_of_data  <= Load_data;
                counter_one_bit <= 0;
            end                
        end

        Load_data : begin
            if (counter_one_bit != one_bit_time) begin
                counter_one_bit <= counter_one_bit + 1;
            end         
            else begin
                counter_one_bit <= 0;
                if (counter_data < 3'b111) begin
                    byte_data = byte_data + UART_data;
                    byte_data = byte_data << 1;
                    counter_data = counter_data + 1;
                end
                else if (counter_data == 3'b111) begin
                    byte_data = byte_data + UART_data;
                    counter_data = counter_data + 1;
                end
                else begin
                    States_of_data = Revers_data;
                end
            end
        end

        Revers_data : begin
            if (counter_packetdge < 4'b1001) begin
                connection_data[7] = byte_data[0];
                connection_data[6] = byte_data[1];
                connection_data[5] = byte_data[2];
                connection_data[4] = byte_data[3]; 
                connection_data[3] = byte_data[4];
                connection_data[2] = byte_data[5];
                connection_data[1] = byte_data[6];
                connection_data[0] = byte_data[7];
                connection_data = connection_data << 8;
                counter_packetdge = counter_packetdge + 1;
                byte_data = 0;
                States_of_data = Idle;
            end
            else begin
                connection_data[7] = byte_data[0];
                connection_data[6] = byte_data[1];
                connection_data[5] = byte_data[2];
                connection_data[4] = byte_data[3]; 
                connection_data[3] = byte_data[4];
                connection_data[2] = byte_data[5];
                connection_data[1] = byte_data[6];
                connection_data[0] = byte_data[7];
                counter_packetdge = counter_packetdge + 1;
                byte_data = 0;
                States_of_data = Idle;
            end
        end
        Check_data : begin
            if (connection_data == 0) begin
                counter_packetdge <= 0;
                led_green <= 1;
                States_of_data <= Idle;
            end
            else if (connection_data[79 : 79 - data_16bits] == vl_packet_start) begin
                amplitude_data = connection_data;
                Stages_of_16bits_data <= Vl_packet_answer;
                connection_data = 0;
                counter_packetdge = 0;
                States_of_data = Idle;
            end
            else if (connection_data[79 : 79 - data_16bits] == tm_packet_start) begin
                time_data = connection_data;
                Stages_of_16bits_data <= Tm_packet_answer;
                connection_data = 0;
                counter_packetdge = 0;
                States_of_data = Idle;
            end
            else if (connection_data[79 : 79 - data_16bits] == ip_packet_start) begin
                num_data = connection_data;
                Stages_of_16bits_data <= Ip_packet_answer;
                packets_download_flag = 1;
                wait_start <= 1;
                connection_data = 0;
                counter_packetdge = 0;
                States_of_data = Idle;
            end
            else if (connection_data[79 : 79 - data_16bits] == start_data) begin
                wait_start = 0;
                connection_data = 0;
                counter_packetdge = 0;
                States_of_data = Start_simulation;
            end
            else begin
                counter_packetdge = 0;
                connection_data = 0;
                led_green = 0;
                led_red = 1;
                States_of_data = Idle;
            end
        end
        Start_simulation : begin
            if (PULSE_END == 1) begin
                start_flag <= 1;
            end
            else begin
                States_of_data <= Simulation_end;
            end
        end
        Simulation_end : begin
            if (PULSE_END == 0) begin
                States_of_data <= Simulation_end;
            end
            else begin
                start_flag <= 0;
                States_of_data <= Idle;
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
            vl_packet_answer = 19'b0_01101010_10_00110010;
            tm_packet_answer = 19'b0_00101010_10_10110010;
            ip_packet_answer = 19'b0_10010010_10_00001010;
            end_sim_answer   = 9'b0_11110011; //11001111
        end
        Vl_packet_answer : begin
            if (counter_one_bit_answer != one_bit_time) begin
                counter_one_bit_answer <= counter_one_bit_answer + 1;
            end
            else begin
                counter_one_bit_answer <= 0;
                if (counter_16bits_answer < 5'b10011) begin
                    uart_tx_flag = vl_packet_answer[18];
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
                if (counter_16bits_answer < 5'b10011) begin
                    uart_tx_flag = tm_packet_answer[18];
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
                if (counter_16bits_answer < 5'b10011) begin
                    uart_tx_flag = ip_packet_answer[18];
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
                if (counter_16bits_answer < 4'b1001) begin
                    uart_tx_flag = end_sim_answer[8];
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