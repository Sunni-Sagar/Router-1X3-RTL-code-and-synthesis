module router_reg(clk,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_pkt_valid,dout);
	input clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
	input [7:0]data_in;
	output reg parity_done,low_pkt_valid,err;
	output reg [7:0] dout;
	
	reg [7:0] header,fifo_full_state,internal_parity,packet_parity;
	
		//dout block
	always@(posedge clk)
		if(!resetn)
			begin
			dout<=0;
			header<=0;
			fifo_full_state<=0;
			end
		else if(detect_add&&pkt_valid&&data_in!=3)
			header<=data_in;
		else if(lfd_state==1)
			dout<=header;
		else if(ld_state&&~fifo_full)
			dout<=data_in;
		else if(ld_state&&fifo_full)
			fifo_full_state<=data_in;
		else if(laf_state==1)
			dout<=fifo_full_state;
		else
			dout<=dout;
	
// low pkt valid	
	always@(posedge clk)
		if(!resetn)
			low_pkt_valid<=0;
		else if(rst_int_reg==1)
			low_pkt_valid<=0;
		else if(ld_state&&~pkt_valid)
			low_pkt_valid<=1;
		else
			low_pkt_valid<=low_pkt_valid;
	
	// internal parity block
	always@(posedge clk)
		if(!resetn)
			internal_parity<=0;
		else if(detect_add)
			internal_parity<=0;
		else if(lfd_state&&pkt_valid)
			internal_parity<=internal_parity^header;
		else if(pkt_valid&&ld_state&&~full_state)
			internal_parity<=internal_parity^data_in;
		else
			internal_parity<=internal_parity;
			
	//packet parity
	always@(posedge clk)
		if(!resetn)
			packet_parity<=0;
		else if(detect_add)
			packet_parity<=0;
		else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && !parity_done && low_pkt_valid))
			packet_parity<=data_in;
		else
			packet_parity<=packet_parity;
			
	//parity done
	always@(posedge clk)
		begin
			if(!resetn)
				parity_done<=0;
			else if(detect_add)
				parity_done<=0;
			else if((ld_state && !fifo_full && !pkt_valid)
              ||(laf_state && low_pkt_valid && !parity_done))
	  parity_done<=1;
	end
			
			
	//err
	always@(posedge clk)
		if(!resetn)
		err<=0;
		else if(parity_done==1)
			begin
				if(internal_parity==packet_parity)
				err<=0;
				else
				err<=1;
			end
		else
			err<=0;
	
endmodule
	
