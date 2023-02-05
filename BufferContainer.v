module BufferContainer(clock, in_number, received_yes, received1, received2, received3, received4,
									dropped1, dropped2, dropped3, dropped4, data1, data2, data3, data4, 
									output_count1, output_count2, output_count3, output_count4, 
									outputted_buffer_packet);

   input clock;
   integer clock_count = 0;
   input wire[3:0] in_number;
	input wire[11:0] received_yes;
   output wire[11:0] received1;
   output wire[11:0] received2;
   output wire[11:0] received3;
   output wire[11:0] received4;
   output wire[11:0] dropped1;
   output wire[11:0] dropped2;
   output wire[11:0] dropped3;
   output wire[11:0] dropped4;
   wire[3:0] current1;
   wire[3:0] current2;
   wire[3:0] current3;
   wire[3:0] current4;
   output wire[17:0] data1;
   output wire[17:0] data2;
   output wire[17:0] data3;
   output wire[17:0] data4;
	output wire[11:0] output_count1;
	output wire[11:0] output_count2;
	output wire[11:0] output_count3;
	output wire[11:0] output_count4;
   output reg[3:0] outputted_buffer_packet;
   wire[1:0] outputted_packet1;
   wire[1:0] outputted_packet2;
   wire[1:0] outputted_packet3;
   wire[1:0] outputted_packet4;
	
	reg[11:0] received_yes1 = 12'b000000000000;
	reg[11:0] received_yes2 = 12'b000000000000;
	reg[11:0] received_yes3 = 12'b000000000000;
	reg[11:0] received_yes4 = 12'b000000000000;	
	
	reg[2:0] num1;
	reg[2:0] num2;
	reg[2:0] num3;
	reg[2:0] num4;
	
	Buffer eren(clock, received_yes1, num1, received1, dropped1, current1, data1, output_count1, outputted_packet1);
	Buffer erenn(clock, received_yes2, num2, received2, dropped2, current2, data2, output_count2, outputted_packet2);
	Buffer erennn(clock, received_yes3, num3, received3, dropped3, current3, data3, output_count3, outputted_packet3);
	Buffer erennnn(clock, received_yes4, num4, received4, dropped4, current4, data4, output_count4, outputted_packet4);
	
	wire[1:0] max_point_buffer;
	
	reg letsgo = 0;
	
	Grader canim(letsgo, current1, current2, current3, current4, max_point_buffer);
	
	integer past_received_yes = 0;
	
	always @(posedge clock) begin
		if(clock_count == 150000000) begin // MORBIN TIME
			clock_count = 0;
			letsgo = ~letsgo;
			// output the highest graded buffer's packet
			case (max_point_buffer)
				2'b00: begin
					if(current1 > 4'b0000) begin
						outputted_buffer_packet[3:2] = 2'b00;
						outputted_buffer_packet[1:0] = outputted_packet1[1:0];
						num1 = 3'b100; received_yes1 = received_yes1 + 1; // tell buffer 1 that it is required to output
					end
				end
				2'b01: begin
					if(current2 > 4'b0000) begin
						outputted_buffer_packet[3:2] = 2'b01;
						outputted_buffer_packet[1:0] = outputted_packet2[1:0];
						num2 = 3'b100; received_yes2 = received_yes2 + 1; // tell buffer 2 that it is required to output
					end
				end
				2'b10: begin
					if(current3 > 4'b0000) begin
						outputted_buffer_packet[3:2] = 2'b10;
						outputted_buffer_packet[1:0] = outputted_packet3[1:0];
						num3 = 3'b100; received_yes3 = received_yes3 + 1; // tell buffer 3 that it is required to output
					end
				end
				2'b11: begin
					if(current4 > 4'b0000) begin
						outputted_buffer_packet[3:2] = 2'b11;
						outputted_buffer_packet[1:0] = outputted_packet4[1:0];
						num4 = 3'b100; received_yes4 = received_yes4 + 1; // tell buffer 4 that it is required to output
					end
				end
			endcase
		end else begin // RECEIVE TIME
			clock_count = clock_count + 1;
			if(received_yes > past_received_yes) begin
				past_received_yes = received_yes;
				case (in_number[3:2])
					2'b00: begin
						num1[2] = 0;
						num1[1:0] = in_number[1:0];
						received_yes1 = received_yes1 + 1;
					end
					2'b01: begin
						num2[2] = 0;
						num2[1:0] = in_number[1:0];
						received_yes2 = received_yes2 + 1;
					end
					2'b10: begin
						num3[2] = 0;
						num3[1:0] = in_number[1:0];
						received_yes3 = received_yes3 + 1;
					end
					2'b11: begin
						num4[2] = 0;
						num4[1:0] = in_number[1:0];
						received_yes4 = received_yes4 + 1;
					 end
				endcase
			end	
		end
		
	end
	
endmodule

module Buffer(clock, received_yes, num, received, dropped, current, data, output_count, outputted_packet);
	
	input clock;
	input wire[11:0] received_yes;
	reg[11:0] past_received_yes = 0;
	input wire[2:0]num; // 3 bit number, if output is pulled from this buffer, send 100 as num
	output reg[11:0] received = 12'b000000000000;
	output reg[11:0] dropped = 12'b000000000000;
	output reg[3:0] current = 4'b0000;
	output reg[17:0] data = 18'b100100100100100100; // oldest num -> 3 LSB, 100 is put in data to indicate empty cell
	output reg[11:0] output_count = 12'b000000000000;
	output reg[1:0] outputted_packet;
	
	integer i = 3;
	integer current_int = 0;
	
	always @(posedge clock) begin
		if(received_yes > past_received_yes) begin
			past_received_yes = received_yes;
			if(num == 3'b100) begin // output is taken from this buffer 
				if(current > 4'b0000) begin
					for(i = 3; i<18; i = i + 1) begin
						data[i-3] <= data[i];
					end
					data[17] <= 1;
					data[16] <= 0;
					data[15] <= 0;
					current = current - 1;
					if(output_count == 0)
						output_count = 1;
					else if(output_count == 1)
						output_count = 2;
					else
						output_count = output_count + 1;
				end
			end else begin
				if(current < 4'b0110) begin // buffer is not full, only add packet
					current_int = current[0] + 2*current[1] + 4*current[2] + 8*current[3];
					data[current_int + current_int + current_int] <= num[0];
					data[current_int + current_int + current_int + 1] <= num[1];
					data[current_int + current_int + current_int + 2] <= num[2];
					if(current_int == 0) begin
						outputted_packet[0] <= num[0];
						outputted_packet[1] <= num[1];
					end else begin
						outputted_packet[0] <= data[0];
						outputted_packet[1] <= data[1];
					end
					
					if(received == 0)
						received = 1;
					else if(received == 1)
						received = 2;
					else
						received = received + 1;
					
					current = current + 1;
				end else begin // buffer is full, also drop happens
					
					if(received == 0)
						received = 1;
					else if(received == 1)
						received = 2;
					else
						received = received + 1;
					
					dropped = dropped + 1;
					outputted_packet[0] <= data[3];
					outputted_packet[1] <= data[4];
					for(i = 3; i<18; i = i + 1) begin
						data[i-3] <= data[i];
					end
					data[17] <= num[2];
					data[16] <= num[1];
					data[15] <= num[0];
				end
			end
		end
	end
	
endmodule

module Grader(letsgo, current1, current2, current3, current4, max_point_buffer);

	input wire letsgo;
	input wire[3:0] current1;
	input wire[3:0] current2;
	input wire[3:0] current3;
	input wire[3:0] current4;
	output reg[1:0] max_point_buffer;
	
	integer point1;
	integer point2;
	integer point3;
	integer point4;
	
	integer latency1 = 800;
	integer latency2 = 600;
	integer latency3 = 400;
	integer latency4 = 200;
	integer reliability1 = 40;
	integer reliability2 = 95;
	integer reliability3 = 150;
	integer reliability4 = 210;
	
	always @(letsgo) begin
	
		point1 = latency1 + reliability1*current1;
		point2 = latency2 + reliability2*current2;
		point3 = latency3 + reliability3*current3;
		point4 = latency4 + reliability4*current4;
		
	
		if(current1==0) begin
		point1=0;
		end
		if(current2==0) begin
		point2=0;
		end
		if(current3==0) begin
		point3=0;
		end
		if(current4==0) begin
		point4=0;
		end
	
		if(point2 > point1) begin
			if(point4 > point3) begin
				if(point4 > point2)
					max_point_buffer= 2'b11;
				else
					max_point_buffer= 2'b01;
			end else begin
				if(point3 > point2)
					max_point_buffer= 2'b10;
				else
					max_point_buffer= 2'b01;
			end
		end else begin
			if(point4 > point3) begin
				if(point4 > point1)
					max_point_buffer= 2'b11;
				else
					max_point_buffer= 2'b00;
			end else begin
				if(point3 > point1)
					max_point_buffer= 2'b10;
				else
					max_point_buffer= 2'b00;
			end
		end
	end

endmodule




module tb_bc();

    reg clock = 0;
    reg[3:0] in_number;
    wire[11:0] received1;
    wire[11:0] received2;
    wire[11:0] received3;
    wire[11:0] received4;
    wire[11:0] dropped1;
    wire[11:0] dropped2;
    wire[11:0] dropped3;
    wire[11:0] dropped4;
    wire[3:0] current1;
    wire[3:0] current2;
    wire[3:0] current3;
    wire[3:0] current4;
    wire[17:0] data1;
    wire[17:0] data2;
    wire[17:0] data3;
    wire[17:0] data4;
    wire[3:0] outputted_buffer_packet;
	 wire[1:0] outputted_packet1;
    wire[1:0] outputted_packet2;
    wire[1:0] outputted_packet3;
    wire[1:0] outputted_packet4;
	 reg[11:0] received_yes = 12'b000000000000;
	 wire[12:0] received_yes1;
	 wire[12:0] received_yes2;
	 wire[12:0] received_yes3;
	 wire[12:0] received_yes4;

    BufferContainer noyan(clock, in_number, received_yes, received1, received2, 
                            received3, received4, dropped1, dropped2, dropped3, 
                            dropped4, 
                            data1, data2, data3, data4, outputted_buffer_packet, received_yes1, received_yes2, received_yes3, received_yes4);

    integer i = 0;

    parameter delay = 10;

    initial begin
        for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0011;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0101;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0110;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0000;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b1111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b1011;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  for(i = 0;i <40; i = i + 1) begin
            #(delay) clock = ~clock;
        end
        in_number = 4'b0111;received_yes = received_yes + 1;
		  
        
		  
    end

endmodule
