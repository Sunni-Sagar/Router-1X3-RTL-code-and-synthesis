// Code your design here
module router_fifo(
	input clk,resetn,write_enb,soft_reset,read_enb,lfd_state,
	input [7:0]data_in,
	output reg empty,full,
	output reg [7:0]data_out
	);

reg [4:0]count; 				// count 0 to 16
reg [6:0] counter;  		// payload + parity
reg [3:0] rd_ptr,wr_ptr;

reg [8:0]mem[15:0];	//16x9 memory

integer i;

 always@(count)
    begin
      empty=(count==0);
      full=(count==16);
    end
	
//counter block
  always@(posedge clk) 
    begin
      if(!resetn)
		count<=0;
	  else if(soft_reset)
        count<=0;
      else if((!full&&write_enb)&&(!empty&&read_enb))
        count<=count;
      else if(write_enb&&!full)
        count<=count+1;
      else if(read_enb&&!empty)
        count<=count-1;
      else 
        count<=count;
    end
	
	//counter block and read block
	always@(posedge clk)
	if(!resetn)
			begin counter<=0; data_out<=8'hzz; end
	else if (soft_reset)
			begin counter<=0; data_out<=8'hzz; end
	else if(empty)
			data_out<=8'hzz;
	else 
		begin
          if(read_enb&&!empty)
						begin
			         counter<=mem[rd_ptr[0]][7:2]+5'b1;
						for(i=0;i<counter;i=i+1)
						data_out<=mem[rd_ptr];
						end
					else 
					begin
						if(counter!=0)
							counter<=counter-1;
						else 
							counter<=counter;
					end
			
		end
		
	
	//write block
always@(posedge clk)
	begin
		if(write_enb&&!full)
		mem[wr_ptr]<={lfd_state,data_in};
		else
		mem[wr_ptr]<=mem[wr_ptr];
	end
	
	//pointer update
always@(posedge clk )
  begin
    if(!resetn)
      begin 
        wr_ptr<=0;
        rd_ptr<=0;
      end
	 else if(soft_reset)
      begin 
        wr_ptr<=0;
        rd_ptr<=0;
      end
    else 
      begin
        if(!full&&write_enb)
          wr_ptr<=wr_ptr+1;
        else
          wr_ptr<=wr_ptr;
			if(!empty&&read_enb)
			rd_ptr<=rd_ptr+1;
			else
			rd_ptr<=rd_ptr;
		end
	end
endmodule
