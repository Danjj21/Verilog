module SPI_mnrch(clk, rst_n, MISO, snd, cmd, SS_n, SCLK, MOSI, done, resp);

typedef enum reg [1:0] {s_init, s_shft, s_ld_SCLK, s_done} state_t;
state_t state, nxt_state;

input logic clk, rst_n, MISO, snd;
input logic [15:0] cmd;
output logic SS_n, SCLK, MOSI, done;
output logic [15:0] resp;

logic [15:0] shft_reg;
logic [4:0] cnt, SCLK_div;
logic set_done, init, done16, ld_SCLK, shft, full;

// Counter
always_ff @(posedge clk, negedge rst_n) begin
	if (~rst_n)
		cnt <= 5'b00000;
	else if (init)
		cnt <= 5'b00000;
	else if (shft)
		cnt <= cnt + 1'b1;
end

assign done16 = (cnt[4]) ? 1'b1 : 1'b0;

// SCLK source

assign SCLK = (~init & ~set_done) ? SCLK_div[4] : 1'b1;
assign shft = (SCLK_div == 5'b10001) ? 1'b1 : 1'b0;
assign full = (SCLK_div == 5'b11111) ? 1'b1 : 1'b0;

always_ff @(posedge clk, negedge rst_n) begin
	if (~rst_n)
		SCLK_div <= 5'b10111;
	else if (ld_SCLK)
		SCLK_div <= 5'b10111;
	else
		SCLK_div <= SCLK_div + 1;
end

// Shifter

assign MOSI = shft_reg[15];

always_ff @(posedge clk,  negedge rst_n) begin
	if (~rst_n) begin
		shft_reg <= cmd;
	end else if (init) begin
		shft_reg <= cmd;
	end else if (shft) begin
		shft_reg <= {shft_reg[14:0], MISO};
	end
end

// State flop

always_ff @(posedge clk,  negedge rst_n) begin
	if (~rst_n)
		state <= s_init;
	else
		state <= nxt_state;
end

always_comb begin
	init = 1'b0;
	set_done = 1'b0;
	ld_SCLK = 1'b0;
	nxt_state = state;	
	case (state)
		default: begin // s_init behavior
                        ld_SCLK = 1;
                        if (snd) begin
				init = 1'b1;
				nxt_state = s_shft;
			end
		end
		s_shft: begin
			if (done16) begin
				nxt_state = s_done;
			end
		end
		s_done: begin
                 	if (full) begin
				set_done = 1'b1;
				ld_SCLK = 1'b1;
				nxt_state = s_init;
 		 	end
    		 end
	endcase
end

// SS_n flop

always_ff @(posedge clk,  negedge rst_n) begin
	if (~rst_n)
		SS_n <= 1'b1;
	else if (init)
		SS_n <= 1'b1;
	else
		SS_n <= 1'b0;
end

// Set done flop

assign resp = shft_reg;

always_ff @(posedge clk,  negedge rst_n) begin
	if (~rst_n) begin
		done <= 1'b0;
	end else begin
		done <= set_done;
	end
end

endmodule