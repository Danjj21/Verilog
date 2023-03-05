////////////////////////////////////////////////////////
// RCA16.sv  This design will add two 16-bit vectors //
// plus a carry in to produce a sum and a carry out //
/////////////////////////////////////////////////////
module RCA16(
  input 	[15:0]	A,B,	// two 16-bit vectors to be added
  input 			Cin,	// An optional carry in bit
  output 	[15:0]	S,		// 16-bit Sum
  output 			Cout  	// and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	wire [15:0] Carries;	// this is driven by .Cout of FA and will
							// in a "promoted" form drive .Cin of FA's
	logic [15:0] Carryin;
	
	assign Carryin={Carries[14:0], Cin};
	assign Cout= Carries[15];
	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	// You fill in vectored instantiation of 16 FA cells >>
	//Also remember a line to drive Cout of top level with Carries[15] >>
	FA FA[15:0] (.A(A),.B(B),.Cin(Carryin), .S(S), .Cout(Carries));
	
	
endmodule