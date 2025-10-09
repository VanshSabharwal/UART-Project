`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Transmitter_TOP (clk, rst, S_tick, tx_wr_data, tx_wr_en, tx, tx_full);
    parameter N_BIT = 8;  // Data width (8 bits)
    
    // -------------------------------
    // Inputs
    // -------------------------------
    input clk, rst, S_tick, tx_wr_en;
    input [N_BIT - 1 : 0] tx_wr_data;

    // -------------------------------
    // Outputs
    // -------------------------------
    output tx, tx_full;
    
    // -------------------------------
    // Internal Wires (connections between modules)
    // -------------------------------
    wire tx_rd_en;  // Read enable for TX FIFO (from TX done)
    wire [N_BIT - 1 : 0] tx_rd_data;  // Data from TX FIFO to TX
    wire tx_empty;  // TX FIFO empty flag (used to start TX)
    
    // -------------------------------
    // Module Instantiations
    // -------------------------------
    // UART Transmitter
    UART_TX transmitter (.clk(clk), .S_tick(S_tick), .rst(rst), .tx_start(~ tx_empty), 
                         .din(tx_rd_data), .tx(tx), .tx_done_tick(tx_rd_en));
    // TX FIFO (holds data before transmission)
    UART_FIFO tx_fifo (.clk(clk), .rst(rst), .wr_en(tx_wr_en), .wr_data(tx_wr_data), 
                       .rd_en(tx_rd_en), .rd_data(tx_rd_data), .empty(tx_empty), .full(tx_full));
endmodule