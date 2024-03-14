//`include "xgriscv_defines.v"
module xgriscv_sc(clk, reset, pcW);
  input             clk, reset;
  output [31:0]     pcW;
   
  wire [31:0]    instr;
  wire [31:0]    PC;
  wire           MemWrite;
  wire [31:0]    dm_addr, dm_din, dm_dout;

  //wire rstn;
  //assign rstn = ~reset;

  riscv_SCPU U_SCPU(
    .clk(clk),                 // input:  cpu clock
    .reset(reset),                 // input:  reset
    .inst_in(instr),             // input:  instruction
    .Data_in(dm_dout),        // input:  data to cpu  
    .mem_w(MemWrite),       // output: memory write signal
    .PC_out(PC),                   // output: PC
    .Addr_out(dm_addr),          // output: address from cpu to memory
    .Data_out(dm_din),        // output: data from cpu to memory
    .pcW(pcW)
  );

  imem U_imem(
  .rd(instr),
  .a(PC)
  );

  dmem U_dmem(
    .clk(clk), 
    .we(MemWrite), 
    .a(dm_addr), 
    .wd(dm_din), 
    .rd(dm_dout), 
    .pc(PC)
    );
  
endmodule
