`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module UART_TX (clk, S_tick, tx_start, rst, din, tx, tx_done_tick);
    // State encoding
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter SHIFT = 2'b10;
    parameter STOP = 2'b11;

    parameter N_BIT = 8;  // Number of data bits

    input clk, tx_start, rst;
    input S_tick;  // 16x baud tick
    input [N_BIT - 1 : 0] din;  // Parallel data input
    output reg tx_done_tick;
    output reg tx;  // Serial output

    (* fsm_encoding = "sequential" *)  // FSM encoding

    reg [1 : 0] cs, ns;  // Current and next state
    reg [3 : 0] tick_count, bit_count;  // Counters for baud ticks and bits
    reg [10 : 0] tx_frame;  // Frame = {stop, parity, data, start} 
    reg load_frame;  // load flag

    // -------------------------------
    // Next State Logic (FSM)
    // -------------------------------
    always @ (*) begin
        case (cs)
            IDLE : begin  // Idle: wait for start signal and frame loaded
                if (tx_start && load_frame)
                    ns = START;
                else
                    ns = IDLE;
            end

            START : begin
                if (S_tick && (tick_count == 15))
                    ns = SHIFT;
                else 
                    ns = START;
            end

            SHIFT : begin
                if (S_tick && (bit_count == N_BIT) && (tick_count == 15))
                    ns = STOP;
                else
                    ns = SHIFT;
            end

            STOP : begin
                if (S_tick && (tick_count == 15))
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
            cs <= IDLE;
        else
            cs <= ns;
    end

    // -------------------------------
    // Output & Frame Handling
    // -------------------------------
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            tick_count <= 0;
            bit_count <= 0;
            tx <= 1;
            tx_done_tick <= 0;
            tx_frame <= 0;
            load_frame <= 1'b0;
        end

        else begin
            tx_done_tick <= 0; // Defualt Value
            load_frame <= 0; // DEfault Value
            
            case (cs)
                IDLE : begin
                    tick_count <= 0;
                    bit_count <= 0;
                    if (tx_start) begin
                        tx_frame <= {1'b1, (^ din), din, 1'b0};  // Stop + parity + data + start
                    end
                    if (tx_frame == {1'b1, (^ din), din, 1'b0})
                        load_frame <= 1'b1;  // Mark frame as ready
                end

                START : begin
                    tx <= tx_frame[0];  // Send start bit (0)
                    if (S_tick) begin
                        tick_count <= tick_count + 1;
                        if (tick_count == 15)
                            tick_count <= 0;  // Reset after one bit duration
                    end
                end
                    
                SHIFT : begin
                    tx <= tx_frame[bit_count + 1];  // Send next data/parity bit
                    if (S_tick) begin
                        if (bit_count <= N_BIT) begin 
                            tick_count <= tick_count + 1;
                            if (tick_count == 15) begin  // Move to next bit after 16 ticks
                                bit_count <= bit_count + 1;
                            end
                        end
                    end
                end

                STOP : begin
                    tx <= tx_frame[10];  // Send stop bit (1)
                    if (S_tick) begin
                        tick_count <= tick_count + 1;
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            tx_done_tick <= 1;  // Transmission complete
                        end 
                    end
                end
            endcase
        end
    end
endmodule