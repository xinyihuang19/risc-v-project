`ifndef _ROM_V_
`define _ROM_V_
`include "phase3/utils/dual_ram.v"

module rom(
    input wire clk                  ,
    input wire rst                  ,
    input wire w_en                 , // 写端口
    input wire[12-1:0]  w_addr_i    ,
    input wire[32-1:0]  w_data_i    ,
    input wire          r_en        , // 读端口
    input wire[12-1:0]  r_addr_i    ,
    output wire[32-1:0] r_data_o
);

    wire[11:0] w_addr = w_addr_i[13:2];
    wire[11:0] r_addr = r_addr_i[13:2];

dual_ram #(
    .DW (32),
    .AW (12),
    .MEM_NUM (4096)
)rom_mem(
    .clk        (clk),
    .rst        (rst),
    .w_en       (w_en),
    .w_addr_i   (w_addr_i),
    .w_data_i   (w_data_i),
    .r_en       (r_en),
    .r_addr_i   (r_addr_i),
    .r_data_o   (r_data_o)
);

endmodule
`endif