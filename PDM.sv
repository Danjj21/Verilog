`default_nettype none
module PDM(clk,rst_n,duty,PDM,PDM_n);

input wire clk,rst_n;		// clock and asynchronous reset signal
input logic[15:0] duty;		// duty cycle input
output logic PDM;		//PDM signal
output logic PDM_n;		// PDM and PDM_n

//decalre intermediate signals
logic [15:0] B;
logic [15:0] dutyInt;
logic [15:0] Bint2;
logic [15:0] Bint1;
logic [15:0] Bint;
//declare signal to determine if A is greater than B
logic AgteqB;


//assign intermediate signal AgteqB to 
//comparison between Bint2 and input=dutyInt
assign AgteqB=(dutyInt>=Bint2);


	//assign Bint1 is B-input(from problem statement(first ALU)
	assign Bint1=B-dutyInt;
	//Assign Bint to Bint2+ Bint1(second ALU)
	assign Bint=Bint2+Bint1;
	//assign B to all 1s or all 0s initial mux
	assign B=(AgteqB)? 16'hffff : 16'h0000;

//always block to reset Bint 2 coming out of flop
// or set it to Bint2(coming out of 2nd ALU 
always_ff @(negedge rst_n,posedge clk) begin

	if(!rst_n) begin
		Bint2<=16'h0000;
	end
	else begin
		Bint2<=Bint;
	end

	
end
	
	
	//assign PDM=~PDM_n;
always_ff @(negedge rst_n,posedge clk) begin
	if(!rst_n) begin
		PDM_n<=1'b1;
		PDM<=1'b0;
	end
	//assign PDM to AgteqB and PDM_n to ~AgteqB
	else begin
		PDM_n<=~AgteqB;
		PDM<=AgteqB;
	end
	//else	begin
		//PDM_n<=PDM_n;
		//PDM<=PDM;
	//end
end	

//assign input signal to comparator and first ALU to all zeros or to
//input of flop,i.e. duty signal
always_ff @(negedge rst_n,posedge clk) begin
	if(!rst_n) begin
		dutyInt<=16'h0000;
		
	end
	else begin
		dutyInt<=duty;
		
	end
	
end
	
	
	
endmodule 
`default_nettype wire