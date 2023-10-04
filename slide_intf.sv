module slide_intf(clk,rst_n,POT_LP,POT_B1,POT_B2,POT_B3,POT_HP,VOLUME,SS_n,SCLK,MOSI,MISO);
///////////////////////////////////////////////////////////////////////////////
// This module performs A2D conversions on our 5 band passes
///////////////////////////////////////////////////////////////////////////////

/// Module Inputs & Outputs ///
input clk, rst_n;		// Sys clock and async active low reset
output SS_n;			// Serf Select from SPI
output SCLK;			// SPI clock
output MOSI;			// Data sent to A2D
input MISO;				// data recieved from A2D
// Gain of bands and overall volume
output logic [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME; 

/// State Machine reg type declaration ///
typedef enum reg {TO_NEXT, CONVERT} state_t;
state_t state, nxt_state;

// Declare local parameters for channel selection 
localparam gain_LP = 3'b001;
localparam gain_B1 = 3'b000;
localparam gain_B2 = 3'b100;
localparam gain_B3 = 3'b010;
localparam gain_HP = 3'b011;
localparam gain_VOL = 3'b111;

/// Internal Module signals ///
wire [11:0] res;							// 12-bit conversion from A2D 

/// State Machine logic singals ///
logic cnv_cmplt;					// flag for SM when new A2D result is ready
logic [2:0] chnnl;						// channel to start A2D conv
logic strt_cnv;						// SM flag sent to A2D 
logic [5:0] rr_en_bus;				// Round-robin register enables
			
/// Instantiate A2D_intf that will perform conversions ///
A2D_intf iA2D(.clk(clk),.rst_n(rst_n),.res(res),.cnv_cmplt(cnv_cmplt),.chnnl(chnnl),
			  .strt_cnv(strt_cnv),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));
			  
/////////////////////////////////////////////////
// Infer shift register that will  round-robin
// select each audio band
/////////////////////////////////////////////////
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    rr_en_bus <= 6'b100000;
  else if (cnv_cmplt)
  	rr_en_bus <= {rr_en_bus[0], rr_en_bus[5:1]};
end

/////////////////////////////////////////////////
// Infer registers for band passes
/////////////////////////////////////////////////
always_ff @(posedge clk) begin
  if (rr_en_bus[0] & cnv_cmplt)
	POT_LP <= res;
  else if (rr_en_bus[1] & cnv_cmplt) 
	POT_B1 <= res;
  else if (rr_en_bus[2] & cnv_cmplt)
	POT_B2 <= res;
  else if (rr_en_bus[3] & cnv_cmplt)
	POT_B3 <= res;
  else if (rr_en_bus[4] & cnv_cmplt)
	POT_HP <= res;  
  else if (rr_en_bus[5] & cnv_cmplt)
	VOLUME <= res;
end

assign chnnl =  (rr_en_bus[0]) ? gain_LP : 
				(rr_en_bus[1]) ? gain_B1 :
				(rr_en_bus[2]) ? gain_B2 :
				(rr_en_bus[3]) ? gain_B3 :
				(rr_en_bus[4]) ? gain_HP :
				gain_VOL;

/////////////////////////////////////////////////
// State Machine Logic
/////////////////////////////////////////////////

/// Infer state registers ///
always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n)
    state <= TO_NEXT;
  else
    state <= nxt_state;
end

/// State Transition logic ///
always_comb begin
  // Default SM outputs 
  strt_cnv = 0;
  nxt_state = state;
  
  case(state)
	TO_NEXT: begin
		nxt_state = CONVERT;
		strt_cnv = 1;
	end
		
	CONVERT: begin
		if (cnv_cmplt) begin
			nxt_state = TO_NEXT;
		end
	end
	
	default: nxt_state = TO_NEXT;
	
  endcase
end



endmodule