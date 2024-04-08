`timescale 1ns / 1ps

module Logic(
    input CLK, SCLK
               reg [15 : 0] DATA_IN,
               reg SCLK,
               reg IMPULSE, 
               END_spi,
    output reg LDAC, 
           reg [15 : 0] DATA_OUT,
           reg START_SPI,  
           reg CS 
);
reg [4 : 0] stage_of_installing_a_temporary_pulse_CLK = 0;
reg strart_CLK = 1'b1;

reg [4 : 0] stage_of_installing_a_temporary_pulse_SCLK = 0;
reg strart_SCLK = 1'b1;
reg [1 : 0] start_SPI_SCLK = 2'b10;
reg [1 : 0] END_spi_SCLK = 2'b11;
reg [2 : 0] open_LDAC_SCLK = 3'b100;
reg [2 : 0] close_LDAC_SCLK = 3'b101;

reg [15 : 0] data = 0;

always @(posedge CLK) begin
    case (stage_of_installing_a_temporary_pulse_CLK)
        strart_CLK : begin
           
        end 
        default: 
    endcase
end

always @(posedge SCLK) begin
    case (stage_of_installing_a_temporary_pulse_SCLK)
        strart_CLK : begin
            LDAC = 1;
            CS = 1;
            START_SPI = 0;
        end 
        start_SPI_SCLK : begin
            if (END_spi != 1) begin
                CS = 1;
                START_SPI = 0;
                DATA_OUT = 0;
            end 
            else begin
                DATA_OUT = data;
                CS = 0;
                START_SPI = 1;
            end
        end
        END_spi_SCLK : begin
            CS = 1;
            START_SPI = 0;
            DATA_OUT = 0;
        end
        open_LDAC_SCLK : begin
            LDAC = 0;
        end
        close_LDAC_SCLK : begin
            LDAC = 1;
        end
        default: begin
            CS = 1;
            LDAC = 1;
            START_SPI = 0;
            DATA_OUT = 0;
        end
    endcase
end


// //case stage_of_installing_a_temporary_puls 
// reg [4 : 0] strart = 1'b1;
// reg [4 : 0] set_parametrs = 2'b10;
// reg [4 : 0] open_LDAC = 2'b11;
// reg [4 : 0] spi_start = 3'b100;

// reg resolution_spi_start = 0;
// reg [15 : 0] data = 0;
// reg [15 : 0] counter_for_open_LDAC = _99_;//посчитать
// reg [10 : 0] counter_16bits_for_CS = 0;

// reg [4 : 0] stage_of_installing_a_temporary_pulse = 0;
// reg [10 : 0] load_data_to_spi_counter = 0;

// reg counter_16bits_for_CS_resolution = 0;

// assign DATA_OUT = data;

// // always@(posedge SCLK) begin

// //     if (counter_16bits_for_CS != 16 & ) begin
// //         counter_16bits_for_CS = counter_16bits_for_CS + 1;
// //         CS = 1;
// //     end

// //     else begin
// //         counter_16bits_for_CS = 0;
// //         CS = 0;
// //     end

// //     if (IMPULSE == 1 ) begin
// //         if (counter_for_open_LDAC != _1000_) begin //не забыть поменять
// //             counter_for_open_LDAC = counter_for_open_LDAC + 1;
// //         end
// //         else begin
// //             counter_for_open_LDAC = 0;
// //         end
// //     end

// //     else begin
// //         START_SPI <= 0;
// //     end
// // end

// always@(posedge SCLK) begin
//     case (stage_of_installing_a_temporary_pulse)
//         strart : begin
//             CS = 1;
//             DATA_OUT = 0;
//             stage_of_installing_a_temporary_puls <= set_parametrs;
//         end
//         set_parametrs : begin
//             DATA_OUT = DATA_IN;
//             START_SPI = 1;
//             stage_of_installing_a_temporary_puls <= spi_start 
//         end
//         spi_start : begin
            
//             if (START_SPI != 0 & load_data_to_spi_counter != 16) begin
//                 CS = 0;
//                 load_data_to_spi_counter = load_data_to_spi_counter + 1;
//             end
//             else begin
//                 START_SPI = 0;
//                 CS = 1;
//                 load_data_to_spi_counter = 0;
//                 stage_of_installing_a_temporary_puls <= open_LDAC;
//             end
//         open_LDAC : begin
//                 if (START_SPI != 1 & IMPULSE != 1) begin
//                     LDAC = 0;
//                 end            
//                 else begin
//                     LDAC = 1;
//                     stage_of_installing_a_temporary_puls <= strart;
//                 end
//         end
//         end
//         default: 
//     endcase
// end

endmodule
