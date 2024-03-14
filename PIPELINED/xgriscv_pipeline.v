//`include "xgriscv_defines.v"
module xgriscv_pipeline(
  input             clk, reset,
  output [31:0]     instr, reg_data, alu_disp_data, dmem_data, pcW
  );
   
  wire [31:0]    PC;
  wire           MemWrite;
  wire [31:0]    dm_addr, dm_din, dm_dout;
  wire [2:0]     dmtype;
  
  assign dmem_data = dm_dout; // data memory output
  assign pcW = PC;      // pc output

  //wire rstn;
  //assign rstn = ~reset;

  pipecpu U_pipe_CPU(
    .clk(clk),                 // input:  cpu clock
    .rst(reset),                 // input:  reset
    .inst(instr),             // input:  instruction
    .data_from_dm(dm_dout),        // input:  data to cpu  
    .dm_write(MemWrite),       // output: memory write signal
    .PC_out(PC),                   // output: PC
    .Addr_out(dm_addr),          // output: address from cpu to memory
    .Data_out(dm_din),        // output: data from cpu to memory
    //.pcW(pcW),
    .DMType(dmtype)
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
    .pc(PC),
    .type(dmtype)
    );
  
endmodule
