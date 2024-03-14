//`include "xgriscv_defines.v"

module xgriscv_tb();
    
   reg                  clk, rstn;
   wire[31:0] pc;
    
   // instantiation of xgriscv_sc
   xgriscv_pipeline xgriscv(
      .clk(clk), .reset(rstn),
      .pcW(pc)
   );

   integer counter = 0;
   
   initial begin
      // input instruction for simulation
      //$readmemh("Test_37_Instr.dat", xgriscv.U_imem.RAM);

      $readmemh("test.txt", xgriscv.U_imem.RAM);
      $readmemh("testdm.txt", xgriscv.U_dmem.RAM);
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
         if (pc == 32'h00000118) // set to the address of the last instruction
          begin
            
            $stop;
          end
      end
      
   end //end always
   
endmodule
