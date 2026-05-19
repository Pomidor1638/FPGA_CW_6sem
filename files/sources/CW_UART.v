`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 09:24:10
// Design Name: 
// Module Name: CW_UART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART controller (TX and RX)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_UART #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 14400,
    parameter RATIO = 8
    )
    (
    input wire       CLK,
    input wire       RST,
    input wire       RXD,
    input wire       TX_RDY_T,
    input wire [7:0] TX_DATA_R,
    output           TX_RDY_R,
    output           TXD,
    output           RX_DATA_EN,
    output     [9:0] RX_DATA_T
    );
    
    wire RXD_RG;
    
    CW_RXD_SYNC rx_sync (
        .RXD(RXD),
        .CLK(CLK),
        .RST(RST),
        .RXD_RG(RXD_RG)
    );
    
    wire UART_CE;
    
    CW_DIVIDER #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .RATIO(RATIO)
    )
    uart_ce_divider (
        .CLK(CLK),
        .RST(RST),
        .CE(UART_CE)  
    );
    
    wire RXCT_R, RX_CE;
    
    CW_RX_SAMP_CT rx_samp_ct (
        .UART_CE(UART_CE),
        .CLK(CLK),
        .RST(RST),
        .RXCT_R(RXCT_R),
        .RX_CE(RX_CE)
    );
    
    CW_RX_FSM rx_fsm (
        .RXD_RG(RXD_RG),
        .CLK(CLK),
        .RST(RST),
        .RX_CE(RX_CE),
        .RXCT_R(RXCT_R),
        .RX_DATA_EN(RX_DATA_EN),
        .RX_DATA_T(RX_DATA_T)
    );
    
    wire TXCT_R, TX_CE;
    
    CW_TX_SAMP_CT tx_samp_ct (
        .UART_CE(UART_CE),
        .CLK(CLK),
        .RST(RST),
        .TXCT_R(TXCT_R),
        .TX_CE(TX_CE)
    );
    
    CW_TX_FSM tx_fsm (
        .CLK(CLK),
        .RST(RST),
        .TX_CE(TX_CE),
        .UART_CE(UART_CE),
        .TX_RDY_T(TX_RDY_T),
        .TX_DATA_R(TX_DATA_R),
        .TXD(TXD),
        .TXCT_R(TXCT_R),
        .TX_RDY_R(TX_RDY_R)
    );
    
endmodule
