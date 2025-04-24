`ifndef _IF_ID_V_
`define _IF_ID_V_

`include "phase1/rtl/defines.v"  // 当前目录
`include "phase1/rtl/dff_set.v"

module if_id(
    input wire clk,
    input wire rst,
    input wire[31:0] inst_addr_i,
    input wire[31:0] inst_i,
    
    output wire[31:0] inst_addr_o,
    output wire[31:0] inst_o

);


// 补充：
    // 触发器(Flip-Flop)是数字电路中的基本存储元件，它能够存储一位二进制信息(0或1)并保持这个值，直到接收到改变状态的
    // 在处理器设计中，触发器是构建寄存器、计数器和各种时序控制电路的基础。例如，程序计数器(PC)寄存器实际上是由多个D触发器组成的，每个触发器存储地址的一位。
    // 在之前的代码中，always @(posedge clk)块描述的就是由时钟上升沿触发的D触发器行为。当时钟从0变为1时，触发器会更新其存储的值。

    dff_set #(32) dff1(clk, rst, `INST_NOP, inst_i, inst_o);
    // 报错：cannot be driven by primitives or continuous assignment.Icarus Verilog(iverilog)
        // 原因：这个错误发生是因为在if_id模块中，您同时使用了两种不同的方式来驱动inst_o信号：
        // 您将inst_o声明为output reg，这意味着它应该在if_id模块内的always块中被赋值
        // 但是您又通过实例化dff_set模块并将其输出连接到inst_o，这相当于另一种驱动方式
        // 在Verilog中，一个信号只能有一个驱动源。当您声明output reg时，
        // 编译器期望这个信号由模块内部的过程块(如always块)驱动，而不是由子模块的输出驱动。
    // 解决方案：1. 使用实例化方式（推荐），但将输出修改为wire类型 2. 保持输出为reg类型，但移除dff_set实例化，直接在if_id模块内部用always块
    dff_set #(32) dff2(clk, rst, 32'b0, inst_addr_i, inst_addr_o);

endmodule 

`endif