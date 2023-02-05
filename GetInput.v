module GetInput(clock, start, high_button, low_button, out_number, received_yes);

	input clock;
	input start;
	input high_button;
	input low_button;
	output reg[3:0] out_number;
	output reg[11:0] received_yes = 12'b00000000000;
	
	reg[3:0] num = 4'b0000;
	wire edge_start;
	wire edge_low;
	wire edge_high;
	reg run = 0;
	integer count = 0;
	
	FallingEdge(clock, start, edge_start);
	FallingEdge(clock, high_button, edge_high);
	FallingEdge(clock, low_button, edge_low);
	
	always @(posedge clock) begin
		if(count == 4) begin
			out_number = num;
			count = 0;
			received_yes = received_yes + 1;
			run = 0;
			num = 4'b0000;
		end else if(edge_start) begin
			run = 1;
			count = 0;
		end else if(edge_high) begin
			if(run) begin
				num[3] <= num[2];
				num[2] <= num[1];
				num[1] <= num[0];
				num[0] <= 1;
				count <= count + 1;
			end
		end else if(edge_low) begin
			if(run) begin
				num[3] <= num[2];
				num[2] <= num[1];
				num[1] <= num[0];
				num[0] <= 0;
				count <= count + 1;
			end
		end
	end

endmodule


module FallingEdge (clock, signal, edge_signal);

	input clock;
	input signal;
	output reg edge_signal;

	reg past_signal = 1;

	always @(posedge clock) begin
		 past_signal <= signal;
		 edge_signal <= past_signal && !signal;
	end

endmodule
