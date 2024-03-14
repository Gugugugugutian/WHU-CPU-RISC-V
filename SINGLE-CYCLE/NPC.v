`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC,aluout, pcW);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] aluout;
   
   output reg [31:0] NPC;   // next pc
   output [31:0] pcW;
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   assign pcW = PC;
   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = PC+IMM;
          `NPC_JUMP:   NPC = PC+IMM;
		    `NPC_JALR:	  NPC = aluout;
          default:     NPC = PCPLUS4;
      endcase
   end // end always
   
endmodule
