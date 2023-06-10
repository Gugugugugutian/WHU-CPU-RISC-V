# WHU-SingleCycleCPU-RISC-V
 武汉大学计算机组成与设计课程单周期CPU处理器实现，使用RISC-V语言实现。
 
 本代码在给出的CPU框架和一些基本模块的基础上，实现了较为完整功能的单周期处理器读取指令、译码、内存读写等操作。

 # 特别提醒

    请注意：本代码供学习参考，请独立完成作业。
    直接提交本代码，很有可能造成查重不通过，请自行承担后果。

# Release说明
## full-SC
Release包含基础的CPU模块和Testbench。
## 本地仿真
本模块可以在ModelSim等软件上完成仿真，但testbench文件并没有给出。以下是一个可能可用的testbench代码。
~~~
module local_tb();
    
   reg                  clk, rstn;
   wire[31:0] pc;
    
   // instantiation of xgriscv_sc
   xgriscv_sc xgriscv(clk, rstn, pc);

   integer counter = 0;
   
   initial begin
      // input instruction for simulation
      $readmemh("filename.hex", xgriscv.U_imem.RAM);
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
~~~
其中，filename.hex是一个存储了测试指令的二进制文件。这个文件可以自行由一些RISC-V指令汇编得到。
## 联系作者
除了Github外，您可通过gugugugugutian@whu.edu.cn邮箱联系。


# 模块介绍
null
