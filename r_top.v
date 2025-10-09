`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Receiver_TOP (clk, rst, S_tick, rx, rx_rd_en, rx_rd_data, rx_empty, rx_full, rx_parity_error, rx_frame_error);
    parameter N_BIT = 8;  // Data width (8 bits)
    
    // -------------------------------
    // Inputs
    // -------------------------------
    input clk, rst, S_tick, rx, rx_rd_en;

    // -------------------------------
    // Outputs
    // -------------------------------
    output [N_BIT - 1 : 0] rx_rd_data;
    output rx_empty, rx_full, rx_parity_error, rx_frame_error;

    // -------------------------------
    // Internal Wires (connections between modules)
    // -------------------------------
    wire rx_wr_en;  // Write enable for RX FIFO (from RX done)
    wire [N_BIT - 1 : 0] rx_wr_data;  // Data from RX to RX FIFO

    // -------------------------------
    // Module Instantiations
    // -------------------------------
    // UART Receiver
    UART_RX receiver (.clk(clk), .S_tick(S_tick), .rst(rst), .rx(rx), .dout(rx_wr_data), 
                      .rx_done_tick(rx_wr_en), .parity_error(rx_parity_error), .frame_error(rx_frame_error));
    // RX FIFO (stores received data)
    UART_FIFO rx_fifo (.clk(clk), .rst(rst), .wr_en(rx_wr_en), .wr_data(rx_wr_data), .rd_en(rx_rd_en), 
                       .rd_data(rx_rd_data), .empty(rx_empty), .full(rx_full));
endmodule