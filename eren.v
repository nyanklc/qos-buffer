module eren(clock, num, received, dropped, current, data, out_now, outputted_packet);
	
	input clock;
	input wire[1:0]num;
	output reg[11:0] received = 12'b000000000000;
	output reg[11:0] dropped = 12'b000000000000;
	output reg[3:0] current = 4'b0000;
	output reg[11:0] data = 12'b000000000000; // oldest num -> 2 LSB
	input wire[11:0] out_now;
	reg[11:0] past_out_now = 0;
	output reg[1:0] outputted_packet;
	
	integer i = 3;
	integer test = 0;
	integer past_test = 0;
	
	always @(num) begin
		test = test + 1;
	end
	
	always @(posedge clock) begin
		if(test > past_test) begin
			past_test = test;
			if(out_now > past_out_now) begin
				past_out_now = out_now;
//				if(current > 4'b0000) begin
//					current = current - 1;
//					outputted_packet[0] = data[(6-current)*3];
//					outputted_packet[1] = data[(6-current)*3 + 1];
//				end
			end else begin
				if(current < 4'b1010) begin // buffer is not full, only add packet
					received = received + 1;
					current = current + 1;
					for(i = 2; i<10; i = i + 1) begin
						data[i-2] <= data[i];
					end
					data[10] <= num[0];
					data[11] <= num[1];
				end else begin // buffer is full, also drop happens
					received = received + 1;
					dropped = dropped + 1;
					for(i = 2; i<9; i = i + 1) begin
						data[i-2] <= data[i];
					end
					data[10] <= num[0];
					data[11] <= num[1];
				end
			end
		end
	end
	
endmodule
