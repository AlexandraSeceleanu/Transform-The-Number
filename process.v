`timescale 1ns / 1ps

module process (
        input                clk,		    	// clock 
        input  [23:0]        in_pix,	        // valoarea pixelului de pe pozitia [in_row, in_col] din imaginea de intrare (R 23:16; G 15:8; B 7:0)
        input  [8*512-1:0]   hiding_string,     // sirul care trebuie codat
        output reg [6-1:0]   row, col, 	        // selecteaza un rand si o coloana din imagine
        output reg           out_we, 		    // activeaza scrierea pentru imaginea de iesire (write enable)
        output reg [23:0]    out_pix,	        // valoarea pixelului care va fi scrisa in imaginea de iesire pe pozitia [out_row, out_col] (R 23:16; G 15:8; B 7:0)
        output reg           gray_done,		    // semnaleaza terminarea actiunii de transformare in grayscale (activ pe 1)
        output               compress_done,		// semnaleaza terminarea actiunii de compresie (activ pe 1)
        output               encode_done        // semnaleaza terminarea actiunii de codare (activ pe 1)
    );	
	 
	 //declararea variabilelor
	reg[2:0] state = 0;
	reg[2:0] next_state;
	reg[23:0] min = 0;
	reg[23:0] max = 0;
	reg[23:0] media = 0;
	reg[6-1:0] rand = 0;
   reg[6-1:0] coloana = 0;
   reg[23:0]  pix_in;
    
    //TODO - instantiate base2_to_base3 here
    
    //TODO - build your FSM here
	 
	 // sequential part
	always @(posedge clk) begin
		state<= next_state;
	end
	
	//combinational part
	always @(*)begin
		gray_done = 0;		
		out_we = 0;
		out_pix = 0;
		
		case(state)
		 0: begin            
			pix_in = in_pix;
			col = coloana;
			row = rand;
			next_state = 1;
		 end
		 
	
		 1:begin				//calculam minimul si maximul
		 
		 if(pix_in[23:16]< pix_in[15:8] && pix_in[23:16]< pix_in[7:0] && pix_in[15:8] < pix_in[7:0]) begin
		  min = pix_in[23:16];
		  max = pix_in[7:0];
		 end
		 else if(pix_in[23:16]< pix_in[15:8] && pix_in[23:16]< pix_in[7:0] && pix_in[7:0] < pix_in[15:8] ) begin
		  min = pix_in[23:16];
		  max = pix_in[15:8];
		 end
		 else if (pix_in[15:8]< pix_in[23:16] && pix_in[15:8]< pix_in[7:0] && pix_in[23:16] < pix_in[7:0]) begin
		  min = pix_in[15:8];
		  max = pix_in[7:0];
		 end
		 else if (pix_in[15:8]< pix_in[23:16] && pix_in[15:8]< pix_in[7:0] && pix_in[7:0] < pix_in[23:16]) begin
		  min = pix_in[15:8];
		  max = pix_in[23:16];
		 end
		 else if (pix_in[7:0]< pix_in[23:16] &&  pix_in[7:0] < pix_in[15:8] && pix_in[23:16] < pix_in[15:8]) begin
		  min = pix_in[7:0];
		  max = pix_in[15:8];
		 end
		 else if (pix_in[7:0]< pix_in[23:16] &&  pix_in[7:0] < pix_in[15:8] && pix_in[15:8] < pix_in[23:16]) begin
		  min = pix_in[7:0];
		  max = pix_in[23:16];
		 end 
		 else if (pix_in[7:0] == pix_in[23:16] &&  pix_in[7:0] == pix_in[15:8] && pix_in[15:8] == pix_in[23:16]) begin
		  min = pix_in[7:0];
		  max = pix_in[23:16];
		 end 
		 
		 else if (pix_in[7:0] < pix_in[23:16] &&  pix_in[15:8] == pix_in[23:16]) begin
		  min = pix_in[7:0];
		  max = pix_in[23:16];
		 end 
		 
		 else if (pix_in[15:8] < pix_in[7:0] && pix_in[7:0] == pix_in[23:16]) begin
		  min = pix_in[15:8];
		  max = pix_in[23:16];
		 end 
		 
		 else if (pix_in[23:16] < pix_in[15:8] && pix_in[15:8] == pix_in[7:0]) begin
		  min = pix_in[23:16];
		  max = pix_in[7:0];
		 end 
		 else if ( pix_in[7:0] < pix_in[15:8] &&  pix_in[7:0]== pix_in[23:16] ) begin
		  min = pix_in[7:0];
		  max = pix_in[15:8];
		 end 
		 else if ( pix_in[15:8] < pix_in[23:16] &&  pix_in[7:0]== pix_in[15:8] ) begin
		  min = pix_in[7:0];
		  max = pix_in[23:16];
		 end 
		  else if ( pix_in[23:16] < pix_in[7:0] &&  pix_in[23:16]== pix_in[15:8] ) begin
		  min = pix_in[23:16];
		  max = pix_in[7:0];
		 end 
		 next_state = 2;
		 end
		 
		 
		2:begin				//calculam media
		 
       out_we = 1;
		 media = (min + max)/ 2;
		 out_pix[15:8]= media;
		 out_pix[7:0] = 0;
		 out_pix[23:16] = 0;
		
		 		
	
		 if(col <= 62) begin       // verificam pe ce coloana suntem
		 coloana = coloana + 1 ;    // crestem coloana
		 next_state = 0;
		 end
		 else if(col == 63 && row <= 62)begin    // verificam daca suntem pe ultima coloana, dar nu si pe ultimul rand
		 coloana = 0;							
		 rand = rand + 1;                  // crestem randul
		 next_state = 0;
		 end
		 else if(col == 63)begin        // verificam daca suntem pe ultima coloana de pe ultimul rand
		 next_state = 3;
		 end
		 end
		
		3:begin
		gray_done = 1;            // terminarea transformarii grayscale 
		end
		
		
		 endcase 
	 end
endmodule
