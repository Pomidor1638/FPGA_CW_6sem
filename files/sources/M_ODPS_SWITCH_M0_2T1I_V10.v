`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Module
// Engineer:       FPGA-Mechanic
//
// Create Date:    11:59:42 12/20/2017
// Design Name:    On-Die Port Set Switching
// Module Name:    M_ODPS_SWITCH_M0_2T1I_V10
// Project Name:   Any
// Target Devices: Any FPGA or ASIC
// Tool versions:  Xilinx DS 14.7
// Description:    2-port TDEPL to 1-port IDEPL Mode-0 ODPS Switch
//                 0T TDEPL-IDEPL/IDEPL-TDEPL transfer delay
// Revision:       1.0
// Revision 1.0 - File Created
//////////////////////////////////////////////////////////////////////////////////
module M_ODPS_SWITCH_M0_2T1I_V10 #(
    parameter DATA_T_WIDTH = 8,
    parameter DATA_R_WIDTH = 8)
    (
    // System inputs:
    input CLK,
    input RST,
    // TDEPL Target Port-0:
    input                     T0_READY_T,
    input                     T0_LAST_TR,
    input  [DATA_T_WIDTH-1:0] T0_DATA_T,
    output                    T0_READY_R,
    output [DATA_R_WIDTH-1:0] T0_DATA_R,
    // TDEPL Target Port-1:
    input                     T1_READY_T,
    input                     T1_LAST_TR,
    input  [DATA_T_WIDTH-1:0] T1_DATA_T,
    output                    T1_READY_R,
    output [DATA_R_WIDTH-1:0] T1_DATA_R,
    // IDEPL Initiator Port-0:
    output                    I0_READY_T,
    output                    I0_LAST_TR,
    output [DATA_T_WIDTH-1:0] I0_DATA_T,
    input                     I0_READY_R,
    input  [DATA_R_WIDTH-1:0] I0_DATA_R
    );

// Internal signals declaration:
 wire I_RDY_T;
 wire I_LAST;
 wire SERV_REQ;
 wire [1:0] O_REQ, OREQ_L;
 reg  [1:0] OREQ_R;
 reg  FSM_STATE;
//------------------------------------------
 assign SERV_REQ = I0_READY_R & I_LAST & I_RDY_T;
//------------------------------------------
// Priority Request MUX:
 MARBITER_PRMX2D_V10      P_MUX(
 .CLK(CLK),
 .RST(RST),
 .I_REQ({T1_READY_T, T0_READY_T}),
 .SERV(SERV_REQ),
 .S_REQ(OREQ_L),
 .NO_REQ(),
 .O_REQ(O_REQ));
//------------------------------------------
// Active Port Number Latch:
 always @ (posedge CLK, posedge RST)
  if(RST) OREQ_R <= 2'b00;
  else    OREQ_R <= OREQ_L;
 assign OREQ_L = FSM_STATE ? OREQ_R : O_REQ;
//------------------------------------------
// Driver FSM:
 always @ (posedge CLK, posedge RST)
  if(RST) FSM_STATE <= 1'b0;
  else
   if(I_RDY_T)
    if(~I0_READY_R | ~I_LAST)
     FSM_STATE <= 1'b1;
    else // I0_READY_R & I_LAST = 1
     FSM_STATE <= 1'b0;
//------------------------------------------
// Initiator Outputs:
 assign I_RDY_T = (T0_READY_T & OREQ_L[0]) |
                  (T1_READY_T & OREQ_L[1]);
 assign I_LAST  = (T0_LAST_TR & OREQ_L[0]) |
                  (T1_LAST_TR & OREQ_L[1]);
 assign I0_DATA_T = (T0_DATA_T & {DATA_T_WIDTH{OREQ_L[0]}}) |
                    (T1_DATA_T & {DATA_T_WIDTH{OREQ_L[1]}});
 assign I0_READY_T = I_RDY_T;
 assign I0_LAST_TR = I_LAST;
//------------------------------------------
// Target Outputs:
 assign T0_READY_R = I0_READY_R & OREQ_L[0];
 assign T1_READY_R = I0_READY_R & OREQ_L[1];
 assign T0_DATA_R  = I0_DATA_R;
 assign T1_DATA_R  = I0_DATA_R;
//------------------------------------------
endmodule
