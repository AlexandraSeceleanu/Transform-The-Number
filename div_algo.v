`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module div_algo(
	output reg [15:0] Q,
	output reg [15:0] R, 
	input [15:0] N,
	input [15:0] D );
	
	reg signed[4:0] i;
	
	always @ (*) begin
		R = 0;                  		 //Initialize quotient and remainder to zero
		Q = 0;                  		//Initialize quotient and remainder to zero
		for(i=15;i>=0;i=i-1) begin  	// Where n is number of bits in N
			R = R<<1;                  // Left-shift R by 1 bit
			R[0] = N[i];					//Set the least-significant bit of R equal to bit i of the numerator
			if(R>=D) begin
				R = R-D;
				Q[i] = 1;
			end
		end
	end

endmodule
