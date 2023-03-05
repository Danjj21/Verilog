///////////////////////////////////////////////////////
// RCA4.sv  This design will add two 4-bit vectors  //
// plus a carry in to produce a sum and a carry out//
////////////////////////////////////////////////////
module RCA4(
  input 	[3:0]	A,B,	// two 4-bit vectors to be added
  input 			Cin,	// An optional carry in bit
  output 	[3:0]	S,		// 4-bit Sum
  output 			Cout  	// and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic [2:0] carry;

	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	FA fa0((A[0]), (B[0]), (Cin), (S[0]), (carry[0]));
	FA fa1((A[1]), (B[1]), (carry[0]), (S[1]), (carry[1]));
	FA fa2((A[2]), (B[2]), (carry[1]), (S[2]), (carry[2]));
	FA fa3((A[3]), (B[3]), (carry[2]), (S[3]), (Cout));

	
endmodule