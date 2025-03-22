`ifndef _OPEN_RISC_V_V_
`define _OPEN_RISC_V_V_

// 必须将defines.v放在其他包含之前，因为其他模块可能依赖于它的定义
`include "phase1/rtl/defines.v"
`include "phase1/rtl/pc_reg.v"
`include "phase1/rtl/ifetch.v"
`include "phase1/rtl/if_id.v"
`include "phase1/rtl/id.v"
`include "phase1/rtl/regs.v"
`include "phase1/rtl/id_ex.v"
`include "phase1/rtl/ex.v"
`include "phase1/rtl/dff_set.v"

module open_risc_v(
    input wire           clk   ,
    input wire           rst ,
    // from rom
    input wire[31:0]     inst_i,
    // to rom
    output wire[31:0]    inst_addr_o
);

    // pc to if
    wire[31:0] pc_reg_pc_o;

    // if to if_id
    wire[31:0] if_inst_addr_o;
    wire[31:0] if_inst_o;

    // if_id to id
    wire[31:0] if_id_inst_addr_o;
    wire[31:0] if_id_inst_o;

     // id to regs
    wire[4:0] id_rs1_addr_o;
    wire[4:0] id_rs2_addr_o;

    // id to id_ex
    wire[31:0]  id_inst_o;
    wire[31:0]  id_inst_addr_o;
    wire[31:0]  id_op1_o;
    wire[31:0]  id_op2_o;
    wire[4:0]   id_rd_addr_o;
    wire        id_reg_wen_o;

    // ex to regs
    wire[31:0]  ex_rd_data_o;
    wire[4:0]   ex_rd_addr_o;
    wire        ex_reg_wen_o;

    // regs to id
    wire[31:0] regs_rs1_id_rdata_o;
    wire[31:0] regs_rs2_id_rdata_o;

     // id_ex to ex
    wire[31:0]  id_ex_inst_o;
    wire[31:0]  id_ex_inst_addr_o;
    wire[31:0]  id_ex_op1_o;
    wire[31:0]  id_ex_op2_o;
    wire[4:0]   id_ex_rd_addr_o;
    wire        id_ex_reg_wen_o;


    pc_reg pc_reg_inst( 
        .clk  (clk), 
        .rst  (rst), 
        .pc_o (pc_reg_pc_o)
    );  

    ifetch ifetch_inst(
      .pc_addr_i    (pc_reg_pc_o),
      .rom_inst_i   (inst_i),
      .if2rom_addr_o(inst_addr_o),
      .inst_addr_o  (if_inst_addr_o),
      .inst_o       (if_inst_o)
    ); 

    if_id if_id_inst(
        .clk         (clk),
        .rst         (rst),
        .inst_addr_i (if_inst_addr_o),
        .inst_i      (if_inst_o),
        .inst_addr_o (if_id_inst_addr_o),
        .inst_o      (if_id_inst_o)
    );

    id id_inst(
      .inst_i     (if_id_inst_o),
      .inst_addr_i(if_id_inst_addr_o),
      .rs1_addr_o (id_rs1_addr_o),
      .rs2_addr_o (id_rs2_addr_o),
      .rs1_data_i (regs_rs1_id_rdata_o),
      .rs2_data_i (regs_rs2_id_rdata_o),
      .inst_o     (id_inst_o),
      .inst_addr_o(id_inst_addr_o),
      .op1_o      (id_op1_o),
      .op2_o      (id_op2_o),
      .rd_addr_o  (id_rd_addr_o),
      .reg_wen    (id_reg_wen_o)
    );

    regs regs_inst(
        .clk          (clk),
        .rst          (rst),
        .reg1_raddr_i (id_rs1_addr_o),
        .reg2_raddr_i (id_rs2_addr_o),
        .reg1_rdata_o (regs_rs1_id_rdata_o),
        .reg2_rdata_o (regs_rs2_id_rdata_o),
        .reg_waddr_i  (ex_rd_addr_o),
        .reg_wdata_i  (ex_rd_data_o),
        .reg_wen      (ex_reg_wen_o)
    );  

    id_ex id_ex_inst(
    .clk        (clk),
    .rst        (rst),
    .inst_i     (id_inst_o),
    .inst_addr_i(id_inst_addr_o),
    .op1_i      (id_op1_o),
    .op2_i      (id_op2_o),
    .rd_addr_i  (id_rd_addr_o),
    .reg_wen_i  (id_reg_wen_o),
    .inst_o     (id_ex_inst_o),
    .inst_addr_o(id_ex_inst_addr_o),
    .op1_o      (id_ex_op1_o),
    .op2_o      (id_ex_op2_o),
    .rd_addr_o  (id_ex_rd_addr_o),
    .reg_wen_o  (id_ex_reg_wen_o)
    );

    ex ex_inst(
    .inst_i         (id_ex_inst_o),
    .inst_addr_i    (id_ex_inst_addr_o),
    .op1_i          (id_ex_op1_o),
    .op2_i          (id_ex_op2_o),
    .rd_addr_i      (id_ex_rd_addr_o),
    .reg_wen_i      (id_ex_reg_wen_o),
    .rd_addr_o      (ex_rd_addr_o),
    .rd_data_o      (ex_rd_data_o),
    .rd_wen_o       (ex_reg_wen_o)
    );

endmodule

`endif
