module uart_rx (
    input wire clk,         // Clock input
    input wire reset_n,     // Active low asynchronous reset
    input wire rx,          // UART RX input
    output reg [7:0] data,  // Received data output
    output reg rx_ready,    // Receive data ready signal
    output reg led_green,   // Green LED output
    output reg led_red      // Red LED output
);

// Parameters
parameter CLK_FREQ = 100_000_000;   // Clock frequency in Hz
parameter BAUD_RATE = 115_200;       // Baud rate in bits per second
parameter BIT_TIME = CLK_FREQ / BAUD_RATE; // Time for one bit

// States for the state machine
typedef enum logic [2:0] {
    IDLE,
    START_BIT,
    DATA_BITS,
    STOP_BIT
} state_t;

// Internal signals
reg [3:0] count;
reg [6:0] shift_reg;
state_t state;
reg [6:0] bit_count;

// Always block for state machine
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= IDLE;
        count <= 4'b0;
        shift_reg <= 7'b0;
        data <= 8'b0;
        rx_ready <= 0;
        bit_count <= 7'b0;
        led_green <= 0;
        led_red <= 0;
    end else begin
        case(state)
            IDLE: begin
                if (!rx) begin
                    state <= START_BIT;
                    count <= 0;
                end
            end
            START_BIT: begin
                if (count == BIT_TIME / 2) begin
                    state <= DATA_BITS;
                    count <= 0;
                end else begin
                    count <= count + 1;
                end
            end
            DATA_BITS: begin
                if (count == BIT_TIME) begin
                    shift_reg <= {shift_reg[5:0], rx};
                    count <= 0;
                    bit_count <= bit_count + 1;
                end else begin
                    count <= count + 1;
                end
            end
            STOP_BIT: begin
                if (count == BIT_TIME) begin
                    data <= shift_reg;
                    rx_ready <= 1;
                    if (bit_count == 8'd80)
                        led_green <= 1;
                    else
                        led_red <= 1;
                    state <= IDLE;
                    count <= 0;
                    bit_count <= 7'b0;
                end else begin
                    count <= count + 1;
                end
            end
        endcase
    end
end

endmodule