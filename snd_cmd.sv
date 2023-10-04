`default_nettype none
module snd_cmd(clk,rst_n,resp_rcvd,cmd_start,send,cmd_len,RX,TX);

  input logic clk,rst_n;	  //input clock and active low reset
  input logic RX;		  	  //input RX from RN-52 bluetooth module
  input logic [4:0] cmd_start;//input address of start bit
  input logic [3:0] cmd_len;  //input length of data
  input logic send;
  
  output logic TX;			//output TX to RN-52 bluetooth module
  output logic resp_rcvd;	//output response received signal
  
  
  //intermediate logic
  logic inc_addr, trmt,tx_done,last_byte;
  //define enumerated type for state machine
  typedef enum reg[1:0] {IDLE,DEAD_WAIT,TRANSMIT} state_t;
  
  state_t state, nxt_state;
  
  //////////////////////////////////
  //   DEFINING LOGIC INTO cmdROM //
  //////////////////////////////////
  
  logic [7:0] tx_data;
  logic [4:0] start_address_intflop,start_address_intmux;
  logic [4:0] addr;
  //2 to 1 mux that takes in start address or incremented addressed
  // based on send bit
  assign start_address_intflop = (send) ? cmd_start : start_address_intmux;
  
  //2 to 1 mux that takes in incremented address the same address
  // based on output from state machine
  assign start_address_intmux = (inc_addr) ? addr + 1 : addr;
  
  //////////////////////////////////////////////////
  //always  block that inputs addresss into cmdROM//
  //at posedge clk(flipflop)					  //
  //////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		addr <= 5'h00;
	end 
	else begin
		addr <= start_address_intflop;
	end
  end
  
  
  ////////////////////////////////
  //cmdROM Instantiated here ///// 
  ////////////////////////////////
  cmdROM cmdROM_def(.clk(clk),.addr(addr),.dout(tx_data));
  //NOTE:tx_data output from cmdROM is input to UART(wait one clock cycle?)
   
  ////////////////////////////////////////
  //   DEFINING LOGIC to check last_byte //
  ////////////////////////////////////////
  logic [4:0] last_byte_addr;   //last byte address
  logic [4:0] last_byte_intflop;//data of last_byte_addr into flop
  logic [4:0] last_byte_outflop;//data of last_byte_addr out of flop
  
  //last byte is start address+length
  assign last_byte_addr = cmd_start + cmd_len; 
  
  //2 to 1 mux that takes in address of last bit(last_byte)
  //and enters into flip flop based on send bit(if high)
  //else hold value out of flip flop
  assign last_byte_intflop = (send) ? last_byte_addr : last_byte_outflop;
  
  /////////////////////////////////////////////////////////////////////
  //always block-Flip flop that holds addresss of last bitinto cmdROM//
  /////////////////////////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		last_byte_outflop<=5'h00;
	end 
	else begin
		last_byte_outflop <= last_byte_intflop;
	end
  end
  
  ////////////////////////////////////////////////////////////////////////////////////
  //check if last bit of data is reached by checking equality of last_byte with addr //
  /////////////////////////////////////////////////////////////////////////////////////
  assign last_byte = (addr == last_byte_outflop) ? 1'b1 : 1'b0;
  
			   
  /////////////////////////
  // define state flops // 
  ///////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;
  ////////////////////////////////////////////////////////////////////////
  //always block to wait for one clock cycle atleast for /////////////////
  //cdROM to access data  								 /////////////////
  ////////////////////////////////////////////////////////////////////////
  logic wait_done;
  always_ff @(posedge clk) begin
	if(!rst_n) begin
		wait_done<=1'b0;
	end else begin
		wait_done <= ~wait_done;
	end
  end
  always_comb begin
	//initialize outputs to default values
    trmt = 1'b0;
	inc_addr = 1'b0;
    nxt_state = state;

	case (state)
	  IDLE : begin
		//if send is asserted begin state machine process
		if(send) begin
		//next state to DEAD_WAIT
		nxt_state=DEAD_WAIT;
		end
	  end
	  DEAD_WAIT : begin
		//wait for one clock cycle to allow cmdROM
		//to process  data to its output
		//then next state is TRANSMIT
		if(wait_done) begin
		nxt_state=TRANSMIT;
		// assert transmit data to UART
		trmt=1'b1;
		//assert increment address to get next bit
		inc_addr=1'b1;
		end
	  end
	  TRANSMIT: begin
		
		//if transmission is done 
		// and IF last_byte is reached go into IDLE
		// ELSE next state is DEAD wait to wait for
		// ROM to access data
		if(tx_done) begin
			if(last_byte) begin
				nxt_state=IDLE;
			end 
			else begin
				nxt_state=DEAD_WAIT;
			end
		end 
		else begin
			nxt_state = TRANSMIT;
		end
	  end
	  default: begin
		 nxt_state=IDLE;
	  end
	endcase
	
  end
  
  
  //define signals for input to UART
  logic rx_rdy,clr_rx_rdy;
  logic [7:0] rx_data;
  
  //////////////////////////////
  //UART Instantiated here ///// 
  //////////////////////////////
  
    UART UART_def(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy),.clr_rx_rdy(clr_rx_rdy),
					.rx_data(rx_data),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done));
	
	
	//assert response received signal(RN-52 sends x0A) signal
	// if rx_rdy is true and rx_data is x0A
	assign resp_rcvd = (rx_rdy && (rx_data == 8'h0A))? 1'b1 : 1'b0;
	assign clr_rx_rdy = rx_rdy;//clear rx ready to rx_rdy to clear when rx rdy is asserted
	
endmodule
`default_nettype wire