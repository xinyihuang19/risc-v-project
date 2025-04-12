`ifndef _REGS_V_
`define _REGS_V_

module regs(
    // 为什么写入需要时钟？
        // 这些寄存器通常在时钟触发下被写入，因为数据写入需要有节奏地发生，避免混乱。
        // 在流水线 CPU 设计中，寄存器的写入通常在指令执行的某个阶段发生（例如 WB 写回阶段）。
        // 为了确保同步写入，每个时钟周期 posedge clk 时，写入操作才会执行。
        // 如果没有 clk，写入可能会在任何时刻发生，导致数据竞争和错误。
    input wire clk,
    input wire rst,
    // from id
    input wire[4:0] reg1_raddr_i,
    input wire[4:0] reg2_raddr_i,
    // to id
    output reg[31:0] reg1_rdata_o,
    output reg[31:0] reg2_rdata_o,
    // from ex
    input wire[4:0] reg_waddr_i,
    input wire[31:0] reg_wdata_i,
    input wire reg_wen
);

    reg[31:0] regs[0:31];
    integer i;

    always @(*)begin
        if(!rst)
            reg1_rdata_o <= 32'b0;
        else if(reg1_raddr_i == 5'b0)
            reg1_rdata_o <= 32'b0;
        // 指令冲突解决：如果读的地址和写的地址写的是同一个寄存器，那么我们可以把写的覆盖给读的数据
        else if(reg_wen && reg1_raddr_i == reg_waddr_i)
            reg1_rdata_o <= reg_wdata_i;
        else 
            reg1_rdata_o <= regs[reg1_raddr_i];
    end
    always @(*)begin
        if(rst == 1'b0)
            reg2_rdata_o <= 32'b0;
        else if(reg2_raddr_i == 5'b0)
            reg2_rdata_o <= 32'b0;
        else if(reg_wen && reg2_raddr_i == reg_waddr_i)
            reg2_rdata_o <= reg_wdata_i;
        else 
            reg2_rdata_o <= regs[reg2_raddr_i];
    end
    
    // 写使能
    always @(posedge clk)begin
        if(rst == 1'b0) begin
            for(i = 0; i < 32; i = i + 1)begin
                regs[i] <= 32'b0;
            end
        end
        // 当写使能时
        // 注意，不能写0寄存器，因为0寄存器是恒0的，硬件规则
        else if(reg_wen && reg_waddr_i != 5'b0)begin
            regs[reg_waddr_i] <= reg_wdata_i;
        end
    end

endmodule
`endif