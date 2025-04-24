`ifndef _RAM_V_
`define _RAM_V_
`include "phase3/utils/dual_ram.v"

module ram(
    input wire clk                  ,
    input wire rst                  ,
    input wire[3:0] wen             , // 写端口
    input wire[32-1:0] w_addr_i     ,
    input wire[32-1:0] w_data_i     ,
    input wire         r_en         , // 读端口
    input wire[32-1:0] r_addr_i     ,
    output wire[32-1:0]r_data_o     
);

    wire[11:0] w_addr = w_addr_i[13:2];
    wire[11:0] r_addr = r_addr_i[13:2];

    // 字节0
    dual_ram #(
        .DW (8),
        .AW (12),
        .MEM_NUM (4096)
    )
    ram_byte0
    (
        .clk        (clk),
        .rst        (rst),
        .w_en        (wen[0]),
        .w_addr_i   (w_addr),
        .w_data_i   (w_data_i[7:0]),
        .r_en       (r_en),
        .r_addr_i   (r_addr),
        .r_data_o   (r_data_o[7:0])
    );

    // 字节1
    dual_ram #(
        .DW (8),
        .AW (12),
        .MEM_NUM (4096)
    )
    ram_byte1
    (
        .clk        (clk),
        .rst        (rst),
        .w_en        (wen[1]),
        .w_addr_i   (w_addr),
        .w_data_i   (w_data_i[15:8]),
        .r_en       (r_en),
        .r_addr_i   (r_addr),
        .r_data_o   (r_data_o[15:8])
    );

    // 字节2
    dual_ram #(
        .DW (8),
        .AW (12),
        .MEM_NUM (4096)
    )
    ram_byte2
    (
        .clk        (clk),
        .rst        (rst),
        .w_en        (wen[2]),
        .w_addr_i   (w_addr),
        .w_data_i   (w_data_i[23:16]),
        .r_en       (r_en),
        .r_addr_i   (r_addr),
        .r_data_o   (r_data_o[23:16])
    );

    // 字节3
    dual_ram #(
        .DW (8),
        .AW (12),
        .MEM_NUM (4096)
    )
    ram_byte3
    (
        .clk        (clk),
        .rst        (rst),
        .w_en        (wen[3]),
        .w_addr_i   (w_addr),
        .w_data_i   (w_data_i[31:24]),
        .r_en       (r_en),
        .r_addr_i   (r_addr),
        .r_data_o   (r_data_o[31:24])
    );




endmodule
`endif