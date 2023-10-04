module band_scale(POT,audio,scaled);	

  input [11:0] POT;
  input  [15:0] audio;
  
  output [15:0] scaled;
  
	wire signed [12:0] int1; //declares intermediate signals
	wire signed [28:0] int2; //declares intermediate signals
	wire signed [23:0] int3;
	
	assign int3= POT*POT; //squaring 12 bit unsigned potentiometer reading we square it to get a 24-bit unsigned product
	assign int1={{1'b0},int3[23:12]};//make it signed by appending a zero in front

	assign int2=int1*audio;	//multiplies the two signed signals


	//performing saturation to condense the 30 bit vector to 16->output scaled
    assign scaled=(int2[28])? ((int2[28] |int2[27] |int2[26] )? (16'h1000):(int2[25:10])):
						((int2[28] |int2[27] |int2[26] )? (16'h0FFF):(int2[25:10]));
								

	
  
endmodule