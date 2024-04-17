`timescale 1ns / 1ps

module Logic(
    input CLK, SCLK, SW, END_spi,
          logic [15 : 0] DATA_IN_At,
          logic [15 : 0] DATA_IN_Bt,
          logic [3 : 0] TIME_IMPULSE, 
          logic [4 : 0] BITS_COUNTER_SPI,
    output logic LDAC, 
           logic [15 : 0] DATA_OUT,
           logic START_SPI,  
           logic CS 
);

reg start_CLK = 1'b1;
reg [1 : 0] start_SPI_CLK_for_first_pulse = 2'b10;
reg [1 : 0] run_spi_for_first_pulse_CLK = 2'b11;
reg [2 : 0] end_spi_for_first_pulse_CLK = 3'b100;
reg [2 : 0] wait_to_open_LDAC_for_first_pulse_CLK = 3'b101;
reg [2 : 0] LDAC_for_first_pulse = 3'b110;
reg [2 : 0] load_data_for_second_pulse = 3'b111;

reg [3 : 0] run_spi_for_second_pulse_CLK = 4'b1000;
reg [3 : 0] end_spi_for_second_pulse_CLK = 4'b1001;
reg [3 : 0] wait_to_open_LDAC_for_second_pulse_CLK = 4'b1010;
reg [3 : 0] LDAC_for_second_pulse = 4'b1011;
reg [3 : 0] load_data_for_third_pulse = 4'b1100;

reg [3 : 0] run_spi_for_third_pulse_CLK = 4'b1101;
reg [3 : 0] end_spi_for_third_pulse_CLK = 4'b1110;
reg [3 : 0] wait_to_open_LDAC_for_third_pulse_CLK = 4'b1111;
reg [4 : 0] LDAC_for_third_pulse = 5'b10000;
reg [4 : 0] load_data_for_fourth_pulse = 5'b10001;

reg [4 : 0] run_spi_for_fourth_pulse_CLK = 5'b10001;
reg [4 : 0] end_spi_for_fourth_pulse_CLK = 5'b10010;
reg [4 : 0] wait_to_open_LDAC_for_fourth_pulse_CLK = 5'b10011;
reg [4 : 0] LDAC_for_fourth_pulse = 5'b10100;
reg [4 : 0] load_data_for_first_pulse = 5'b10101;

reg [4 : 0] stage_of_installing_a_temporary_pulse_CLK = start_CLK;

reg [4 : 0] stage_of_installing_a_temporary_pulse_SCLK = 0;
reg start_SCLK = 1'b1;
reg [1 : 0] start_SPI_SCLK = 2'b10;
reg [1 : 0] end_spi_SCLK = 2'b11;
reg [2 : 0] open_LDAC_SCLK = 3'b100;
reg [2 : 0] close_LDAC_SCLK = 3'b101;

reg [5 : 0] coounter_for_close_LDAC = 0;
reg [20 : 0] counter_16bits_for_CS = 0;
reg [15 : 0] data = 0;
reg [4 : 0] wait_to_open_LDAC_counter = 0;
reg counter_16bits_for_CS_end = 0;

reg ldac_flag = 1;
reg [15 : 0] data_out_flag = 0;
reg start_spi_flag = 0;
reg cs_flag = 1;

assign LDAC = ldac_flag;
assign DATA_OUT  = data_out_flag;
assign START_SPI = start_spi_flag;
assign CS = cs_flag;

always @(posedge CLK) begin
    case (stage_of_installing_a_temporary_pulse_CLK) 
//first pulse
        start_CLK : begin
            data <= DATA_IN_At;
            if (SW == 1 & TIME_IMPULSE == 1) begin
                stage_of_installing_a_temporary_pulse_CLK <= run_spi_for_first_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= start_SPI_SCLK;
            end
            else begin 
                stage_of_installing_a_temporary_pulse_CLK <= start_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= start_SCLK;
            end
        end    
        run_spi_for_first_pulse_CLK : begin
            if (END_spi == 1) begin
                stage_of_installing_a_temporary_pulse_CLK <= run_spi_for_first_pulse_CLK;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_first_pulse_CLK;
            end
        end
        end_spi_for_first_pulse_CLK : begin
            if (BITS_COUNTER_SPI != 16) begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_first_pulse_CLK;
            end
            else begin
                data = 0;
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_first_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
            end
        end
        wait_to_open_LDAC_for_first_pulse_CLK : begin
            if (wait_to_open_LDAC_counter != 6) begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_first_pulse_CLK;
                wait_to_open_LDAC_counter = wait_to_open_LDAC_counter + 1;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_first_pulse;
                wait_to_open_LDAC_counter = 0;
            end
        end
        LDAC_for_first_pulse : begin
            if (TIME_IMPULSE == 1 & END_spi == 1 & coounter_for_close_LDAC != 10) begin
                stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
                coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
            end
            else begin
                stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
                stage_of_installing_a_temporary_pulse_CLK <= load_data_for_second_pulse;
                data = 0;
                coounter_for_close_LDAC = 0;
            end
        end
//second pulse
        load_data_for_second_pulse : begin
            if (LDAC != 1) begin
                stage_of_installing_a_temporary_pulse_CLK <= load_data_for_second_pulse;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_second_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= start_SPI_SCLK;
            end
        end
        end_spi_for_second_pulse_CLK : begin
            if (BITS_COUNTER_SPI != 16) begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_second_pulse_CLK;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_second_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
            end
         end   
        wait_to_open_LDAC_for_second_pulse_CLK : begin
            if (wait_to_open_LDAC_counter != 6) begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_second_pulse_CLK;
                wait_to_open_LDAC_counter = wait_to_open_LDAC_counter + 1;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_second_pulse;
                wait_to_open_LDAC_counter = 0;
            end
        end    
        LDAC_for_second_pulse : begin
            data <= DATA_IN_Bt;
            if (TIME_IMPULSE == 2) begin
                if (coounter_for_close_LDAC != 10) begin
                    stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
                    coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
                end
                else begin 
                    stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
                    stage_of_installing_a_temporary_pulse_CLK <= load_data_for_third_pulse;
                    coounter_for_close_LDAC = 0;
                end
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_second_pulse;
            end
        end
//third pulse
        load_data_for_third_pulse : begin
            if (LDAC != 1) begin
                stage_of_installing_a_temporary_pulse_CLK <= load_data_for_third_pulse;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_third_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= start_SPI_SCLK;
            end
        end
        end_spi_for_third_pulse_CLK : begin
            if (BITS_COUNTER_SPI != 16) begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_third_pulse_CLK;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_third_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
            end
        end
        wait_to_open_LDAC_for_third_pulse_CLK : begin
            if (wait_to_open_LDAC_counter != 6) begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_third_pulse_CLK;
                wait_to_open_LDAC_counter = wait_to_open_LDAC_counter + 1;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_third_pulse;
                wait_to_open_LDAC_counter = 0;
            end
        end
        LDAC_for_third_pulse : begin
            data <= 0;
            if (TIME_IMPULSE == 3) begin
                if (coounter_for_close_LDAC != 10) begin
                    stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
                    coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
                end
                else begin 
                    stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
                    stage_of_installing_a_temporary_pulse_CLK <= load_data_for_fourth_pulse;
                    coounter_for_close_LDAC = 0;
                end
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_third_pulse;
            end
        end  
//fourth pulse
        load_data_for_fourth_pulse : begin
            if (LDAC != 1) begin
                stage_of_installing_a_temporary_pulse_CLK <= load_data_for_fourth_pulse;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_fourth_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= start_SPI_SCLK;
            end
        end
        end_spi_for_fourth_pulse_CLK : begin
            if (BITS_COUNTER_SPI != 16) begin
                stage_of_installing_a_temporary_pulse_CLK <= end_spi_for_fourth_pulse_CLK;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_fourth_pulse_CLK;
                stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
            end
        end
        wait_to_open_LDAC_for_fourth_pulse_CLK : begin
            if (wait_to_open_LDAC_counter != 6) begin
                stage_of_installing_a_temporary_pulse_CLK <= wait_to_open_LDAC_for_fourth_pulse_CLK;
                wait_to_open_LDAC_counter = wait_to_open_LDAC_counter + 1;
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_fourth_pulse;
                wait_to_open_LDAC_counter = 0;
            end
        end
        LDAC_for_fourth_pulse : begin
            data <= DATA_IN_At;
            if (TIME_IMPULSE == 4) begin
                if (coounter_for_close_LDAC != 10) begin
                    stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
                    coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
                end
                else begin 
                    stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
                    stage_of_installing_a_temporary_pulse_CLK <= start_CLK;
                    coounter_for_close_LDAC = 0;
                end
            end
            else begin
                stage_of_installing_a_temporary_pulse_CLK <= LDAC_for_fourth_pulse;
            end
        end

    endcase 
end

always @(posedge SCLK) begin
    case (stage_of_installing_a_temporary_pulse_SCLK)
        start_SCLK : begin
            ldac_flag <= 1;
            data_out_flag <= data;
            start_spi_flag <= 0;
            cs_flag <= 1;
        end
        start_SPI_SCLK : begin
            start_spi_flag <= 1;
            cs_flag <= 0;
            data_out_flag <= data;
        end 
        end_spi_SCLK : begin
            start_spi_flag <= 0;
            cs_flag <= 1;
            data_out_flag <= data;
        end
        open_LDAC_SCLK : begin
            ldac_flag <= 0;
            data_out_flag <= data;
        end
        close_LDAC_SCLK : begin
            ldac_flag <= 1;
            data_out_flag <= data;
        end
    endcase
end

// always @(posedge CLK) begin
//     case (stage_of_installing_a_temporary_pulse_CLK)
//         strart_CLK : begin
//             if (SW == 1) begin
//                 data <= DATA_IN_At;
//                 stage_of_installing_a_temporary_pulse_SCLK <= start_SPI_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= start_SPI_CLK_for_first_pulse;
//             end 
//             else begin
//                 stage_of_installing_a_temporary_pulse_CLK <= strart_CLK;
//                 data <= DATA_IN_At;
//             end       
//         end 
//         start_SPI_CLK_for_first_pulse : begin
//             if (TIME_IMPULSE == 1 & END_spi != 1) begin 
//                 stage_of_installing_a_temporary_pulse_CLK <= start_SPI_CLK_for_first_pulse;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;            
//                 stage_of_installing_a_temporary_pulse_CLK <= open_LDAC_for_first_pulse;
//             end
//         end
//         open_LDAC_for_first_pulse : begin
//             if (TIME_IMPULSE == 1 & END_spi == 1 & coounter_for_close_LDAC != 5) begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
//                 coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= start_SPI_CLK_for_second_pulse;
//                 data = 0;
//                 coounter_for_close_LDAC = 0;
//             end
//         end
//         start_SPI_CLK_for_second_pulse : begin
//               if (TIME_IMPULSE == 2 & counter_16bits_for_CS != 6'b100_000 & counter_16bits_for_CS_end != 1) begin //counter_16bits_for_CS != 32
//                 counter_16bits_for_CS = counter_16bits_for_CS + 1;
//                 counter_16bits_for_CS_end = 0;
//             end
//             else begin
//                 counter_16bits_for_CS = 0;
//                 counter_16bits_for_CS_end = 1;
//                 stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= open_LDAC_for_second_pulse;
//             end
//         end
//         open_LDAC_for_second_pulse : begin
//              if (TIME_IMPULSE == 2 & END_spi == 1 & coounter_for_close_LDAC != 5) begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
//                 coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= start_SPI_CLK_for_third_pulse;
//                 data = DATA_IN_Bt;
//                 coounter_for_close_LDAC = 0;
//             end
//         end
//         start_SPI_CLK_for_third_pulse : begin
//             if (TIME_IMPULSE == 3 & counter_16bits_for_CS != 6'b100_000 & counter_16bits_for_CS_end != 1) begin //counter_16bits_for_CS != 32
//                 counter_16bits_for_CS = counter_16bits_for_CS + 1;
//                 counter_16bits_for_CS_end = 0;
//             end
//             else begin
//                 counter_16bits_for_CS = 0;
//                 counter_16bits_for_CS_end = 1;
//                 stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= open_LDAC_for_third_pulse;            
//             end
//         end
//         open_LDAC_for_third_pulse : begin
//              if (TIME_IMPULSE == 3 & END_spi == 1 & coounter_for_close_LDAC != 5) begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
//                 coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= start_SPI_CLK_for_fourth_pulse;
//                 data = 0;
//                 coounter_for_close_LDAC = 0;
//             end
//         end
//         start_SPI_CLK_for_fourth_pulse : begin
//             if (TIME_IMPULSE == 4 & counter_16bits_for_CS != 6'b100_000 & counter_16bits_for_CS_end != 1) begin //counter_16bits_for_CS != 32
//                 counter_16bits_for_CS = counter_16bits_for_CS + 1;
//                 counter_16bits_for_CS_end = 0;
//             end
//             else begin
//                 counter_16bits_for_CS = 0;
//                 counter_16bits_for_CS_end = 1;
//                 stage_of_installing_a_temporary_pulse_SCLK <= end_spi_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= open_LDAC_for_fourth_pulse;            
//             end
//         end
//         open_LDAC_for_fourth_pulse : begin
//              if (TIME_IMPULSE == 4 & END_spi == 1 & coounter_for_close_LDAC != 5) begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= open_LDAC_SCLK;
//                 coounter_for_close_LDAC = coounter_for_close_LDAC + 1;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_SCLK <= close_LDAC_SCLK;
//                 stage_of_installing_a_temporary_pulse_CLK <= strart_CLK;
//                 coounter_for_close_LDAC = 0;
//             end
//         end
//         default: begin
//             if (SW != 1) begin
//             //    stage_of_installing_a_temporary_pulse_CLK <= default;
//                 LDAC = 1;
//                 CS = 1;
//                 start_SPI_CLK_for_first_pulse = 0;
//                 coounter_for_close_LDAC = 0;
//                 counter_16bits_for_CS = 0;
//             end
//             else begin
//                 stage_of_installing_a_temporary_pulse_CLK <= strart_CLK;
//             end
//         end
//     endcase
// end

// always @(posedge SCLK) begin
//     case (stage_of_installing_a_temporary_pulse_SCLK)
//         strart_CLK : begin
//             data_out_flag = data;
//             ldac_flag <= 1;
//             cs_flag <= 1;
//             start_spi_flag <= 0;
//         end 
//         start_SPI_SCLK : begin
//             cs_flag <= 1;
//             start_spi_flag <= 1;
//             data_out_flag <= data;
//         end
//         end_spi_SCLK : begin
//             cs_flag = 1;
//             start_spi_flag = 0;
//             data_out_flag = 0;
//         end
//         open_LDAC_SCLK : begin
//             ldac_flag = 0;
//         end
//         close_LDAC_SCLK : begin
//             ldac_flag = 1;
//         end
//         default: begin
//             cs_flag = 1;
//             ldac_flag = 1;
//             start_spi_flag = 0;
//             data_out_flag = 0;
//         end
//     endcase
// end
endmodule
