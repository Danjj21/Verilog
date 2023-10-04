module rst_synch(clk,rst_n,RST_n);

input clk,RST_n;		// clock and asynchronous reset signal
output reg rst_n;
//LEC 11 updown counter

reg intSig;




always @(negedge RST_n,negedge clk) begin
	if(!RST_n) begin
	  intSig<=1'b0;
	end
	else begin
	  intSig<=1'b1;
	end
	
	
end

always @(negedge RST_n,negedge clk) begin
	if(!RST_n) begin
	  rst_n<=1'b0;
	end
	else begin
	  rst_n<=intSig;
	end
end	
	

	
endmodule