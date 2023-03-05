module AHW1(
  input		[17:0] SW,		// 18 slide switches on board
  input		[3:0] KEY,		// hooked to the 4 push buttons
  output 	[17:0] LEDR,	// 18 red LEDs
  output	[7:0] LEDG		// 8 green LEDs
);

  ///////////////////////////////////////////////////////////////////
  // Instantiate your RCA4 block and make appropriate connections //
  /////////////////////////////////////////////////////////////////
    
	RCA4 RCA4_0(.A(SW[17:14]),.B(SW[3:0]),.Cin(~KEY[0]),.S(LEDG[3:0]),.Cout(LEDG[7]));

  ////////////////////////////////////////////////////////////////////
  // Need a couple of assign statements below to have LEDR[17:14]  //
  // represent SW[17:14] and LEDR[3:0] represent SW[3:0].         //
  /////////////////////////////////////////////////////////////////
  assign LEDR [17:14] =SW[17:14];
  assign LEDR [3:0] = SW[3:0];
 
				
  
endmodule
