`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Semenikhin A.V.
// 
// Create Date: 20.02.2026 21:09:25
// Design Name: 
// Module Name: CW_DEBUGGER
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: TOP DEBUGGER module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CW_DEBUGGER (
    input  wire        CLK,
    input  wire        RST,

    input  wire        RX_RDY_T,
    input  wire [7:0]  RX_DATA_R,
    output wire        RX_RDY_R,

    output wire        TX_RDY_T,
    output wire [7:0]  TX_DATA_T,
    input  wire        TX_RDY_R,
    
    output wire        CEO,
    output wire        RSTO,
    
    output wire        PGM_S_EX_REQ,
    output wire [15:0] PGM_S_ADDR,
    output wire [3:0]  PGM_S_NBE,
    output wire [2:0]  PGM_S_CMD,
    output wire [31:0] PGM_S_D_WR,
    input  wire        PGM_S_EX_ACK,
    input  wire [31:0] PGM_S_D_RD,
    
    output wire        DM_S_EX_REQ,
    output wire [15:0] DM_S_ADDR,
    output wire [2:0]  DM_S_CMD,
    output wire [7:0]  DM_S_D_WR,
    input  wire        DM_S_EX_ACK,
    input  wire [7:0]  DM_S_D_RD
);

    wire        w_cmd_rdy_t;
    wire [51:0] w_cmd_data;
    wire        w_cmd_rdy_r;
    
    wire        w_res_rdy_t;
    wire [51:0] w_res_data;
    wire        w_res_rdy_r;
    
    wire [7:0]  w_as_ascii_data;
    wire        w_as_hex_flg;
    wire [3:0]  w_as_hex_data;
    
    wire [3:0]  w_dis_hex_data;
    wire [7:0]  w_dis_ascii_data;

    wire [4:0]  w_rom_addr;
    wire [7:0]  w_rom_data;



    CW_ASSEMBLER asm_inst (
        .CLK           (CLK),
        .RST           (RST),
        
        .RX_RDY_T      (RX_RDY_T),
        .RX_DATA_R     (RX_DATA_R),
        .RX_RDY_R      (RX_RDY_R),
        
        .CMD_RDY_T     (w_cmd_rdy_t),
        .CMD_DATA_T    (w_cmd_data),
        .CMD_RDY_R     (w_cmd_rdy_r),
        
        .ASCII_DATA    (w_as_ascii_data),
        .HEX_FLG       (w_as_hex_flg),
        .DC_ASCII_HEX  (w_as_hex_data)
    );

    CW_DC_ASCII_HEX dc_ascii2hex (
        .ASCII         (w_as_ascii_data), // [cite: 3633]
        .HEX_FLG       (w_as_hex_flg),    // [cite: 3633]
        .HEX           (w_as_hex_data)    // [cite: 3633]
    );

    CW_PROCESSOR proc_inst (
        .CLK           (CLK),
        .RST           (RST),
        
        .CMD_RDY_T     (w_cmd_rdy_t),
        .CMD_DATA_R    (w_cmd_data),
        .CMD_RDY_R     (w_cmd_rdy_r),
        
        .RES_RDY_T     (w_res_rdy_t),
        .RES_DATA_T    (w_res_data),
        .RES_RDY_R     (w_res_rdy_r),
        
        .CEO           (CEO),
        .RSTO          (RSTO),
        
        .PGM_S_EX_REQ  (PGM_S_EX_REQ),
        .PGM_S_ADDR    (PGM_S_ADDR),
        .PGM_S_NBE     (PGM_S_NBE),
        .PGM_S_CMD     (PGM_S_CMD),
        .PGM_S_D_WR    (PGM_S_D_WR),
        .PGM_S_EX_ACK  (PGM_S_EX_ACK),
        .PGM_S_D_RD    (PGM_S_D_RD),
        
        .DM_S_EX_REQ   (DM_S_EX_REQ),
        .DM_S_ADDR     (DM_S_ADDR),
        .DM_S_CMD      (DM_S_CMD),
        .DM_S_D_WR     (DM_S_D_WR),
        .DM_S_EX_ACK   (DM_S_EX_ACK),
        .DM_S_D_RD     (DM_S_D_RD)
    );

    CW_DISASSEMBLER disasm_inst (
        .CLK           (CLK),
        .RST           (RST),
        
        .RES_RDY_T     (w_res_rdy_t),
        .RES_DATA_R    (w_res_data),
        .RES_RDY_R     (w_res_rdy_r),
        
        .TX_RDY_T      (TX_RDY_T),
        .TX_DATA_T     (TX_DATA_T),
        .TX_RDY_R      (TX_RDY_R),
        
        .HEX_DATA      (w_dis_hex_data),
        .DC_ASCII_DATA (w_dis_ascii_data),
        
        .ADDR          (w_rom_addr),
        .DATA          (w_rom_data)
    );

    CW_DC_HEX_ASCII dc_hex2ascii (
        .HEX           (w_dis_hex_data),  
        .ASCII         (w_dis_ascii_data)
    );

    CW_DIS_ROM rom_inst (
        .ADDR          (w_rom_addr),
        .DATA          (w_rom_data)
    );

endmodule
