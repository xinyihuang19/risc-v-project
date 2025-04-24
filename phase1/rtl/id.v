`ifndef _ID_V_
`define _ID_V_
`include "phase1/rtl/defines.v"

module id(
    // from if_id
    input wire[31:0] inst_i,
    input wire[31:0] inst_addr_i,

    // to regs
    output reg[4:0] rs1_addr_o,
    output reg[4:0] rs2_addr_o,

    // from regs
    input wire[31:0] rs1_data_i,
    input wire[31:0] rs2_data_i,

    // to id_ex
    output reg[31:0] inst_o,
    output reg[31:0] inst_addr_o,
    output reg[31:0] op1_o,
    output reg[31:0] op2_o,
    // 为什么目的寄存器地址是[4:0]？
        // 在RISC-V架构中，有32个通用寄存器(x0-x31)。要表示32个不同的地址，需要5位二进制数：
        // 2^5 = 32，刚好能表示从0到31的所有可能值
        // 所以寄存器地址字段使用5位宽度[4:0]是足够的
        // 而其他信号如指令(inst_o)、指令地址(inst_addr_o)等需要32位宽度，因为它们存储的是完整的32位数据值。
    output reg[4:0] rd_addr_o,
    // 为什么reg_wen没有位宽指定？当一个信号没有明确指定位宽时，它默认为1位宽。
        // reg_wen是一个控制信号，表示"寄存器写使能"，它只需要表达两种状态：
            // 1：允许写入寄存器
            // 0：禁止写入寄存器
            // 所以只需要1位就足够了，不需要用[n:0]格式指定位宽。
    output reg reg_wen
);

   wire[6:0] opcode;
   wire[4:0] rd;
   wire[2:0] func3;
   wire[4:0] rs1;
   wire[4:0] rs2;  
   wire[11:0] imm;
   wire[6:0] func7;
   
   assign opcode = inst_i[6:0];
   assign rd = inst_i[11:7];
   assign func3 = inst_i[14:12];
   assign rs1 = inst_i[19:15];
   assign rs2 = inst_i[24:20];
   assign imm = inst_i[31:20];
   assign func7 = inst_i[31:25];
   
   always @(*)begin
        // 无论怎么样，指令都要往下传
        inst_o = inst_i;
        inst_addr_o = inst_addr_i;
        
        // ADDI
        case(opcode)
        `INST_TYPE_I: begin
            case(func3)
            `INST_ADDI:begin
                rs1_addr_o = rs1;
                rs2_addr_o = 5'b0;
                op1_o      = rs1_data_i;
                // 立即数要进行符号位拓展: imm[11]是符号位，拓宽到32位，然后和imm拼接。由于imm有12位，所以是{20{imm[11]},imm}
                op2_o      = {{20{imm[11]}},imm};
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
            case(func3) 
                `INST_ADD_SUB:begin
                    rs1_addr_o = rs1;
                    rs2_addr_o = rs2;
                    op1_o      = rs1_data_i;
                    op2_o      = rs2_data_i;
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
        default: begin
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

endmodule

`endif