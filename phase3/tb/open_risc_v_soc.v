`ifndef _OPEN_RISC_V_SOC_V_
`define _OPEN_RISC_V_SOC_V_

`include "phase3/rtl/rom.v"
`include "phase3/rtl/open_risc_v.v"

module open_risc_v_soc(
        input wire  clk,
        input wire  rst,
        input wire  debug,
        input wire  uart_rxd,
        output wire led1
);
    // open_risc_v to rom
    wire[31:0] open_risc_v_inst_addr_o;
    // rom to open_risc_v
    wire[31:0] rom_inst_o;

    // open_risc_v to ram
    wire        open_risc_v_mem_wr_req_o;
    wire[3:0]   open_risc_vmem_wr_sel_o;
    wire[31:0]  open_risc_v_mem_wr_addr_o;
    wire[31:0]  open_risc_v_mem_wr_data_o;
    wire        open_risc_v_mem_rd_req_o;
    wire[31:0]  open_risc_v_mem_rd_addr_o;
    // ram to open_risc_v
    wire[31:0]  ram_rd_data_o;
    // uart_debug to rom

    wire       uart_debug_ce;
    wire       uart_debug_wen;
    wire[31:0] uart_debug_addr_o;
    wire[31:0] uart_debug_data_o;

    assign led1 = open_risc_v_mem_wr_data_o[1];

    open_risc_v open_risc_v_inst(
        .clk            (clk),
        .rst            (rst),
        .inst_i         (rom_inst_o),
        .inst_addr_o    (open_risc_v_inst_addr_o)
    );

    rom rom_inst(
        .clk                 (clk)              ,
        .rst                 (rst)              ,
        .w_en                (uart_debug_wen)   , // 写端口    来自串口
        .w_addr_i            (uart_debug_addr_o),
        .w_data_i            (uart_debug_data_o),
        .r_en                (1'b1)             , // 指令读端口
        .r_addr_i            (open_risc_v_inst_addr_o),
        .r_data_o            (rom_inst_o)
    );  

endmodule
`endif