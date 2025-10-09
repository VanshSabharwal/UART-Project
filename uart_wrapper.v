`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module UART_wrapper (clk, rst, rx, rx_rd_en, tx_wr_data, tx_wr_en, rx_rd_data, rx_empty, rx_full, tx, tx_full,
                     rx_parity_error, rx_frame_error);

    parameter N_BIT = 8;  // Data width (8 bits)
    
    // -------------------------------
    // Inputs
    // -------------------------------
    input clk, rst;
    input rx;  // Serial in
    input rx_rd_en;  // Read enable for RX FIFO
    input tx_wr_en;  // Write enable for TX FIFO
    input [N_BIT - 1 : 0] tx_wr_data;  // Data to transmit
    
    // -------------------------------
    // Outputs
    // -------------------------------
    output rx_empty, rx_full;  // RX FIFO status
    output tx;  // Serial out
    output tx_full;  // TX FIFO status
    output rx_parity_error, rx_frame_error;  // Error flags from RX
    output [N_BIT - 1 : 0] rx_rd_data;  // Data read from RX FIFO
    
    // -------------------------------
    // Internal Wires (connections between modules)
    // -------------------------------
    wire S_tick;  // Baud rate tick (16x baud) from generator
    
    // -------------------------------
    // Module Instantiations
    // -------------------------------
    // Baud rate generator
    baud_rate_gen baud_rate_generator (.clk(clk), .rst(rst), .S_tick(S_tick));

    // Tranmitter Top
    Transmitter_TOP tx_top (.clk(clk), .rst(rst), .S_tick(S_tick), .tx_wr_data(tx_wr_data), .tx_wr_en(tx_wr_en),
                           .tx(tx), .tx_full(tx_full));

    // Receiver Top
    Receiver_TOP rx_top (.clk(clk), .rst(rst), .S_tick(S_tick), .rx(rx), .rx_rd_en(rx_rd_en), .rx_rd_data(rx_rd_data),
                         .rx_empty(rx_empty), .rx_full(rx_full), .rx_parity_error(rx_parity_error), .rx_frame_error(rx_frame_error));
endmodule