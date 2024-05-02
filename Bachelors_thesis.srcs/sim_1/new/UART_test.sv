`timescale 1ns / 1ps
module UART_load_data_tb;

// Parameters
localparam CLK_PERIOD = 6; // Clock period in ns for 152000 baud rate

// Inputs
reg CLK = 0;
reg UART_data = 1;

// Outputs
wire UART_Tx;
wire [79:0] DATA_time, DATA_amplitude, DATA_num;
wire START, PACKETS_download;
wire [1:0] LEDs;
reg [79 : 0] test_upload_parametr = {16'b01010110_01001100 , 62'hffffff , 1'b0};
// Instantiate the UART module
UART_load_data dut (
    .CLK(CLK),
    .UART_data(UART_data),
    .UART_Tx(UART_Tx),
    .DATA_time(DATA_time),
    .DATA_amplitude(DATA_amplitude),
    .DATA_num(DATA_num),
    .START(START),
    .PACKETS_download(PACKETS_download),
    .LEDs(LEDs)
);

// Clock generation
always #((CLK_PERIOD / 2)) CLK = ~CLK;

// Test stimulus
initial begin
    // Start bit
    UART_data = 1;
    #10;

    // Send array of 80 zero bits
    repeat (80) begin
        UART_data = 0; // Data bit
        #3916;
    end

    // Stop bit
    UART_data = 1;
    #100000;

    // Add more test stimuli as needed
    for (int i = 1; i < 80 ; i++) begin
      UART_data  = test_upload_parametr[79];
      test_upload_parametr = test_upload_parametr << 1; 
      #3916;
    end
    // End simulation
    #1000000;
    $finish;
end

endmodule
