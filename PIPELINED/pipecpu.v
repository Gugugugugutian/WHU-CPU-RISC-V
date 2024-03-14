`include "ctrl_encode_def.v"

module pipecpu(
    input clk, rst,
    input [31:0] inst, data_from_dm,

    output    dm_write,
    output [31:0] PC_out, 

    output [31:0] Addr_out,     // read/write memory address
    output [31:0] Data_out,     // data to data memory
    output [2:0] DMType,        // data memory type control
    
    output CPU_MIO,
    input INT, MIO_ready,
    
    output [31:0] pcW
);
// datas
wire [31:0] data_from_rs1, data_from_rs2;
wire [31:0] immgen_out, imm_from_id, imm_from_ex;
wire [31:0] rd1_from_id, rd2_from_id, rd2_from_mem; 
wire [31:0] data_from_mem, data_from_alu;
wire [31:0] WD;

// pc relative
wire [31:0] next_pc, if_id_pc ,id_ex_pc, ex_mem_pc, mem_wb_pc;//, branch_pc, jump_pc;
wire [31:0] branch_dest, jump_dest, jalr_dest;

// instructions and signals
wire [31:0] inst_from_if;
wire [31:0] inst_from_id;
wire [31:0] inst_from_ex;
wire [31:0] inst_from_mem;
wire [21:0] sigs_by_id;   // signals from id stage
wire [21:0] sigs_from_id;   // signals from id stage
wire [21:0] sigs_from_ex;
wire [21:0] sigs_from_mem;

wire mem_Zero;

// global signals
wire [1:0] forwardingA, forwardingB;
wire stall; // PC not update, 
wire jump;  // clear 3 stage registers (IF/ID, ID/EX, EX/MEM)
wire branch = sigs_from_ex[12] & mem_Zero;  // branch taken: NPCOp[0] & Zero, also clear 3 registers. 

// jump and branch
assign branch_dest = ex_mem_pc + imm_from_ex; // branch address
assign jump_dest = imm_from_ex + ex_mem_pc; // jump (I type) address
assign jalr_dest = Addr_out; // jalr address

wire alu_zero;
// alu arguments
wire [31:0] alu_result;
// wire [31:0] alu_opB = (sigs_from_id[15]) ? imm_from_id : rd2_from_id;  // ALU's second oprand

// forwarding implementation
wire [31:0] alu_A, alu_B, rd2_to_MEM;
mux4 rd2_selection (
    .signal(forwardingB),
    .d0(rd2_from_id),   // default 
    .d1(WD),        // mem -> ex
    .d2(Addr_out),
    .d3(Addr_out),     // ex -> ex
    .do(rd2_to_MEM)
);
mux4 alu_selA(
    .signal(forwardingA),
    .d0(rd1_from_id),
    .d1(WD),
    .d2(Addr_out),
    .d3(0),
    .do(alu_A)
);
mux2 alu_selB(
    .sig((sigs_from_id[21] | sigs_from_id[15])),
    .d0(rd2_to_MEM),
    .d1(imm_from_id),
    .do(alu_B)
);

wire ctrl_itype_l, id_ex_memread;
//wire [31:0] mid_data_to_regfile;

// STALL ONE CYCLE
wire [31:0] sel_pc;
wire [31:0] inst_to_if_id_register, inst_to_id;

wire [6:0] inst_opcode = inst[6:0];
wire j_fetch = ((inst_opcode == 7'b1100111)||(inst_opcode == 7'b1101111))? 1: 0;

// When jump or branch taken, clear 3 stage registers.
wire clear_signal;
assign clear_signal = ( jump | branch )?  1: 0;
//wire stall_j;
//assign stall_j = stall | clear_signal;  // stall because of jump or branch


// when stall, next pc is pc
mux2 next_pc_sel (
    .sig(stall),
    .d0(next_pc),
    .d1(PC_out),
    .do(sel_pc)
);
// when stall, input inst to IF/ID register 
// is from last IF/ID register. 
// mux4 stage_register_input_sel (
//     .signal({1'b0 ,(stall)}),
//     .d0(inst),
//     .d1(inst_from_if),    // instruction backward
//     .d2(32'h00000013),
//     .d3(32'h00000013),
//     .do(inst_to_if_id_register)
// );
// when stall, instruction to id stage is nop, IF/ID register not updates. 
mux2 stage_register_input_sel(
    .sig(stall),
    .d0(inst),
    .d1(inst_to_id),
    .do(inst_to_if_id_register)
);
mux2 stage_ID_inst_sel (
    .sig(stall),
    .d0(inst_to_id),
    .d1(32'h00000013),
    .do(inst_from_if)
);

// PC
PC u1_pc(
    .clk(clk), .rst(rst),
    .NPC(sel_pc), 
    .PC(PC_out)     //  pc output
);


// if/id regester
StageR u1_2(
    .clk(clk), .rst(rst),
    .flush(clear_signal),
    .in1(inst_to_if_id_register), .out1(inst_to_id), 
    .in2(PC_out), .out2(if_id_pc)
    //.in3({31'b0, j_fetch}), .out3(id_jump)
);
// id/ex regester
StageR u2_3(
    .flush(clear_signal),
    .clk(clk), .rst(rst),
    .in1({31'b0, ctrl_itype_l}), .out1(id_ex_memread),
    .in2({10'b0, sigs_by_id[21:0]}), .out2(sigs_from_id),
    .in3(immgen_out), .out3(imm_from_id),
    .in4(data_from_rs1), .out4(rd1_from_id),
    .in5(data_from_rs2), .out5(rd2_from_id),
    .in6(inst_from_if), .out6(inst_from_id), 
    .in7(if_id_pc), .out7(id_ex_pc)
    // .in({ctrl_itype_l ,sigs_by_id, immgen_out, data_from_rs1, data_from_rs2, inst_from_if, if_id_pc}),
    // .out({id_ex_memread ,sigs_from_id, imm_from_id, rd1_from_id, rd2_from_id, inst_from_id, id_ex_pc})
);
// ex/mem regester
assign dm_write = sigs_from_ex[21];
assign DMType = sigs_from_ex[18:16];

StageR u3_4(
    .flush(clear_signal),
    .clk(clk), .rst(rst),
    .in1({31'b0, alu_zero}), .out1(mem_Zero),
    .in2({10'b0, sigs_from_id[21:0]}), .out2(sigs_from_ex),
    .in3(alu_result), .out3(Addr_out),
    .in4(imm_from_id), .out4(imm_from_ex),
    .in5(id_ex_pc), .out5(ex_mem_pc),
    .in6(inst_from_id), .out6(inst_from_ex),
    .in7(rd2_to_MEM), .out7(Data_out)
    // .in({alu_zero, sigs_from_id, alu_result,  alu_opB, imm_from_id, id_ex_pc, inst_from_id}),
    // .out({mem_Zero, sigs_from_ex, Addr_out,  Data_out, imm_from_ex, ex_mem_pc, inst_from_ex})
);

// mem/wb regester
StageR u4_5(
    .flush(0),
    .clk(clk), .rst(rst),
    .in1({10'b0, sigs_from_ex}), .out1(sigs_from_mem),
    .in2(data_from_dm), .out2(data_from_mem),
    .in3(Addr_out), .out3(data_from_alu),
    .in4(inst_from_ex), .out4(inst_from_mem),
    .in5(ex_mem_pc), .out5(mem_wb_pc),
    .in6(Data_out), .out6(rd2_from_mem)
    // .in({sigs_from_ex, Data_in, Addr_out, ex_mem_pc, inst_from_ex}),
    // .out({sigs_from_mem, data_from_mem, data_from_alu, mem_wb_pc, inst_from_mem})
);

// control unit
ctrl u2_control(
    .Op(inst_from_if[6:0]),
    .Funct7(inst_from_if[31:25]),
    .Funct3(inst_from_if[14:12]),
    //.Zero(mem_Zero),
    
    // output signals
    .RegWrite(sigs_by_id[0]),
    .MemWrite(sigs_by_id[21]),
    .EXTOp(sigs_by_id[6:1]),
    .ALUOp(sigs_by_id[11:7]),
    .NPCOp(sigs_by_id[14:12]),
    .ALUSrc(sigs_by_id[15]),
    .DMType(sigs_by_id[18:16]),
    // .GPRSel(),
    .WDSel(sigs_by_id[20:19]),
    .itypel(ctrl_itype_l)
);

// register file
RegFile u2_reg(
    .clk(clk), .rst(rst),
    .write_en(sigs_from_mem[0]),
    .read_addr_1(inst_from_if[19:15]),
    .read_addr_2(inst_from_if[24:20]),
    .write_addr(inst_from_mem[11:7]),
    .write_data(WD),
    .read_data_1(data_from_rs1),
    .read_data_2(data_from_rs2),
    .pc(mem_wb_pc)
);

// imm generator
EXT u2_immgen(
    .EXTOp(sigs_by_id[6:1]),
    .immout(immgen_out),
    .iimm_shamt(inst_from_if[24:20]),
    .iimm(inst_from_if[31:20]),
    .simm({inst_from_if[31:25],inst_from_if[11:7]}),
    .bimm({inst_from_if[31],inst_from_if[7],inst_from_if[30:25],inst_from_if[11:8]}),
    .uimm(inst_from_if[31:12]),
    .jimm({inst_from_if[31],inst_from_if[19:12],inst_from_if[20],inst_from_if[30:21]})
);

alu u3_alu(
    .A(alu_A),
    .B(alu_B),
    .ALUOp(sigs_from_id[11:7]),
    .C(alu_result),
    .Zero(alu_zero),
    .PC(id_ex_pc)
);

// S and B type instructions no rd, also no writeback
wire [4:0] id_ex_rd = ((inst_from_id[6:0] == 7'b0100011) || (inst_from_id[6:0] == 7'b1100011)) ? 5'b0 : inst_from_id[11:7];
// U(lui, auipc) and UJ type instruction no rs1 
wire [4:0] if_id_rs1 = ((inst_from_if[6:0] == 7'b0110111) || (inst_from_if[6:0] == 7'b0010111)
                        || (inst_from_if[6:0] == 7'b1100111/*jalr*/)) ? 5'b0 : inst_from_if[19:15];
// I and U and UJ type instruction no rs2 
wire [4:0] if_id_rs2 = ((inst_from_if[6:0] == 7'b0110111) || (inst_from_if[6:0] == 7'b0010111) || (inst_from_if[6:0] == 7'b0010011)
                        || (inst_from_if[6:0] == 7'b0000011) || (inst_from_if[6:0] == 7'b1100111/*jalr*/)) ? 5'b0 : inst_from_if[24:20];

// applying stall to data and control hazard
hazard_det u_stall(
    .id_ex_memread(id_ex_memread),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),
    //output
    .stall(stall)
);

// applying forwarding to data hazard
// U(lui, auipc) and UJ type instruction no rs1 
wire [4:0] id_ex_rs1 = ((inst_from_id[6:0] == 7'b0110111) || (inst_from_id[6:0] == 7'b0010111) || (inst_from_id[6:0] == 7'b1100111)) ? 5'b0 : inst_from_id[19:15];
// I and U and UJ type instruction no rs2 
wire [4:0] id_ex_rs2 = ((inst_from_id[6:0] == 7'b0110111) || (inst_from_id[6:0] == 7'b0010111) || (inst_from_id[6:0] == 7'b0010011)
                        || (inst_from_id[6:0] == 7'b0000011) || (inst_from_id[6:0] == 7'b1100111)) ? 5'b0 : inst_from_id[24:20];
// S and B type instructions no rd, also no writeback
wire [4:0] ex_mem_rd = ((inst_from_ex[6:0] == 7'b0100011) || (inst_from_ex[6:0] == 7'b1100011)) ? 5'b0 : inst_from_ex[11:7];
wire [4:0] mem_wb_rd = ((inst_from_mem[6:0] == 7'b0100011) || (inst_from_mem[6:0] == 7'b1100011)) ? 5'b0 : inst_from_mem[11:7];

hazard_forward u_forward(
    .instr_opcode(inst_from_id[6:0]),
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_wb(sigs_from_ex[0]),
    .mem_wb_wb(sigs_from_mem[0]),
    .ex_mem_rd(ex_mem_rd),
    .mem_wb_rd(mem_wb_rd),
    // output
    .forwardingA(forwardingA),
    .forwardingB(forwardingB)
);

NPC u1_npc(
    .PC(PC_out),
    .branch_dest(branch_dest),
    .jump_dest(jump_dest),
    .jalr_dest(jalr_dest),
    .NPCOp({sigs_from_ex[14:13], branch}), 
    .NPC(next_pc),
    .jump(jump),     // jump signal 
    //.inst_opcode(inst[6:0]) // instruction fetched opcode
    .j_fetch(j_fetch)
);

mux4 wb_sel (
    .signal(sigs_from_mem[20:19]),
    .do(WD),
    .d0(data_from_alu),
    .d1(data_from_mem),
    .d2(mem_wb_pc + 4),
    .d3(0)
    );
endmodule