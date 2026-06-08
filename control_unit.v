`timescale 1ns/1ns
module control_single( opcode, funct, RegDst, ALUSrc, RegWrite,
                       MemRead, MemWrite, Branch, Jump, JumpReg, MemtoReg, ALUOp );
    input [5:0] opcode;
    input [5:0] funct;
    output RegDst, ALUSrc, RegWrite, MemRead, MemWrite, Branch, Jump, JumpReg, MemtoReg;
    output [1:0] ALUOp;
    reg RegDst, ALUSrc, RegWrite, MemRead, MemWrite, Branch, Jump, JumpReg, MemtoReg;
    reg [1:0] ALUOp;

    parameter R_FORMAT = 6'd0;
    parameter LW   = 6'd35;
    parameter SW   = 6'd43;
    parameter BEQ  = 6'd4;
    parameter J    = 6'd2;
    parameter SLTI = 6'd10;
    parameter F_JR    = 6'd8;
    parameter F_NOP   = 6'd0;
    parameter F_MULTU = 6'd25;

    always @( opcode or funct )
    begin
        case ( opcode )
          R_FORMAT :
          begin
            if ( funct == F_NOP )
            begin
              RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
              Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b00;
            end
            else if ( funct == F_JR )
            begin
              RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
              Branch=1'b0; Jump=1'b0; JumpReg=1'b1; MemtoReg=1'b0; ALUOp=2'b10;
            end
            else if ( funct == F_MULTU )
            begin
              RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
              Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b10;
            end
            else
            begin
              RegDst=1'b1; ALUSrc=1'b0; RegWrite=1'b1; MemRead=1'b0; MemWrite=1'b0;
              Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b10;
            end
          end
          LW :
          begin
            RegDst=1'b0; ALUSrc=1'b1; RegWrite=1'b1; MemRead=1'b1; MemWrite=1'b0;
            Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b1; ALUOp=2'b00;
          end
          SW :
          begin
            RegDst=1'b0; ALUSrc=1'b1; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b1;
            Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b00;
          end
          BEQ :
          begin
            RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
            Branch=1'b1; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b01;
          end
          J :
          begin
            RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
            Branch=1'b0; Jump=1'b1; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b00;
          end
          SLTI :
          begin
            RegDst=1'b0; ALUSrc=1'b1; RegWrite=1'b1; MemRead=1'b0; MemWrite=1'b0;
            Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b11;
          end
          default :
          begin
            RegDst=1'b0; ALUSrc=1'b0; RegWrite=1'b0; MemRead=1'b0; MemWrite=1'b0;
            Branch=1'b0; Jump=1'b0; JumpReg=1'b0; MemtoReg=1'b0; ALUOp=2'b00;
          end
        endcase
    end
endmodule
