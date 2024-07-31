module router_fsm(
	input clk,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
	input [1:0]data_in,
	output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state
	);
	
parameter 		DECODE_ADDRESSS	=3'b000,
					LOAD_FIRST_DATA	=3'b001,
					LOAD_DATA			=3'b010,
					LOAD_PARITY			=3'b011,
					CHECK_PARITY_ERROR=3'b100,
					FIFO_FULL_STATE	=3'b101,
					WAIT_TILL_EMPTY	=3'b110,
					LOAD_AFTER_FULL	=3'b111;
					
reg [2:0]PS,NS;
reg [1:0]addr;

//data_in in 2 bit variable addr
always@(data_in)
	addr=data_in; 

//present state logic
always@(posedge clk)
	if(!resetn)
		PS<=DECODE_ADDRESSS;
	else if(soft_reset_0||soft_reset_1||soft_reset_2)
		PS<=DECODE_ADDRESSS;
	else
		PS<=NS;

always@(*)
	begin
		case(PS)
			DECODE_ADDRESSS: begin
									if((pkt_valid&(data_in[1:0]==0)&fifo_empty_0)|
										(pkt_valid&(data_in[1:0]==1)&fifo_empty_1)|
										(pkt_valid&(data_in[1:0]==2)&fifo_empty_2))
										NS=LOAD_FIRST_DATA;
									else if((pkt_valid&(data_in[1:0]==0)&!fifo_empty_0)|
										(pkt_valid&(data_in[1:0]==1)&!fifo_empty_1)|
										(pkt_valid&(data_in[1:0]==2)&!fifo_empty_2))
										NS=WAIT_TILL_EMPTY;
									else
										NS=DECODE_ADDRESSS;
									end
			
			LOAD_FIRST_DATA:	begin
										NS=LOAD_DATA;
									end
													
			LOAD_DATA	:		begin
									if(!fifo_full&&!pkt_valid)
										NS=LOAD_PARITY;
									else if(fifo_full)
										NS=FIFO_FULL_STATE;
									else
										NS=LOAD_DATA;
									end
													
			LOAD_PARITY:		begin
										NS=CHECK_PARITY_ERROR;
									end
			
			CHECK_PARITY_ERROR:
									begin
										if(fifo_full)
											NS=FIFO_FULL_STATE;
										else	
											NS=DECODE_ADDRESSS;
										end
													
			FIFO_FULL_STATE:	begin
										if(!fifo_full)
											NS=LOAD_AFTER_FULL;
										else
											NS=FIFO_FULL_STATE;
										end
													
			WAIT_TILL_EMPTY:	begin
										if((fifo_empty_0&&(addr==0))||
											(fifo_empty_1&&(addr==1))||
											(fifo_empty_2&&(addr==2)))
											NS=LOAD_FIRST_DATA;
										else
											NS=WAIT_TILL_EMPTY;
										end

			LOAD_AFTER_FULL:	begin
										if(!parity_done&&low_pkt_valid)
											NS=LOAD_PARITY;
										else if(!parity_done&&!low_pkt_valid)
											NS=LOAD_DATA;
										else if(parity_done)
											NS=DECODE_ADDRESSS;
										else
											NS=DECODE_ADDRESSS;
										end
			endcase
		end
		
	assign detect_add=(PS==DECODE_ADDRESSS)?1:0;
	assign ld_state=(PS==LOAD_DATA)?1:0;
	assign laf_state=(PS==LOAD_AFTER_FULL)?1:0;
	assign full_state=(PS==FIFO_FULL_STATE)?1:0;
	assign write_enb_reg=((PS==LOAD_DATA)||(PS==LOAD_PARITY)||(PS==LOAD_AFTER_FULL))?1:0;
	assign rst_int_reg=(PS==CHECK_PARITY_ERROR)?1:0;
	assign lfd_state=(PS==LOAD_FIRST_DATA)?1:0;
	assign busy=((PS==DECODE_ADDRESSS)||(PS==LOAD_DATA))?0:1;
endmodule
															
												
