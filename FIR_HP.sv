module FIR_HP(clk, rst_n, lft_in, rght_in, sequencing, lft_out, rght_out);

input clk, rst_n, sequencing;
input [15:0]lft_in, rght_in;
output [15:0]lft_out, rght_out;

typedef enum reg{IDLE, ACCUM}state_t;
state_t state, nxt_state;

logic [9:0]romff, addrommux, clrrommux;
logic addrom, clrrom, accum, clraccum;
logic [31:0]accumffL, accumffR, accummuxL, clraccummuxL, accummuxR, clraccummuxR;
logic signed [31:0]lft_inS, rght_inS; 
logic [15:0]romOut;

// instantiate rom
ROM_HP hp(.clk(clk), .addr(romff), .dout(romOut));

assign addrommux = addrom ? romff + 1 : romff;			// incr rom mux
assign clrrommux = clrrom ? 10'b0 : addrommux;			// clr rom mux

// rom ff
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)		romff <= 10'b0;
	else			romff <= clrrommux;

end

assign lft_inS = lft_in * romOut;				// multiply sample by rom coefficient
assign rght_inS = rght_in * romOut;

assign accummuxL = accum ? lft_inS + accumffL : accumffL;	// incr accum mux
assign clraccummuxL = clraccum ? 32'b0 : accummuxL;		// clr accum mux 

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)		accumffL <= 32'b0;		// accum ff
	else			accumffL <= clraccummuxL;
end

assign accummuxR = accum ? rght_inS + accumffR : accumffR;	// same as above but for right chnnl
assign clraccummuxR = clraccum ? 32'b0 : accummuxR; 

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)		accumffR <= 32'b0;
	else			accumffR <= clraccummuxR;
end

always_ff @(posedge clk, negedge rst_n) begin			// SM flop
	if(!rst_n)		state <= IDLE;
	else			state = nxt_state;
end

always_comb begin						// SM logic
	nxt_state = IDLE;
	accum = 1'b0;
	clraccum = 1'b1;
	addrom = 1'b0;
	clrrom = 1'b1;
	case(state)
		IDLE: if(sequencing) begin
			nxt_state = ACCUM;
			clraccum = 1'b1;			// seq gets asserted, clr accum mux first
			clrrom = 1'b0;
			accum = 1'b1;
			addrom = 1'b1;
		end
		ACCUM: begin
			clraccum = 1'b0;			// start accumulating
			if(!sequencing)		
				nxt_state = IDLE;
		end
	endcase
end

assign lft_out = accumffL[30:15];				// assign left and right outputs
assign rght_out = accumffR[30:15]; 

endmodule