`ifndef _OPEN_RISC_V_SOC_V_
`define _OPEN_RISC_V_SOC_V_

<<<<<<< HEAD
`include "../rtl/rom.v"
`include "../rtl/open_risc_v.v"
=======
`include "phase2/rtl/rom.v"
`include "phase2/rtl/open_risc_v.v"
>>>>>>> a535b7641757e65c7b871fde8900367adac53034

module open_risc_v_soc(
        input wire  clk,
        input wire  rst 
);
    // open_risc_v to rom
    wire[31:0] open_risc_v_inst_addr_o;

    // rom to open_risc_v
    wire[31:0] rom_inst_o;

    open_risc_v open_risc_v_inst(
        .clk            (clk),
        .rst            (rst),
        .inst_i         (rom_inst_o),
        .inst_addr_o    (open_risc_v_inst_addr_o)
    );

    rom rom_inst(
        .inst_addr_i    (open_risc_v_inst_addr_o),
        .inst_o         (rom_inst_o)
    );

endmodule
`endif