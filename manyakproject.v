module manyakproject(clock_50, clock_25, start, high_button, low_button, 
							red_out, blue_out, green_out, hsync, vsync, nsync);
	
	input clock_50;
	output reg clock_25 = 0;
	input start;
	input high_button;
	input low_button;
	wire red_sig;
	wire green_sig;
	wire blue_sig;
	output wire hsync;
	output wire vsync;
	output wire nsync;
	
	wire[3:0] packet;
	wire[11:0] received_yes;
	
	wire[11:0] received1;
	wire[11:0] received2;
	wire[11:0] received3;
	wire[11:0] received4;
	wire[11:0] dropped1;
	wire[11:0] dropped2;
	wire[11:0] dropped3;
	wire[11:0] dropped4;
	wire[17:0] data1;
	wire[17:0] data2;
	wire[17:0] data3;
	wire[17:0] data4;
	wire[11:0] output_count1;
	wire[11:0] output_count2;
	wire[11:0] output_count3;
	wire[11:0] output_count4;
	wire[3:0] outputted_buffer_packet;
	
	output wire[7:0] blue_out;
	output wire[7:0] red_out;
	output wire[7:0] green_out;
	
	assign blue_out[0] = blue_sig;
	assign blue_out[1] = blue_sig;
	assign blue_out[2] = blue_sig;
	assign blue_out[3] = blue_sig;
	assign blue_out[4] = blue_sig;
	assign blue_out[5] = blue_sig;
	assign blue_out[6] = blue_sig;
	assign blue_out[7] = blue_sig;
	
	assign red_out[0] = red_sig;
	assign red_out[1] = red_sig;
	assign red_out[2] = red_sig;
	assign red_out[3] = red_sig;
	assign red_out[4] = red_sig;
	assign red_out[5] = red_sig;
	assign red_out[6] = red_sig;
	assign red_out[7] = red_sig;
	
	assign green_out[0] = green_sig;
	assign green_out[1] = green_sig;
	assign green_out[2] = green_sig;
	assign green_out[3] = green_sig;
	assign green_out[4] = green_sig;
	assign green_out[5] = green_sig;
	assign green_out[6] = green_sig;
	assign green_out[7] = green_sig;
	
	always @(posedge clock_50) begin
		clock_25 <= ~clock_25;
	end
	
	GetInput(clock_50, start, high_button, low_button, packet, received_yes);
	
	BufferContainer(clock_50, packet, received_yes, received1, received2, 
						received3, received4, dropped1, dropped2, dropped3, dropped4, 
						data1, data2, data3, data4, output_count1, output_count2, 
						output_count3, output_count4, outputted_buffer_packet);
						
	DisplayM(clock_50, clock_25, packet, received1, received2, received3, received4, dropped1, dropped2, dropped3, 
                dropped4, data1, data2, data3, data4, output_count1, output_count2, output_count3, 
					 output_count4, outputted_buffer_packet, red_sig, green_sig, blue_sig, hsync, vsync, nsync);
	
endmodule
