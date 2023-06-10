//`include "xgriscv_defines.v"

module xgriscv_tb();
    
   reg                  clk, rstn;
   wire[31:0] pc;
    
   // instantiation of xgriscv_sc
   xgriscv_sc xgriscv(clk, rstn, pc);

   integer counter = 0;
   
   initial begin
      // input instruction for simulation
      $readmemh("riscv32_sim_all.hex", xgriscv.U_imem.RAM);
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
   end
   
   always begin
      #(50) clk = ~clk;
     
      if (clk == 1'b1) 
      begin
         counter = counter + 1;
         //comment out all display line(s) for online judge
         if (pc == 32'h00000CCC) // set to the address of the last instruction
          begin

            $stop;
          end
      end
      
   end //end always
   
endmodule
