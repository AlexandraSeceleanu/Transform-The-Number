`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module base2_to_base3(
    output reg  [31 : 0]  base3_no, 
    output reg         done,
    input    [15 : 0]  base2_no,
    input              en,
    input              clk);
	 
	 
	 //declararea variabilelor necesare
 	reg[2:0] state = 0;
	reg[2:0] next_state;
	reg[15 : 0] base2_no_r;
	reg[15 : 0] N1;
	reg[15 : 0] D1;
	reg[7:0] i;
	wire[15 : 0] R1;
	wire[15 : 0] Q1;
	
	 // instantiez modulul div_algo
	div_algo uut(
	    .Q(Q1),
		 .R(R1),
		 .N(N1),
		 .D(D1) );
		 
		 
   // sequential part
	always @(posedge clk) begin
		state<= next_state;
	end
	
	
	//combinational part
	always @(*)begin
		done = 0;
		
		case(state)
		 0: begin   			//READ
		   i = 0;
			base3_no = 0;
			if (en == 1) begin			//verificam existenta unui nr in baza 2
			base2_no_r = base2_no;      // il punem in registrul auxiliar  base2_no_r si trecem la urmatoarea stare
			next_state = 1;
			end 
			else next_state = 0;
			end
	
		1: begin					//EXEC: efectuam operatia de impartire
		 N1= base2_no_r;
		 D1 = 3;
		 next_state = 2;
		 end
		
		2: begin					//EXEC2: formam nr in baza 3 si in functie de valoarea catului aflam urmatoarea stare
		base3_no[i+:2]= R1[1:0];    
		 i = i + 2;
		 base2_no_r = Q1;
		 
		 if(base2_no_r == 0)begin  //daca catul e zero impartirea s-a terminat
		   next_state = 3;
		end
		else if(base2_no_r != 0)begin // daca catul e diferit de zero, efectuam inca o impartire
			next_state =  1;
		end
		end
		
		3: begin						//DONE
		 done = 1;
		 next_state = 0;
		 end
		 
	endcase
	 end
	
endmodule
