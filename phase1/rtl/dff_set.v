// 这个代码被称为 “打拍”（Register Staging 或 Flop Staging），主要是因为它的作用是在时钟沿（posedge clk）触发时，
// 将输入数据 data_i 传递到输出 data_o，并在复位时赋予特定的初始值 set_data。
`ifndef _DFF_SET_V_
`define _DFF_SET_V_

module dff_set #(parameter DW = 32)
(
    input wire clk, 
    input wire rst,
    input wire[DW - 1:0] set_data,
    input wire[DW - 1:0] data_i,
    output reg[DW - 1:0] data_o
);

    always @(posedge clk)begin
        if(rst == 1'b0)
            data_o <= set_data; // NOP指令，无作为
        else
            data_o <= data_i;
    end

endmodule
`endif