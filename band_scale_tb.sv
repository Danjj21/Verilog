module band_scale_tb();

reg [15:0] audio;//input audio vector
reg [11:0]POT; //input potentiometer determines gain to output

//output scaled vector based on gain due to pot
wire signed [15:0] scaled;	// hook to iDUT


////// Instantiate structural version of DUT ////////
band_scale iDUT(.POT(POT),.audio(audio),.scaled(scaled));

initial begin
	// Initialization test
  POT=12'h000;
  audio=16'h0000;
    
  if(POT!=12'h000)begin
  $display("Init test failed");
  $stop();
  end
  if(scaled!=16'h0000)begin
  $display("Init test failed");
  $stop();
  end
  //Potentiometer set to 0 so scaled should be zero
  #5
  POT=12'h000;
  audio=16'hFFFF;
  #5
  if(scaled!=16'h0000)begin
  $display("Should be zero gain");
  $stop();
  end
  //Potentiometer set to 273 = 6.665% gain scaled should be .0665x ~ 0 for our input
  #5
  POT=12'h111;
  audio=16'h0001;
  #5
  
  if(scaled!=16'h0000)begin
  $display("should be almost zero due to saturation");
  $stop();
  end
   //Potentiometer set to FFFF = 400% gain scaled should be 4x
  #5
  POT=12'hFFF;
  audio=16'h0010;
  #5
  if(scaled!=16'h1000)begin
  $display("should be x4 i.e. 4");
  $stop();
  end
  //Potentiometer set to FFFF = 400% gain scaled should be zero
  #5
  POT=12'hFFF;
  audio=16'h0000;
  #5
  if(scaled!=16'h0000)begin
  $display("should be x4 i.e. 4");
  $stop();
  end
  $stop();
end


endmodule