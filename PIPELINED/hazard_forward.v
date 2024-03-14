module hazard_forward(
    input [4:0] id_ex_rs1, id_ex_rs2,
    input ex_mem_wb, mem_wb_wb,
    input [4:0] ex_mem_rd, mem_wb_rd,
    input [6:0] instr_opcode,   // itype_r instruction's rs2 not considerred. 

    output reg [1:0] forwardingA, forwardingB

    // input ex_no_rs2, mem_no_rs2
    // output reg rd2_sel
);
// reg flag, flagu;
always @* begin
    // if (instr_opcode == 7'b0110111)flagu=1'b1;
    // else flagu = 1'b0;   // not consider read data 1 when lui
    
    // if ((instr_opcode == 7'b0110111)|| (instr_opcode == 7'b0000011))flag=1'b1;
    // else flag = 1'b0;   // not consider read data 2 when I-type or lui

    forwardingA = 2'b00;
    forwardingB = 2'b00;    // default
    
    if (mem_wb_wb && (mem_wb_rd != 5'b00000)) begin
        // mem -> ex
        if ((id_ex_rs1 == mem_wb_rd) /*&& !flagu*/) forwardingA = 2'b01;
        if ((id_ex_rs2 == mem_wb_rd) /*&& !flag*/) forwardingB = 2'b01;
    end
    if (ex_mem_wb && (ex_mem_rd != 5'b00000)) begin
        // ex -> ex
        if ((id_ex_rs1 == ex_mem_rd) /*&& !flagu*/) forwardingA = 2'b10;
        if ((id_ex_rs2 == ex_mem_rd) /*&&!flag*/) forwardingB = 2'b10;
    end
    
    // EX->EX forwarding is superior than MEM->EX
end

endmodule