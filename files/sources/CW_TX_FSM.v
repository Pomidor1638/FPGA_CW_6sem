`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 13:44:14
// Design Name: 
// Module Name: CW_TX_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: TX UART protocol
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_TX_FSM(
    input wire CLK,
    input wire RST,
    input wire TX_CE,
    input wire UART_CE,
    input wire TX_RDY_T,
    input wire [7:0] TX_DATA_R,
    output reg TXD,
    output reg TXCT_R,
    output reg TX_RDY_R
    );
    
    reg [7:0] TX_DATA = 8'h00;
    reg TX_PAR_BIT_RG = 1'b0;
    reg [2:0] TX_DATA_CT = 3'b000;
    
    initial begin
        TXD = 1'b1;
        TXCT_R = 1'b1;
        TX_RDY_R = 1'b1;
    end
    
    localparam IDLE = 0,
               WCE = 1,
               TSTRB = 2,
               TDT = 3,
               TPARB = 4,
               TSTB1 = 5,
               TSTB2 = 6;
    reg [2:0] state = IDLE;
    
    always @(posedge CLK, posedge RST) begin
        if (RST) begin
            TX_DATA <= 8'h00;
            TX_PAR_BIT_RG <= 1'b0;
            TXCT_R <= 1'b1;
            TX_DATA_CT <= 3'b000;
            TX_RDY_R <= 1'b1;
            TXD <= 1'b1;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (TX_RDY_T) begin
                        TX_DATA <= TX_DATA_R;
                        TX_PAR_BIT_RG <= ^TX_DATA_R;
                        TX_RDY_R <= 1'b0;
                        if (UART_CE) begin
                            TXD <= 1'b0;
                            TXCT_R <= 1'b0;
                            state <= TSTRB;
                        end else begin
                            state <= WCE;
                        end
                    end else begin
                        state <= IDLE;
                    end
                end
                
                WCE: begin
                    if (UART_CE) begin
                        TXD <= 1'b0;
                        TXCT_R <= 1'b0;
                        state <= TSTRB;
                    end else begin
                        state <= WCE;
                    end
                end
                
                TSTRB: begin
                    if (TX_CE) begin
                        TXD <= TX_DATA[0];
                        TX_DATA <= {1'b0, TX_DATA[7:1]};
                        state <= TDT;
                    end else begin
                        state <= TSTRB;
                    end
                end
                
                TDT: begin
                    if (TX_CE) begin
                        TX_DATA <= {1'b0, TX_DATA[7:1]};
                        TX_DATA_CT <= TX_DATA_CT + 1'b1;
                        if (TX_DATA_CT == 3'h7) begin
                            TXD <= TX_PAR_BIT_RG;
                            state <= TPARB;
                        end else begin
                            TXD <= TX_DATA[0];
                            state <= TDT;
                        end
                    end else begin
                        state <= TDT;
                    end
                end
                
                TPARB: begin
                    if (TX_CE) begin
                        TXD <= 1'b1;
                        state <= TSTB1;
                    end else begin
                        state <= TPARB;
                    end
                end
                
                TSTB1: begin
                    if (TX_CE) begin
                        TXD <= 1'b1;
                        state <= TSTB2;
                    end else begin
                        state <= TSTB1;
                    end
                end
                
                TSTB2: begin
                    if (TX_CE) begin
                        TX_RDY_R <= 1'b1;
                        TXCT_R <= 1'b1;
                        state <= IDLE;
                    end else begin
                        state <= TSTB2;
                    end
                end
            endcase
        end
    end
endmodule
