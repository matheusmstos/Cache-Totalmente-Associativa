module MemoryBlock (address, data, clock,  wren, q);

	input clock;
	input	[7:0] data;
	input	[4:0] address;
	input wren;
	output[7:0] q;
	
	ramlpm MB1 (address, clock, data, wren, q);
	
endmodule

module decod7_1(cin, cout);//transformar o binario em hexadecimal
	input [3:0]cin;
	output reg [0:6]cout;

	always @(cin)
	begin
		case(cin)  //abcdefg
		0: cout = 	7'b0000001;
		1: cout = 	7'b1001111;
		2: cout = 	7'b0010010; 
		3: cout = 	7'b0000110; 
		4: cout = 	7'b1001100; 
		5: cout = 	7'b0100100; 
		6: cout = 	7'b0100000; 
		7: cout = 	7'b0001111; 
		8: cout = 	7'b0000000; 
		9: cout = 	7'b0000100; 
		10: cout = 	7'b0001000; //A
		11: cout = 	7'b1100000; //B
		12: cout = 	7'b0110001; //C
		13: cout = 	7'b1000010; //D
		14: cout = 	7'b0110000; //E
		15: cout = 	7'b0111000; //F
		default : cout = 0;
		endcase
	end	
	
endmodule

module parte_1 (SW, LEDR, HEX0, HEX1, KEY);
	
	input [17:0]SW;
	input [17:0]LEDR;
	input [1:0]KEY;
	output [0:6]HEX0;
	output [0:6]HEX1;
	wire [7:0]C;
	
					 //(adress,   data,    clock,  wren,    q)
	MemoryBlock m1 (SW[12:8], SW[7:0], KEY[0], SW[17] , C[7:0]);
	decod7_1 d0 (C[3:0], HEX0);
	decod7_1 d1 (C[7:4], HEX1);
	
endmodule
