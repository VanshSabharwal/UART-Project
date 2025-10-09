`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module UART_tb ();
    parameter N_BIT = 8;

    reg clk, rst;
    
    // -------------------------------
    // UART_A signals
    // -------------------------------
    reg rx_rd_en_A, tx_wr_en_A;
    reg [N_BIT - 1 : 0] tx_wr_data_A;
    wire rx_empty_A, rx_full_A, tx_full_A, rx_parity_error_A, rx_frame_error_A;
    wire [N_BIT - 1 : 0] rx_rd_data_A;

    // -------------------------------
    // UART_B
    // -------------------------------
    reg rx_rd_en_B, tx_wr_en_B;
    reg [N_BIT - 1 : 0] tx_wr_data_B;
    wire rx_empty_B, rx_full_B, tx_full_B, rx_parity_error_B, rx_frame_error_B;
    wire [N_BIT - 1 : 0] rx_rd_data_B;

    // -------------------------------
    // Serial line connections 
    // (cross-connect TX ↔ RX between A and B)
    // -------------------------------
    wire tx_to_rx_A, tx_to_rx_B;
    
    // -------------------------------
    // Instantiate UART_A
    // -------------------------------
    UART_wrapper uart_A (.clk(clk), .rst(rst), .rx(tx_to_rx_B), .rx_rd_en(rx_rd_en_A), .tx_wr_en(tx_wr_en_A),
                         .tx_wr_data(tx_wr_data_A), .rx_empty(rx_empty_A), .rx_full(rx_full_A), .tx(tx_to_rx_A),
                         .tx_full(tx_full_A), .rx_parity_error(rx_parity_error_A), .rx_frame_error(rx_frame_error_A),
                         .rx_rd_data(rx_rd_data_A));
    
    // -------------------------------
    // Instantiate UART_B
    // -------------------------------
    UART_wrapper uart_B (.clk(clk), .rst(rst), .rx(tx_to_rx_A), .rx_rd_en(rx_rd_en_B), .tx_wr_en(tx_wr_en_B),
                         .tx_wr_data(tx_wr_data_B), .rx_empty(rx_empty_B), .rx_full(rx_full_B), .tx(tx_to_rx_B),
                         .tx_full(tx_full_B), .rx_parity_error(rx_parity_error_B), .rx_frame_error(rx_frame_error_B),
                         .rx_rd_data(rx_rd_data_B));
    
    // -------------------------------
    // Clock generation (toggle every 1 time unit)
    // -------------------------------
    initial begin
        clk = 0;
        forever
            #1 clk = ~ clk;
    end
    
    // -------------------------------
    // Stimulus for UART_A
    // -------------------------------
    initial begin
        rst = 1'b1;
        rx_rd_en_A = 1'b0;
        tx_wr_en_A = 1'b1;
        tx_wr_data_A = $random;
        @ (negedge clk);
        rst = 1'b0;

        repeat (16) begin
            tx_wr_data_A = $random;
            @(negedge clk);
        end
        tx_wr_en_A = 1'b0;
        repeat (1000000) @(negedge clk);
       
        repeat (18) begin
            rx_rd_en_A = 1'b1;
            @(negedge clk);
            rx_rd_en_A = 1'b0;
            repeat (10000) @(negedge clk);
        end
        $stop;
    end
    
    // -------------------------------
    // Stimulus for UART_B
    // -------------------------------
    initial begin
        rst = 1'b1;
        rx_rd_en_B = 1'b0;
        tx_wr_en_B = 1'b1;
        tx_wr_data_B = $random;
        @ (negedge clk);
        rst = 1'b0;

        repeat (16) begin
            tx_wr_data_B = $random;
            @(negedge clk);
        end
        tx_wr_en_B = 1'b0;
        repeat (1000000) @(negedge clk);
       
        repeat (18) begin
            rx_rd_en_B = 1'b1;
            @(negedge clk);
            rx_rd_en_B = 1'b0;
            repeat (10000) @(negedge clk);
        end
        $stop;
    end
endmodule
