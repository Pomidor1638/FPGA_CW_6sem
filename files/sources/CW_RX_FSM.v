`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 10:03:05
// Design Name: 
// Module Name: CW_RX_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: FSM for receive data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_RX_FSM(
    input wire RXD_RG,
    input wire CLK,
    input wire RST,
    input wire RX_CE,
    output reg RXCT_R,
    output reg RX_DATA_EN,
    output reg [9:0] RX_DATA_T
    );
    
    reg [2:0] RX_DATA_CT;
    
    initial begin
        RX_DATA_EN = 1'b0;
        RX_DATA_T = {(10){1'b0}};
        RX_DATA_CT = {3{1'b0}};
        RXCT_R = 1'b1;
    end
    
    localparam IDLE = 0,
               RSTRB = 1,
               RDT = 2,
               RPARB = 3,
               RSTB1 = 4,
               RSTB2 = 5,
               WEND = 6;
    reg [2:0] state = IDLE;
    
    always @(posedge CLK, posedge RST) begin
        if (RST) begin
            RX_DATA_EN <= 1'b0;
            RX_DATA_T <= {(10){1'b0}};
            RX_DATA_CT <= {3{1'b0}};
            RXCT_R <= 1'b1;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (~RXD_RG) begin
                        RX_DATA_EN <= 1'b0;
                        RX_DATA_T[9] <= 1'b0;
                        RXCT_R <= 1'b0;
                        state <= RSTRB;
                    end else begin
                        RX_DATA_EN <= 1'b0;
                        state <= IDLE;
                    end
                end
                
                RSTRB: begin
                    if (RX_CE) begin
                        if (RXD_RG) begin
                            RXCT_R <= 1'b1;
                            state <= IDLE;
                        end else begin
                            state <= RDT;
                        end
                    end else begin
                        state <= RSTRB;
                    end
                end
                
                RDT: begin
                    if (RX_CE) begin
                        RX_DATA_T[7:0] <= {RXD_RG, RX_DATA_T[7:1]}; 
                        RX_DATA_CT <= RX_DATA_CT + 1;
                        if (RX_DATA_CT == 7) begin
                            state <= RPARB;
                        end
                    end else begin
                        state <= RDT;
                    end
                end
                
                RPARB: begin
                    if (RX_CE) begin
                        RX_DATA_T[8] <= ^RX_DATA_T[7:0] ^ RXD_RG;
                        state <= RSTB1;
                    end else begin
                        state <= RPARB;
                    end
                end
                
                RSTB1: begin
                    if (RX_CE) begin
                        RX_DATA_T[9] <= ~RXD_RG;
                        state <= RSTB2;
                    end else begin
                        state <= RSTB1;
                    end
                end
                
                RSTB2: begin
                    if (RX_CE) begin
                        if (RXD_RG) begin
                            RX_DATA_EN <= 1'b1;
                            RXCT_R <= 1'b1;
                            state <= IDLE;
                        end else begin
                            RX_DATA_T[9] <= 1'b1;
                            state <= WEND;
                        end
                    end else begin
                        state <= RSTB2;
                    end
                end
                
                WEND: begin
                    if (RXD_RG) begin
                        RX_DATA_EN <= 1'b1;
                        RXCT_R <= 1'b1;
                        state <= IDLE;
                    end else begin
                        state <= WEND;
                    end
                end
            endcase
        end
    end
endmodule
