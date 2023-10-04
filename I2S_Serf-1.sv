module I2S_Serf_1(clk, rst_n, 
		I2S_sclk, I2S_ws, 
		I2S_data, lft_chnnl, 
		rght_chnnl, vld
		);

	input logic clk, rst_n, I2S_sclk, I2S_ws, I2S_data;
	output logic [23:0] lft_chnnl, rght_chnnl;
	output logic vld;

	// Counter
	logic [4:0] bit_cntr_out;
	logic clr_cnt, sclk_rise;
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			bit_cntr_out <= 5'b00000;
		end
		if (clr_cnt) begin
			bit_cntr_out <= 5'b00000;
		end
		else if (sclk_rise) begin
			bit_cntr_out <= bit_cntr_out + 1;
		end	
	end

	// Decode
	logic eq22, eq23, eq24;
	assign eq22 = (bit_cntr_out == 5'b10110) ? 1'b1 : 1'b0;
	assign eq23 = (bit_cntr_out == 5'b10111) ? 1'b1 : 1'b0;
	assign eq24 = (bit_cntr_out == 5'b11000) ? 1'b1 : 1'b0;

	// Shifter 
	
	logic signed [47:0] shft_reg;
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			shft_reg <= 48'h0;
		end
		if (sclk_rise) begin
			shft_reg <= {shft_reg[46:0], I2S_data};
		end
	end

	// left and right channels
	assign {lft_chnnl, rght_chnnl} = shft_reg;


	// sclk edge detect
	logic prev_sclk, ff1, ff2;
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			ff1 <= 0'b0;
			ff2 <= 0'b0;
			prev_sclk <= 1'b0;
		end
		else begin
			ff1 <= I2S_sclk;
			ff2 <= ff1;
			prev_sclk <= ff2;
		end
	end
	assign sclk_rise = (~prev_sclk & ff2) ? 1'b1 : 1'b0; 

	// I2S_ws edge detect
	logic prev_ws, ws_fall, ws_ff1, ws_ff2;
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			ws_ff1 <= 1'b0;
			ws_ff2 <= 1'b0;
			prev_ws <= 1'b0;
		end
		else begin
			ws_ff1 <= I2S_ws;
			ws_ff2 <= ws_ff1;
			prev_ws <= ws_ff2;
		end
	end
	assign ws_fall = (prev_ws & ~ws_ff2) ? 1'b1 : 1'b0;


	// State Machine states
	typedef enum logic [1:0]{ IDLE, R_LSB, LEFT, RIGHT } state_t;
	state_t state, nxt_state;
	// SM ff
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin 
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

	always_comb begin
		clr_cnt = 1'b0;
		vld = 1'b0;
		nxt_state = state;
		case (state)
			IDLE : if (ws_fall) begin
					nxt_state = R_LSB;
					clr_cnt = 1'b1;
				end
			R_LSB : 
				if (sclk_rise) begin
					nxt_state = LEFT;
					clr_cnt = 1'b1;
				end
				else if (I2S_ws) begin
					nxt_state = IDLE;
					clr_cnt = 1'b1;
				end
			LEFT : 
				if (eq22 && I2S_ws && sclk_rise) begin					// check if still synched
					nxt_state = IDLE;
					clr_cnt = 1'b1;
				end
			       	else if (eq24) begin
					nxt_state = RIGHT;
					clr_cnt = 1'b1;
			       	end
			       	else if (eq23 && ~I2S_ws && sclk_rise) begin
					nxt_state = IDLE;
					clr_cnt = 1'b1;
				end
			RIGHT : 
				if (eq22 && ~I2S_ws && sclk_rise) begin					// check if still synched
					nxt_state = IDLE;
					clr_cnt = 1'b1;
				end
				else if (eq24) begin
					vld = 1'b1;
					nxt_state = LEFT;
					clr_cnt = 1'b1;
				end	
				else if (eq23 && I2S_ws && sclk_rise) begin
					nxt_state = IDLE;
					clr_cnt = 1'b1;
				end
		endcase
	end
endmodule
