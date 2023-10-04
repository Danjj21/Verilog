module A2D_intf
(clk,rst_n,strt_cnv,cnv_cmplt,chnnl,res,SS_n,SCLK,MOSI,MISO);
///////////////////////////////////////////////////////////////////////////////
// This module outlines a A2D converter to interface with SPI_mnrch.sv
// to be flashed onto the DE0-Nano board
// Author: Hernan Carranza
///////////////////////////////////////////////////////////////////////////////

/// Module Signals /// 
input clk, rst_n;	// clock and asynch active low reset
input strt_cnv;		// flag to start a A2D conversion
input [2:0] chnnl;	// Specifies which channel (0-7) to convert
output reg cnv_cmplt;	// asserted when conversion is complete
output [11:0] res;  // 12-bit result of A2D conversion
output SS_n;		// active low serf select
output SCLK;		// SPI clock to A2D
output MOSI;		// Serial data to A2D
input MISO;			// Serial data from A2D

/// Internal Signals ///
logic set_complete;	// flag to set cnv_cmplt
logic send;			// flag to send to SPI to start transaction
wire done_f;		// done flag from SPI
wire [15:0]chnnl_cmd;			// cmd to send to SPI
wire [15:0] res_cnct;		// resp from SPI to send as result

assign chnnl_cmd = {2'b00,chnnl,11'h000};

/// Define state machine states ///
typedef enum reg [1:0] {IDLE,CMD,WAIT,RESULT} state_t;
state_t state, nxt_state;

/// Instantiate internal SPI_mnrch ///
SPI_mnrch SPI(.clk(clk),.rst_n(rst_n),.snd(send),.done(done_f),.resp(res_cnct),
              .cmd(chnnl_cmd),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));

/// Flop cnv_cmplt ///
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
	cnv_cmplt <= 1'b0;
  else
    cnv_cmplt <= set_complete && (!strt_cnv);
end

///////////////////////////////////////////////////////////
// State Machine logic
///////////////////////////////////////////////////////////

/// Infer state flops ///
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
	state <= IDLE;
  else 
    state <= nxt_state;
end

/// State transision comb logic ///
always_comb begin
  send = 0;
  set_complete = 0;
  nxt_state = state;
  case (state)
	IDLE: 
	  if(strt_cnv) begin
	    nxt_state = CMD;
	    send = 1;
	  end
	CMD: 
	  if(done_f)
		nxt_state = WAIT;
	WAIT: begin
	  nxt_state = RESULT;
	  send = 1;
	  end
	RESULT:
	  if(done_f) begin
	    nxt_state = IDLE;
		set_complete = 1;
		end
	endcase
end

assign res = res_cnct[11:0];

endmodule