`ifndef _TB_V_
`define _TB_V_

<<<<<<< HEAD
`include "../tb/open_risc_v_soc.v"
=======
`include "phase2/tb/open_risc_v_soc.v"
>>>>>>> a535b7641757e65c7b871fde8900367adac53034

module tb();
    reg clk;
    reg rst;

    open_risc_v_soc open_risc_v_soc_inst(
        .clk    (clk),
        .rst    (rst)
    );

    wire x3 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
    wire x26 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[26];
    wire x27 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27];
    integer r;

    always #10 clk = ~clk;
    initial begin
        clk <= 1'b1;
        rst <= 1'b0;
        #30
        rst <= 1'b1;
    end 

    // rom 初始值
    initial begin

        // 因为官方文件是16进制的，要把reademb改为readmemh
<<<<<<< HEAD
        $readmemh("./generated/inst_data.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
=======
        $readmemh("phase2/tb/inst_txt/rv32ui-p-xor.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
>>>>>>> a535b7641757e65c7b871fde8900367adac53034
    end

    initial begin
        wait(x26); // 当x26 = 1时，程序结束，运行完毕

        #200; // 在dump文件中，s10为1的时候，s11还没有置1，至少要延时一个周期才行，这样s11才能打印1

        // 无论通过或失败，都显示关键寄存器的值
        $display("x3 = %h (%d decimal)", x3, x3);
        $display("x26 = %h (%d decimal)", x26, x26);
        $display("x27 = %h (%d decimal)", x27, x27);

        if(x27 == 32'b1)begin
            $display("##############################");
            $display("########## pass !!!!##########");
            $display("##############################");
        end
        else begin
            $display("##############################");
            $display("########## fail !!!!##########");
            $display("##############################");
            $display("fail testnum = %2d", x3);
            for(r = 0; r < 31; r = r + 1)begin
                $display("x%2d register value is %d", r, tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);
            end
        end
<<<<<<< HEAD
        $finish();
=======
        $finish;
>>>>>>> a535b7641757e65c7b871fde8900367adac53034
    end

    initial begin
    #200; 
    end

    initial begin
        $dumpfile("tb.vcd");  // 指定波形输出文件名
        $dumpvars(0, tb);  // 指定要记录波形的模块，tb是顶层模块名
    end

endmodule
`endif