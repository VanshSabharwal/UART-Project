`timescale 1ns / 1ps
module UART_RX (clk, S_tick, rst, rx, dout, rx_done_tick, parity_error, frame_error);
    // State encoding
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter SHIFT = 2'b10;
    parameter STOP = 2'b11;

    parameter N_BIT = 8;  // Number of data bits

    input clk, rst;
    input S_tick;  //16x baud tick
    input rx;  //serial input
    output reg [N_BIT - 1 : 0] dout;  // Parallel data output
    output reg rx_done_tick;  // Signal: data reception complete
    output reg parity_error, frame_error;  // Error flags

    (* fsm_encoding = "one_hot" *)  // FSM encoding

    reg [1 : 0 ] cs, ns;  // Current state, next state
    reg [3 : 0] tick_count, bit_count;  // Tick counter, bit counter
    reg [10 : 0] rx_frame;  // Shift register for full frame (start + data + parity + stop)

    // -------------------------------
    // Next State Logic (FSM)
    // -------------------------------
    always @ (*) begin
        case (cs)
            IDLE : begin
                if (rx == 0)  // Detect start bit (line goes low)
                    ns = START;
                else
                    ns = IDLE;
            end

            START : begin
                if (S_tick && (tick_count == 7))  // Wait half bit time to sample middle of start bit
                    ns = SHIFT;
                else
                    ns = START;
            end

            SHIFT : begin
                if (S_tick && (bit_count == N_BIT) && (tick_count == 15))  // After all bits are received
                    ns = STOP;
                else
                    ns = SHIFT;
            end

            STOP : begin
                if (S_tick && rx && (tick_count == 15))  // Wait for stop bit, then go idle
                    ns = IDLE;
                else
                    ns = STOP;
            end
        endcase
    end

    // ---------------------
    // State Register
    // ---------------------
    always @ (posedge clk, posedge rst) begin
        if (rst)
            cs <=IDLE;
        else
            cs <= ns;
    end

    // -------------------------------
    // Output & Data Handling Logic
    // -------------------------------
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            dout <= 0;
            rx_done_tick <= 0;
            tick_count <= 0;
            bit_count <= 0;
            rx_frame <= 0;
            parity_error <= 1'b0;
            frame_error <= 1'b0;
        end

        else begin
            // Default values (cleared every cycle)
            rx_done_tick <= 1'b0; 
            parity_error <= 1'b0; 
            frame_error <= 1'b0; 

            case (cs)
                IDLE : begin  // Idle state: reset counters and rx_frame
                    tick_count <= 0;
                    bit_count <= 0;
                    rx_frame <= 0;
                end

                START : begin  // Start bit detection
                    dout <= 0;
                    if (S_tick) begin
                        tick_count <= tick_count + 1;
                        if (tick_count == 7) begin // Sample in middle of start bit
                            tick_count <= 0;
                            rx_frame[0] <= rx;  // Save start bit
                        end
                    end
                end

                SHIFT : begin  // Shift in data + parity bits
                    if (S_tick) begin
                        if (bit_count <= N_BIT) begin
                            tick_count <= tick_count + 1;
                            if (tick_count == 15) begin  // Sample at end of each bit period
                                rx_frame[bit_count + 1] <= rx;
                                bit_count <= bit_count + 1;
                            end
                        end
                    end 
                end

                STOP : begin  // Stop bit and frame check
                    // Parity error: mismatch between received parity and computed parity
                    if (rx_frame[9] != (^ rx_frame[8 : 1]))
                        parity_error <= 1'b1;

                    if (S_tick) begin
                        tick_count <= tick_count + 1;
                        if (tick_count == 15) begin
                            rx_done_tick <= 1'b1;  // Signal that data is ready
                            rx_frame[10] <= rx;  // Store stop bit
                            dout <= rx_frame[8 : 1];  // Extract data bits

                            // Frame error: wrong start or stop bits
                            if ((rx_frame[0] != 1'b0) || (rx != 1'b1))
                                frame_error <= 1'b1;
                        end
                    end
                end
            endcase
        end
    end
endmodule