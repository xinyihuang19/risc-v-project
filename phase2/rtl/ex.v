`ifndef _EX_V_
`define _EX_V_
`include "phase2/rtl/defines.v"

module ex(
    // from id_ex
    input wire[31:0] inst_i,
    input wire[31:0] inst_addr_i,
    input wire[31:0] op1_i,
    input wire[31:0] op2_i,
    input wire[4:0] rd_addr_i,
    input wire reg_wen_i,
    // to regs
    output reg[4:0] rd_addr_o,
    output reg[31:0] rd_data_o,
    output reg rd_wen_o,
    // to ctrl
    output reg[31:0]    jump_addr_o,
    output reg          jump_en_o,
    output reg          hold_flag_o
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

   // branch offset
   // 立即数都应该是符号位扩展
   wire[31:0] jump_imm;
   assign jump_imm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
   wire op_i_equal_op2_i;
   assign op_i_equal_op2_i = (op1_i == op2_i)? 1'b1: 1'b0;  

    // 组合逻辑
    always @(*)begin
        case(opcode)
            `INST_TYPE_I: begin
                jump_addr_o = 32'b0;
                jump_en_o = 1'b0;
                hold_flag_o = 1'b0;
                case(func3)
                    `INST_ADDI:begin
                        rd_data_o = op1_i + op2_i;
                        rd_addr_o = rd_addr_i;
                        rd_wen_o = reg_wen_i;
                    end
                    default:begin
                        rd_data_o = 32'b0;
                        rd_addr_o = 5'b0;
                        rd_wen_o = 1'b0;
                    end
                endcase
            end
            
            `INST_TYPE_R_M: begin
                jump_addr_o = 32'b0;
                jump_en_o = 1'b0;
                hold_flag_o  = 1'b0;
                case(func3)
                    `INST_ADD_SUB:begin
                        if(func7 == 7'b0000000)begin // add
                            rd_data_o = op1_i + op2_i;
                            rd_addr_o = rd_addr_i;
                            rd_wen_o = reg_wen_i;
                        end
                        else begin // sub 
                            rd_data_o = op1_i - op2_i;
                            rd_addr_o = rd_addr_i;
                            rd_wen_o = reg_wen_i;
                        end
                    end
                    default:begin
                        rd_data_o = 32'b0;
                        rd_addr_o = 5'b0;
                        rd_wen_o = 1'b0;
                    end
                endcase
            end

            `INST_TYPE_B:begin
                // 给默认值，不返回寄存器
                rd_data_o = 32'b0;
                rd_addr_o = 5'b0;
                rd_wen_o = 1'b0;
                case(func3)
                    `INST_BEQ:begin
                        jump_addr_o = (inst_addr_i + jump_imm) & {32{(op_i_equal_op2_i)}}; // 应该扩展为32位再与
                        jump_en_o = op_i_equal_op2_i;
                        hold_flag_o = 1'b0;
                    end
                    `INST_BNE:begin
                        // 当op1 != op2时，返回0，～0就是1，就是以下地址生效
                        jump_addr_o = (inst_addr_i + jump_imm) & {32{(~op_i_equal_op2_i)}};
                        jump_en_o = ~op_i_equal_op2_i;
                        hold_flag_o = 1'b0;
                    end
                    default:begin
                        jump_addr_o = 32'b0;
                        jump_en_o = 1'b0;
                        hold_flag_o = 1'b0;
                    end
                endcase
            end
  
            `INST_JAL:begin
                rd_data_o = inst_addr_i + 32'd4;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
                jump_addr_o = op1_i + inst_addr_i;
                jump_en_o = 1'b1;
                hold_flag_o = 1'b0;
            end

            `INST_LUI:begin
                rd_data_o = op1_i;
                rd_addr_o = rd_addr_i;
                rd_wen_o = 1'b1;
                jump_addr_o = 32'b0;
                jump_en_o = 1'b0;
                hold_flag_o = 1'b0;
            end

            default:begin
                rd_data_o = 32'b0;
                rd_addr_o = 5'b0;
                rd_wen_o = 1'b0;
                jump_addr_o = 32'b0;
                jump_en_o = 1'b0;
                hold_flag_o = 1'b0;
            end
        endcase
    end


endmodule

`endif