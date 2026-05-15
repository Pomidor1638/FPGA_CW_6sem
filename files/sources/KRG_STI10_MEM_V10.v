`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Module
// Engineer:       Kryakhtunov G.M. 
// 
// Create Date:    2022-10-18
// Design Name:    KRG_STI10_MEM_V10
// Module Name:    KRG_STI10_MEM_V10 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module KRG_STI10_MEM_V10 #(
   parameter           UAW       = 4,               // User-Defined address width
   parameter [1:0]     UDW       = 0                // User-Defined data width
)
(
    // System
    input                   CLK,
    input                   RST,
    // STI Interface 1.0
    input                   S_EX_REQ,
    input [UAW-1:UDW]       S_ADDR,
    input [2:0]             S_CMD,
    input [2**(UDW+3)-1:0]  S_D_WR,
    output                  S_EX_ACK,
    output [2**(UDW+3)-1:0] S_D_RD,
    // Memory Interface
    output [UAW-UDW-1:0]    R_ADR,
    output                  R_WE,
    output [2**(UDW+3)-1:0] R_WD,
    output                  R_RE,
    input  [2**(UDW+3)-1:0] R_RD
);

// FSM S_EX_ACK:
 reg FS;
 always @(posedge CLK, posedge RST)
  if(RST) FS <= 1'b0;
  else
   case(FS)
    1'b0:
     if(S_EX_REQ == 1'b1) FS <= 1'b1;
    default: FS <= 1'b0;
   endcase
// ------------------------------
// Assign STI Inteface V1.0. Singnal's:
// Assign S_EX_ACK:
 assign S_EX_ACK = FS;
// ------------------------------
// Assign S_D_RD:
 assign S_D_RD = R_RD;
// ------------------------------
// ------------------------------
// Assign Memory Inteface Singnal's:
// Assign R_ADR:
 assign R_ADR = S_ADDR;
// ------------------------------
// Assign R_WE:
 assign R_WE = S_EX_REQ & FS & ~S_CMD[2]; 
// ------------------------------
// Assign R_RE:
 assign R_RE = S_EX_REQ & ~FS & S_CMD[2]; 
// ------------------------------
// Assign R_WD:
 assign R_WD = S_D_WR; 
// ------------------------------
// ------------------------------
endmodule
