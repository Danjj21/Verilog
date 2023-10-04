`default_nettype none
module bt_intf(clk,rst_n,TX,RX,cmd_n,prev_n,next_n);

  input logic clk,rst_n;	  //input clock and active low reset
  input logic RX;		  	  //input RX from RN-52 bluetooth module
  input logic next_n;
  input logic prev_n;
  
  output logic TX;			//output TX to RN-52 bluetooth module
  output logic cmd_n;	//output response received signal
  
 						
						
	//define logic//
	
	logic [3:0] cmd_len;
	logic [4:0] cmd_start;
	logic resp_rcvd,send;
	
	/////////////////////////////////////
	//Instantiate send command//////////
	/////////////////////////////////// 
  
    snd_cmd snd_inst(.clk(clk),.rst_n(rst_n),.resp_rcvd(resp_rcvd),.cmd_start(cmd_start)
						,.send(send),.cmd_len(cmd_len),.RX(RX),.TX(TX));
						
	/////////////////////////////////////
	// Instantiate PB_release //////////
	///////////////////////////////////

	logic prev_track;
	PB_release PB(.clk(clk),.rst_n(rst_n),.PB(prev_n),.released(prev_track));
	
	
	/////////////////////////////////////
	// Instantiate PB_release //////////
	///////////////////////////////////

	logic nxt_track;
	PB_release PB_2(.clk(clk),.rst_n(rst_n),.PB(next_n),.released(nxt_track));
	
  ////////////////////////
  // Infer bit counter //
  //////////////////////
  
  
  logic [16:0] cnt;
  logic count_done;
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n) begin
		cnt <= 17'h00000;			// active low reset to 0x00
		cmd_n <=1'b1;
		end
	  else if(!count_done) 	// allowed to count
		cnt <= cnt + 1;		// count up
	  else
		cmd_n<=1'b0;


  assign count_done =(cnt == 17'h1FFFF)? 1'b1 : 1'b0;
  
  //define enumerated type for state machine
  typedef enum reg[1:0] {IDLE,WAIT_COMMAND1,WAIT_COMMAND2,WAIT_BUTTON} state_t;
  
  state_t state, nxt_state;
  
  
			   
  /////////////////////////
  // define state flops // 
  ///////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;

  always_comb begin
	//initialize outputs to default values
	// cmd_start="";
	// cmd_len=5'h00;
	nxt_state=state;
	send = 0;
	case (state)
	  IDLE : begin
		if(count_done) begin
		//next state to WAIT_COUNTER
		nxt_state=WAIT_COMMAND1;
		end
	  end
	  WAIT_COMMAND1 : begin
		cmd_start=5'b00000;
		cmd_len=5'h06;
		if(resp_rcvd) begin
		send = 1;
		nxt_state=WAIT_COMMAND2;
		end
	  end
	  WAIT_COMMAND2: begin
	  	cmd_start=5'b00110;
		cmd_len=5'h0A;
		if(resp_rcvd) begin
		send=1'b1;
		nxt_state=WAIT_BUTTON;
		end
	  end
	  WAIT_BUTTON: begin
		if(nxt_track) begin
			cmd_start=5'b10000;
			cmd_len=5'h04;	
			send = 1'b1;
			nxt_state=WAIT_BUTTON;				
		end
		else if(prev_track) begin
			cmd_start=5'b10100;
			cmd_len=5'h0A;	
			send = 1'b1;
			nxt_state=WAIT_BUTTON;
		end
		else begin
			nxt_state=WAIT_BUTTON;
		end
	  
	  end
	  default: begin
		 nxt_state=IDLE;
	  end
	endcase
	
  end
  
  
	
endmodule
`default_nettype wire