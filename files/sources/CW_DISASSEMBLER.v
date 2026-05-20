`timescale 1ns / 1ps

module CW_DISASSEMBLER (
    input  wire        CLK,
    input  wire        RST,
    
    // DRP ODPS
    input  wire        RES_RDY_T,
    input  wire [51:0] RES_DATA_R,
    output reg         RES_RDY_R,
    
    // DTP ODPS
    output reg         TX_RDY_T,
    output reg  [7:0]  TX_DATA_T,
    input  wire        TX_RDY_R,
    
    //HEX to ASCII
    output reg  [3:0]  HEX_DATA,
    input  wire [7:0]  DC_ASCII_DATA,
    
    //ROM
    output reg  [4:0]  ADDR,
    input  wire [7:0]  DATA 
);

    localparam CHAR_SPACE = 8'h20;
    localparam CHAR_CR    = 8'h0D;
    localparam CHAR_LF    = 8'h0A;

    localparam ST_IDLE = 3'd0,
               ST_TRES = 3'd1,
               ST_TMEM = 3'd2,
               ST_TSP  = 3'd3,
               ST_TDT  = 3'd4,
               ST_TCR  = 3'd5,
               ST_TLF  = 3'd6;

    reg [2:0]  state;
    reg [2:0]  RES_CT;
    reg [4:0]  END_ADDR;
    reg [3:0]  CMD;
    reg [15:0] RES_ADDR;
    reg [31:0] RES_DATA;
    reg        RES_FLG;
    reg        OPR2_FLG;



    // (p. 30)
    wire [3:0] dec_cmd = (state == ST_IDLE) ? RES_DATA_R[51:48] : CMD;
    reg  [4:0] ADDR_MX, END_ADDR_MX;

    initial begin
        state     = ST_IDLE;
        TX_RDY_T  = 1'b0;
        TX_DATA_T = 8'h00;
        RES_RDY_R = 1'b1;
        RES_CT    = 3'b000;
        ADDR      = 5'd0;
        END_ADDR  = 5'd0;
        CMD       = 4'd0;
        RES_ADDR  = 16'd0;
        RES_DATA  = 32'd0;
        RES_FLG   = 1'b0;
        OPR2_FLG  = 1'b0;
    end
    
   always @(*) begin
        case(dec_cmd)
            4'h0: begin ADDR_MX = 5'h00; END_ADDR_MX = 5'h04; end // RESET
            4'h1: begin ADDR_MX = 5'h05; END_ADDR_MX = 5'h07; end // RUN
            4'h2: begin ADDR_MX = 5'h08; END_ADDR_MX = 5'h0B; end // STEP
            4'h3: begin ADDR_MX = 5'h0C; END_ADDR_MX = 5'h0F; end // STOP
            4'h4: begin ADDR_MX = 5'h10; END_ADDR_MX = 5'h12; end // MWR
            4'h5: begin ADDR_MX = 5'h13; END_ADDR_MX = 5'h15; end // MRD
            4'h6: begin ADDR_MX = 5'h16; END_ADDR_MX = 5'h18; end // PWR
            4'h7: begin ADDR_MX = 5'h19; END_ADDR_MX = 5'h1B; end // PRD
            4'hF: begin ADDR_MX = 5'h1C; END_ADDR_MX = 5'h1E; end // ERR
            default: begin ADDR_MX = 5'h00; END_ADDR_MX = 5'h00; end 
        endcase
    end

    // (p. 31)
    wire [2:0] CT_MX  = CMD[1]   ? 3'b000 : 3'b110;
    wire [2:0] END_CT = OPR2_FLG ? 3'b000 : 3'b100;

    // HEX_DATA (p. 32)
    always @(*) begin
        if (~OPR2_FLG) begin
            case (RES_CT[1:0])
                2'd0: HEX_DATA = RES_ADDR[15:12];
                2'd1: HEX_DATA = RES_ADDR[11:8];
                2'd2: HEX_DATA = RES_ADDR[7:4];
                2'd3: HEX_DATA = RES_ADDR[3:0];
            endcase
        end else begin
            case (RES_CT[2:0])
                3'd0: HEX_DATA = RES_DATA[31:28];
                3'd1: HEX_DATA = RES_DATA[27:24];
                3'd2: HEX_DATA = RES_DATA[23:20];
                3'd3: HEX_DATA = RES_DATA[19:16];
                3'd4: HEX_DATA = RES_DATA[15:12];
                3'd5: HEX_DATA = RES_DATA[11:8];
                3'd6: HEX_DATA = RES_DATA[7:4];
                3'd7: HEX_DATA = RES_DATA[3:0];
            endcase
        end
    end

    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state     <= ST_IDLE;
            TX_RDY_T  <= 1'b0;
            TX_DATA_T <= 8'h00;
            RES_RDY_R <= 1'b1;
            RES_CT    <= 3'b000;
            ADDR      <= 5'd0;
            END_ADDR  <= 5'd0;
            CMD       <= 4'd0;
            RES_ADDR  <= 16'd0;
            RES_DATA  <= 32'd0;
            RES_FLG   <= 1'b0;
            OPR2_FLG  <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (RES_RDY_T) begin
                        RES_RDY_R <= 1'b0;
                        
                        CMD       <= RES_DATA_R[51:48];
                        RES_ADDR  <= RES_DATA_R[47:32];
                        RES_DATA  <= RES_DATA_R[31:0];

                        RES_FLG   <= (RES_DATA_R[51:50] == 2'b01); 
                        
                        ADDR      <= ADDR_MX;
                        END_ADDR  <= END_ADDR_MX;
                        RES_CT    <= 3'b000;
                        OPR2_FLG  <= 1'b0;
                        state     <= ST_TRES;
                    end else begin
                        TX_RDY_T  <= 1'b0;
                        RES_RDY_R <= 1'b1;
                    end
                end

                ST_TRES: begin
                    TX_DATA_T <= DATA; 
                    TX_RDY_T  <= 1'b1;
                    ADDR      <= ADDR + 1'b1;
                    state     <= ST_TMEM;
                end

                ST_TMEM: begin
                    if (TX_RDY_R) begin
                        if (ADDR <= END_ADDR) begin
                            TX_DATA_T <= DATA;
                            ADDR      <= ADDR + 1'b1;
                        end else begin
                            if (RES_FLG) begin
                                TX_DATA_T <= CHAR_SPACE;
                                state     <= ST_TSP;
                            end else begin
                                TX_DATA_T <= CHAR_CR;
                                state     <= ST_TCR;
                            end
                        end
                    end
                end

                ST_TSP: begin
                    if (TX_RDY_R) begin
                        RES_FLG   <= 1'b0;
                        TX_DATA_T <= DC_ASCII_DATA;
                        RES_CT    <= RES_CT + 1'b1;
                        state     <= ST_TDT;
                    end
                end

                ST_TDT: begin
                    if (TX_RDY_R) begin
                        if (RES_CT == END_CT) begin
                            if (~OPR2_FLG) begin
                                TX_DATA_T <= CHAR_SPACE;
                                RES_CT    <= CT_MX;
                                OPR2_FLG  <= 1'b1;
                                state     <= ST_TSP;
                            end else begin
                                TX_DATA_T <= CHAR_CR;
                                OPR2_FLG  <= 1'b0;
                                state     <= ST_TCR;
                            end
                        end else begin
                            TX_DATA_T <= DC_ASCII_DATA;
                            RES_CT    <= RES_CT + 1'b1;
                        end
                    end
                end

                ST_TCR: begin
                    if (TX_RDY_R) begin
                        TX_DATA_T <= CHAR_LF;
                        state     <= ST_TLF;
                    end
                end

                ST_TLF: begin
                    if (TX_RDY_R) begin
                        TX_RDY_T  <= 1'b0;
                        RES_RDY_R <= 1'b1;
                        state     <= ST_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
