`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Module
// Engineer:       FPGA-Mechanic
//
// Create Date:    12:01:50 07/28/2016
// Design Name:    ARBITER IMPLEMENTATIONS
// Module Name:    MARBITER_PRMX2D_V10
// Project Name:   Any
// Target Devices: Any FPGA or ASIC
// Tool versions:  Xilinx DS 14.7
// Description:    2-bit Request Version of MARBITER_PRMX3D_V10
//
// Revision:       1.0
// Revision 1.0 - File Created
//////////////////////////////////////////////////////////////////////////////////
module MARBITER_PRMX2D_V10(
    input        CLK,
    input        RST,
    input  [1:0] I_REQ,
    input        SERV,
    input  [1:0] S_REQ,
    output       NO_REQ,
    output [1:0] O_REQ
    );

// Internal signals declaration:
 wire FSM_CE;
 reg  FSM_STATE;
//------------------------------------------
// Output flag:
 assign NO_REQ = ~(|(I_REQ));
//------------------------------------------
// FSM Clock Enable:
 assign FSM_CE = SERV;
//------------------------------------------
// Driver FSM:
 always @ (posedge CLK, posedge RST)
  if(RST)
   FSM_STATE <= 1'b0;
  else if(FSM_CE)
   if(!FSM_STATE)
    FSM_STATE <= S_REQ[0];
   else
    FSM_STATE <= ~S_REQ[1];
//------------------------------------------
// Output MX:
 assign O_REQ[0] = I_REQ[0] & (~FSM_STATE | (FSM_STATE & ~I_REQ[1]));
 assign O_REQ[1] = I_REQ[1] & (FSM_STATE | (~FSM_STATE & ~I_REQ[0]));
//------------------------------------------
endmodule
