module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output R,
    output G,
    output Y
);

reg [2:0] ST=3'd0;
reg [10:0] times=3'd0;
reg [10:0] count=11'd0;
reg red, green, yellow;

always@(posedge clk or posedge rst)
begin

	if(rst)
	begin
		count<=11'd0;
		ST<=1'd0;
		red<=1'b0;
                green<=1'b1;
                yellow<=1'b0;
	end

	else if(pass==1)
	begin
		count<=count+11'd1;

		if(ST!=3'd0)
		begin
          		count<=11'd0;
          		ST<=3'd0;
			red<=1'b0;
         		green<=1'b1;
          		yellow<=1'b0;
		end
	end	

	else
	begin

		count<=count+11'd1;

        	case(ST)
        	3'd0: 
		begin
			times=11'd1023;
			if(count==times)
              		begin
                		count<=11'd0;
                		ST<=3'd1;
				red<=1'b0;
                		green<=1'b0;
                		yellow<=1'b0;

                	end              
               	end

        	3'd1: 
		begin
			times=11'd127;
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd2;
                		red<=1'b0;
                		green<=1'b1;
                		yellow<=1'b0;
                	end              
               	end

        	3'd2: 
		begin
			times=11'd127;
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd3;
                		red<=1'b0;
                		green<=1'b0;
                		yellow<=1'b0;
                	end              
               	end

		3'd3: 
		begin
			times=11'd127;
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd4;
                		red<=1'b0;
                		green<=1'b1;
                		yellow<=1'b0;
                	end              
               	end

        	3'd4: 
		begin   
			times=11'd127;    
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd5;
                		red<=1'b0;
                		green<=1'b0;
                		yellow<=1'b1;
                	end              
               	end

       	 	3'd5: 
		begin   
			times=11'd511;
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd6;
                		red<=1'b1;
                		green<=1'b0;
                		yellow<=1'b0;
                	end              
               	end

		3'd6: 
		begin  
			times=11'd1023;             
			if(count==times)
              		begin
				count<=11'd0;
                		ST<=3'd0;
                		red<=1'b0;
                		green<=1'b1;
                		yellow<=1'b0;
                	end              
               	end
        	endcase
	end
end

assign G=green;
assign Y=yellow;
assign R=red;

endmodule