`default_nettype none
module I2S_Serf(clk, rst_n, I2S_sclk, I2S_ws, I2S_data, lft_chnnl, rght_chnnl, vld);

	typedef enum reg [1:0] {IDLE,WAIT_SCLK,SHFT_left,SHFT_right} state_t;
	state_t state, nxt_state;

	input logic clk, rst_n, I2S_sclk, I2S_ws, I2S_data;
	output logic [23:0] lft_chnnl, rght_chnnl;
	output logic vld;
	
	logic [47:0] shft_reg;  
	logic [4:0] bit_cntr;
	logic sclk_flop, sclk_rise, ws_flop, ws_fall, clr_cnt;
	
	logic eq22,eq23,eq24;
	// Bit counter
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			bit_cntr <= 5'b00000;
		else if (clr_cnt)
			bit_cntr <= 5'b00000;		
		else if (sclk_rise)
			bit_cntr <= bit_cntr + 1;
	end
	
	assign eq22 = (bit_cntr == 5'b10110);
	assign eq23 = (bit_cntr == 5'b10111);
	assign eq24 = (bit_cntr == 5'b11000);
	
	// Channel data shift register
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			shft_reg <= {48{1'b0}};
		else if (sclk_rise)
			shft_reg <= {shft_reg[46:0], I2S_data};
	end
	
	assign lft_chnnl = shft_reg[47:24];
	assign rght_chnnl = shft_reg[23:0];
	
	// Synch/edge detect
	always_ff @(posedge clk,  negedge rst_n) begin
		if (!rst_n) begin
			sclk_flop <= 1'b0;
			ws_flop <= 1'b0;
		end else begin
			ws_flop <= I2S_ws;
			sclk_flop <= I2S_sclk;
		end
	end
	
	assign sclk_rise = ~sclk_flop & I2S_sclk;
	assign ws_fall = ws_flop & ~I2S_ws;
	
	// State machine
	always_ff @(posedge clk,  negedge rst_n) begin
		if (!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	always_comb begin
		nxt_state = state;
		clr_cnt = 1'b0;
		vld = 1'b0;
		case (state)
			IDLE: begin
				// WS falls a cycle before left data
				if (ws_fall) begin
					nxt_state = WAIT_SCLK;
				end
			end
			WAIT_SCLK: begin
				if (sclk_rise) begin
					clr_cnt = 1'b1;
					nxt_state = SHFT_left;
				end
			end
			
			SHFT_left: begin
				// Resync checks: if ws is not what we expect, go back to syncing states
				if (eq22 & I2S_ws & sclk_rise) begin
					nxt_state = IDLE;
				end
				if (eq23 & (~I2S_ws) & sclk_rise) begin
					nxt_state = IDLE;
				end
				
				// Finished recieving left
				if (eq24) begin
					clr_cnt = 1'b1;
					nxt_state = SHFT_right;
				end
			end
			
			SHFT_right: begin
				if (eq24) begin
					vld = 1'b1;
					nxt_state = IDLE;
				end
			end
			default: begin 
				nxt_state=IDLE;
			end
			
		endcase
	end
endmodule
`default_nettype wire