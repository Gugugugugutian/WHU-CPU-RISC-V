`include "ctrl_encode_def.v"

module NPC(  // next pc module
   input  [31:0] PC,        // pc
   input [31:0] branch_dest, jump_dest, jalr_dest,
   input  [2:0]  NPCOp,     // next pc operation
   //input [6:0] inst_opcode,
   input j_fetch,
   //input  [31:0] IMM,       // immediate
   //input [31:0] aluout,
   //input stall,
   
   output reg [31:0] NPC,   // next pc
   output jump   // branch signal
);

   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = j_fetch ? PC: (PC+4); // pc + 4
   // when jal or jalr, stall the pipeline but when 
   // jump taken at MEM stage, not stall. 
   
  // assign pcW = PC - 4;
   
   always @(*) begin
     // if(!stall) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = branch_dest;   // branch taken
          `NPC_JUMP:   NPC = jump_dest;   // jump taken
		  `NPC_JALR:   NPC = jalr_dest;  // jalr taken
          default:     NPC = PCPLUS4;
      endcase
    //  end
      //else NPC = PC;
   end // end always

   assign jump = ((NPCOp == `NPC_BRANCH) | (NPCOp == `NPC_JALR) | (NPCOp == `NPC_JUMP));   
endmodule
