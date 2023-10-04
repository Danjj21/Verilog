module PB_release(clk,rst_n,PB,released);

input clk;	// clock 
input rst_n;// asynchronous reset signal
input PB;// asynchronous push button pressed signal
//LEC 11 updown counter
output released;// released(after fixing metastability issues) signal
logic intSig1,intSig2,intSig3;
logic notintSig3,notint4;



always_ff @(negedge rst_n,posedge clk) begin
	if(!rst_n) begin
		intSig1<=1'b1;
	end
	else begin
	  intSig1<=PB;
	end
	
	
end

always_ff @(negedge rst_n,posedge clk) begin
	if(!rst_n) begin
		intSig2<=1'b1;
	end
	else begin
	  intSig2<=intSig1;
	end
	
end

always_ff @(negedge rst_n,posedge clk) begin
	if(!rst_n) begin
		intSig3<=1'b1;
	end
	else begin
	  intSig3<=intSig2;
	end
	end
	
not (notintSig3,intSig3);
and (notint4,notintSig3,intSig2);


assign released=notint4;
endmodule 
