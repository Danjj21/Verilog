`default_nettype none
module Equalizer_tb1();

reg clk,RST_n;
reg next_n,prev_n,Flt_n;
reg [11:0] LP,B1,B2,B3,HP,VOL;

wire [7:0] LED;
wire ADC_SS_n,ADC_MOSI,ADC_MISO,ADC_SCLK;
wire I2S_data,I2S_ws,I2S_sclk;
wire cmd_n,RX_TX,TX_RX;
wire lft_PDM,rght_PDM;
wire lft_PDM_n,rght_PDM_n;


logic sht_dwn,rst_n;
//////////////////////
// Instantiate DUT //
////////////////////
Equalizer iDUT(.clk(clk),.RST_n(RST_n),.LED(LED),.ADC_SS_n(ADC_SS_n),
                .ADC_MOSI(ADC_MOSI),.ADC_SCLK(ADC_SCLK),.ADC_MISO(ADC_MISO),
                .I2S_data(I2S_data),.I2S_ws(I2S_ws),.I2S_sclk(I2S_sclk),.cmd_n(cmd_n),
				.sht_dwn(sht_dwn),.lft_PDM(lft_PDM),.rght_PDM(rght_PDM),
				.lft_PDM_n(lft_PDM_n),.rght_PDM_n(rght_PDM_n),.Flt_n(Flt_n),
				.next_n(next_n),.prev_n(prev_n),.RX(RX_TX),.TX(TX_RX));
	
	
//////////////////////////////////////////
// Instantiate model of RN52 BT Module //
////////////////////////////////////////	
RN52 iRN52(.clk(clk),.RST_n(RST_n),.cmd_n(cmd_n),.RX(TX_RX),.TX(RX_TX),.I2S_sclk(I2S_sclk),
           .I2S_data(I2S_data),.I2S_ws(I2S_ws));

//////////////////////////////////////////////
// Instantiate model of A2D and Slide Pots //
////////////////////////////////////////////		   
A2D_with_Pots iPOTs(.clk(clk),.rst_n(rst_n),.SS_n(ADC_SS_n),.SCLK(ADC_SCLK),.MISO(ADC_MISO),
                    .MOSI(ADC_MOSI),.LP(LP),.B1(B1),.B2(B2),.B3(B3),.HP(HP),.VOL(VOL));
		

		
initial begin
  
  clk=1'b0;
  RST_n=1'b0;
  next_n = 1'b0;
  prev_n = 1'b0;
  Flt_n=1'b1;
  rst_n=1'b0;
  LP=12'h001;
  HP=12'h001;
  B1=12'h001;
  B2=12'h001;
  B3=12'h001;
  VOL=12'h100;
  
  //deassert reset
  repeat (5) @ (posedge clk);
  RST_n=1'b1;
  rst_n=1'b1;
  Flt_n=1'b0;
  repeat (5000000) @ (posedge clk);
  
end

always
  #5 clk = ~ clk;
  
endmodule


//////////////////////////////////////////////
//Task to set //
////////////////////////////////////////////	

task SendCmd(input [7:0] cmd2send, input [15:0] data);
begin2send

@(posedge clk); // wait for posedge clk

@(posedge clk);

end
endtask

//////////////////////////////////////////////
//Task to set tone_hex_lft/right.txt //
////////////////////////////////////////////
task SendCmd(input [7:0] cmd2send, input [15:0] data);
begin2send

@(posedge clk); // wait for posedge clk

@(posedge clk);

end
endtask	
`default_nettype wire


























	  
