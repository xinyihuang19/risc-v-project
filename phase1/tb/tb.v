`ifndef _TB_V_
`define _TB_V_

`include "phase1/tb/open_risc_v_soc.v"

module tb();
    reg clk;
    reg rst;

    open_risc_v_soc open_risc_v_soc_inst(
        .clk    (clk),
        .rst  (rst)
    );

    //always #10 clk = ~clk;
        // 这行创建了一个周期性的时钟信号
        // #10表示延迟10个时间单位（可能是ns或ps，取决于您的仿真设置）
        // clk = ~clk表示将时钟信号取反，从低到高或从高到低翻转
            // 开始时，clk被设置为1
                // 等待10个时间单位
                // clk变为0
                // 再等待10个时间单位
                // clk变回1
                // 重复这个过程...
        // 整体效果是创建一个周期为20个时间单位的时钟信号（每10个单位翻转一次）
    always #10 clk = ~clk;
    initial begin
        clk <= 1'b1;
        // 将复位信号初始化为0（低电平，通常表示处于复位状态）
        rst <= 1'b0;
        #30
        // 当系统开始仿真时（rst = 0，即处于复位状态），芯片内部的各个组件会根据设计中的复位逻辑进入初始状态。在此期间，系统并不是在"工作"，而是在"被复位"。
            // 这30个时间单位的等待是为了：
                // 确保复位完全生效：给所有组件足够的时间响应复位信号并完成初始化
                // 时钟稳定：让时钟信号先运行几个周期（如果时钟周期是20个单位，那么30个单位大约是1.5个周期）
                // 仿真设置：让仿真工具和波形观察器有足够的时间设置好
                // 在这30个时间单位里，系统中的组件会响应复位信号：
                // 程序计数器可能会被设为起始地址
                // 寄存器会被清零或设置为初值
                // 状态机会回到初始状态
                // 其他控制信号会设为默认值

            // 只有当rst变为1后（即退出复位状态），系统才会开始正常的运算和处理指令。这种设计确保了系统从一个确定的状态开始运行，避免了由于随机初始状态导致的不确定行为。
        rst <= 1'b1;
    end 

    // rom 初始值
    initial begin
        // $readmemb("phase1/tb/inst_data_ADD.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
        $readmemb("phase1/tb/inst_data_ADD.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
    end

    initial begin
        while(1)begin
            @(posedge clk)
            $display("x27 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
            $display("x28 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
            $display("x29 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
            $display("---------------------------");
        end
    end

    initial begin
    #1000; 
    $display("Simulation ended by timeout");
    $finish;
    end

    initial begin
        $dumpfile("tb.vcd");  // 指定波形输出文件名
        $dumpvars(0, tb);  // 指定要记录波形的模块，tb是顶层模块名
    end

endmodule
`endif