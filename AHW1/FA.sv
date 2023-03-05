///////////////////////////////////////////////////
// FA.sv  This design will take in 3 bits       //
// and add them to produce a sum and carry out //
////////////////////////////////////////////////
module FA(
  input 	A,B,Cin,	// three input bits to be added
  output	S,Cout		// Sum and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic a_and_b;
	logic xor_a_b;
	logic not1,not2;
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	xor xor0(xor_a_b,A,B);
	and and0(a_and_b,A,B);
	xor xor1(S,xor_a_b,Cin);
	and and1(xor_a_b_and_Cin,xor_a_b,Cin);
	or or0(Cout,a_and_b,xor_a_b_and_Cin);
	
	
	
endmodule