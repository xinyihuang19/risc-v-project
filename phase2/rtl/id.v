`ifndef _ID_V_
`define _ID_V_
`include "phase2/rtl/defines.v"

module id(
    // from if_id
    input wire[31:0] inst_i         ,
    input wire[31:0] inst_addr_i    ,

    // to regs
    output reg[4:0] rs1_addr_o      ,
    output reg[4:0] rs2_addr_o      ,

    // from regs
    input wire[31:0] rs1_data_i     ,
    input wire[31:0] rs2_data_i     ,

    // to id_ex
    output reg[31:0] inst_o         ,
    output reg[31:0] inst_addr_o    ,
    output reg[31:0] op1_o          ,
    output reg[31:0] op2_o          ,
    // 为什么目的寄存器地址是[4:0]？
        // 在RISC-V架构中，有32个通用寄存器(x0-x31)。要表示32个不同的地址，需要5位二进制数：
        // 2^5 = 32，刚好能表示从0到31的所有可能值
        // 所以寄存器地址字段使用5位宽度[4:0]是足够的
        // 而其他信号如指令(inst_o)、指令地址(inst_addr_o)等需要32位宽度，因为它们存储的是完整的32位数据值。
    output reg[4:0] rd_addr_o       ,
    // 为什么reg_wen没有位宽指定？当一个信号没有明确指定位宽时，它默认为1位宽。
        // reg_wen是一个控制信号，表示"寄存器写使能"，它只需要表达两种状态：
            // 1：允许写入寄存器
            // 0：禁止写入寄存器
            // 所以只需要1位就足够了，不需要用[n:0]格式指定位宽。
    output reg reg_wen              ,
    output reg[31:0] base_addr_o   ,
    output reg[31:0] addr_offset_o
);

   wire[6:0]    opcode;
   wire[4:0]    rd;
   wire[2:0]    func3;
   wire[4:0]    rs1;
   wire[4:0]    rs2;  
   wire[11:0]   imm;
   wire[6:0]    func7;
   wire[4:0]    shamt;
   
   assign opcode = inst_i[6:0];
   assign rd = inst_i[11:7];
   assign func3 = inst_i[14:12];
   assign rs1 = inst_i[19:15];
   assign rs2 = inst_i[24:20];
   assign imm = inst_i[31:20];
   assign func7 = inst_i[31:25];
   assign shamt = inst_i[24:20];
   
   always @(*)begin
        // 无论怎么样，指令都要往下传
        inst_o          = inst_i;
        inst_addr_o     = inst_addr_i;
        
        // ADDI
        case(opcode)
        `INST_TYPE_I: begin
            base_addr_o    = 32'b0;
            addr_offset_o   = 32'b0;
            case(func3)
            `INST_ADDI,`INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI:begin
                rs1_addr_o = rs1;
                rs2_addr_o = 5'b0;
                op1_o      = rs1_data_i;
                // 立即数要进行符号位拓展: imm[11]是符号位，拓宽到32位，然后和imm拼接。由于imm有12位，所以是{20{imm[11]},imm}
                op2_o      = {{20{imm[11]}},imm};
                rd_addr_o  = rd;
                reg_wen    = 1'b1;
            end
            `INST_SLLI, `INST_SRI:begin
                rs1_addr_o = rs1;
                rs2_addr_o = 5'b0;
                op1_o      = rs1_data_i;
                op2_o      = {27'b0, shamt};
                rd_addr_o  = rd;
                reg_wen    = 1'b1;
            end
            default:begin
                rs1_addr_o = 5'b0;
                rs2_addr_o = 5'b0;
                op1_o      = 32'b0;
                // 立即数要进行符号位拓展
                op2_o      = 32'b0;
                rd_addr_o  = 5'b0;
                reg_wen    = 1'b0;
            end
            endcase
        end

        // ADD/SUB
        `INST_TYPE_R_M:begin
            base_addr_o     = 32'b0;
            addr_offset_o   = 32'b0;
            case(func3) 
                `INST_ADD_SUB, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_OR, `INST_AND:begin
                    rs1_addr_o = rs1;
                    rs2_addr_o = rs2;
                    op1_o      = rs1_data_i;
                    op2_o      = rs2_data_i;
                    rd_addr_o  = rd;
                    reg_wen    = 1'b1;
                end
                `INST_SLL, `INST_SR:begin
                    rs1_addr_o = rs1;
                    rs2_addr_o = rs2;
                    op1_o      = rs1_data_i;
                    op2_o      = {27'b0, rs2_data_i[4:0]}; // 不能移超过五位
                    rd_addr_o  = rd;
                    reg_wen    = 1'b1;
                end
                default:begin
                    rs1_addr_o = 5'b0;
                    rs2_addr_o = 5'b0;
                    op1_o      = 32'b0; 
                    op2_o      = 32'b0;
                    rd_addr_o  = 5'b0;
                    reg_wen    = 1'b0;
                end
            endcase 
        end

        `INST_TYPE_B:begin
            case(func3)
                `INST_BNE, `INST_BEQ, `INST_BLT, `INST_BGEU, `INST_BLTU, `INST_BGE:begin
                    rs1_addr_o = rs1;
                    rs2_addr_o = rs2;
                    op1_o      = rs1_data_i;
                    op2_o      = rs2_data_i;
                    rd_addr_o  = 5'b0;
                    reg_wen    = 1'b0;
                    base_addr_o     = inst_addr_i;
                    addr_offset_o   = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
                default:begin
                    rs1_addr_o = 5'b0;
                    rs2_addr_o = 5'b0;
                    op1_o      = 32'b0;
                    op2_o      = 32'b0;
                    rd_addr_o  = 5'b0;
                    reg_wen    = 1'b0; // 不回写所以是0
                    base_addr_o     = 32'b0;
                    addr_offset_o   = 32'b0;
                end
            endcase
        end

        `INST_JAL:begin
            rs1_addr_o = 5'b0;
            rs2_addr_o = 5'b0;
            op1_o      = inst_addr_i;
            op2_o      = 32'h4;
            rd_addr_o  = rd;
            reg_wen    = 1'b1;
            base_addr_o     = inst_addr_i;
            addr_offset_o   = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end

        `INST_JALR:begin
            rs1_addr_o = rs1;
            rs2_addr_o = 5'b0;
            op1_o      = inst_addr_i;
            op2_o      = 32'h4;
            rd_addr_o  = rd;
            reg_wen    = 1'b1;
            base_addr_o     = rs1_data_i;
            addr_offset_o   = {{20{imm[11]}}, imm};
        end


        `INST_LUI:begin
            rs1_addr_o = 5'b0;
            rs2_addr_o = 5'b0;
            op1_o      = {inst_i[31:12], 12'b0};
            op2_o      = 32'b0;
            rd_addr_o  = rd;
            reg_wen    = 1'b1;
            base_addr_o     = 32'b0;
            addr_offset_o   = 32'b0;
        end

        `INST_AUIPC:begin
            rs1_addr_o = 5'b0;
            rs2_addr_o = 5'b0;
            op1_o      = {inst_i[31:12], 12'b0};
            op2_o      = inst_addr_i;   
            rd_addr_o  = rd;
            reg_wen    = 1'b1;
            base_addr_o     = 32'b0;
            addr_offset_o   = 32'b0;
        end

        default: begin
            rs1_addr_o = 5'b0;
            rs2_addr_o = 5'b0;
            op1_o      = 32'b0;
            // 立即数要进行符号位拓展
            op2_o      = 32'b0;
            rd_addr_o  = 5'b0;
            reg_wen    = 1'b0;
            base_addr_o     = 32'b0;
            addr_offset_o   = 32'b0;
        end
        endcase
   end

endmodule

`endif