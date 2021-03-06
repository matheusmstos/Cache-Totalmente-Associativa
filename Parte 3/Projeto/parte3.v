module cache_totalmente_associativa (
	input Clock,
	input Write,
	input [6:0] Tag_Input, 		// tag que vem do circuito
	input [4:0] BlockIn, 		// dado que esta indo do circuito para a cache
	input [4:0] M_Block_C, 		// dado que esta indo da memoria para a cache
	
	output reg [6:0] Tag_Output, 	//Tag de acesso a memoria
	output reg [4:0] BlockOut, 	// o bloco da cache para o circuito
	output reg [4:0] C_Block_M, 	// dado que esta indo da cache para a memoria
	output reg C_Write_M, 			// sinal de acesso a  memoria
	output reg hit
	
);
	
	reg [15:0] cache[3:0]; 	//4 blocos com palavras de 16bits
	reg [11:0] mem[4:0]; 	//IMPORTANTE: nao estou conseguindo usar a ramlpm

	wire valido		[3:0];
	wire dirty		[3:0];
	wire [1:0]lru  [3:0];
	wire [6:0]tag  [3:0];
	wire [4:0]bloco[3:0];

	//bloco 0 da cache						 //bloco 2 da cache
	assign  valido[0] = cache[0][15];	 assign  valido[2] = cache[2][15];
	assign  dirty [0] = cache[0][14];	 assign  dirty [2] = cache[2][14];
	assign  lru	  [0] = cache[0][13:12]; assign  lru   [2] = cache[2][13:12];
	assign  tag   [0] = cache[0][11:5];  assign  tag   [2] = cache[2][11:5];
	assign  bloco [0] = cache[0][4:0];	 assign  bloco [2] = cache[2][4:0];

	//bloco 1 da cache						 //bloco 3 da cache
	assign  valido[1] = cache[1][15];	 assign  valido[3] = cache[3][15];
	assign  dirty [1] = cache[1][14];	 assign  dirty [3] = cache[3][14];
	assign  lru	  [1] = cache[1][13:12]; assign  lru   [3] = cache[3][13:12];
	assign  tag   [1] = cache[1][11:5];  assign  tag   [3] = cache[3][11:5];
	assign  bloco [1] = cache[1][4:0];	 assign  bloco [3] = cache[3][4:0];

	reg [1:0]acessado;
	reg reset;


	initial begin

		//([15]validade, [14]dirty, [13:12]lru, [11:5]tag, [4:0]bloco)
		cache[0] <= {1'b1, 1'b0, 2'b00, 7'b1100100, 5'b00101}; //tag = 1100100(100) , valor = 00101(5)
		cache[1] <= {1'b1, 1'b0, 2'b01, 7'b1100110, 5'b00001}; //tag = 1100110(102) , valor = 00001(1)
		cache[2] <= {1'b0, 1'b0, 2'b11, 7'b1101001, 5'b00101}; //tag = 1101001(105) , valor = 00101(5)
		cache[3] <= {1'b1, 1'b0, 2'b10, 7'b1100101, 5'b00011}; //tag = 1100101(101) , valor = 00011(3)
		
		mem[0] <= {7'b1100100, 5'b01010}; //tag = 1100100(100) , valor = 01010(10)
		mem[1] <= {7'b1100110, 5'b01011}; //tag = 1100110(102) , valor = 01011(11)
		mem[2] <= {7'b1101001, 5'b01100}; //tag = 1101001(105) , valor = 01100(12)
		mem[3] <= {7'b1100101, 5'b01101}; //tag = 1100101(101) , valor = 01101(13)
		mem[4] <= {7'b1100111, 5'b01110}; //tag = 1100101(103) , valor = 01101(14)

		hit = 1'b0;
	end

	always@(posedge Clock) begin
		// caso especial de escrita ocorrendo ao mesmo tempo de uma leitura

		//>>>>LEITURA<<<<
		if(Write == 0) begin
			reset = 1'b0;
			if(tag[0] == Tag_Input[6:0]) begin 	//primeiro verificamos se a tag bate
				if (valido[0] == 1'b1) begin		//caso sim, verificamos se o bloco é valido
					hit = 1'b1;							//caso sim, hit
				end
			 acessado = 2'b00;						//caso não, tratamos o bloco invalido
			 reset = 1'b1;	
			end

			else if(tag[1] == Tag_Input[6:0]) begin // realizamos o mesmo processo para bloco[1]
				if (valido[1] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b01;
				reset = 1'b1;
			end

			else if(tag[2] == Tag_Input[6:0]) begin // realizamos o mesmo processo para bloco[2]
				if (valido[2] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b10;
				reset = 1'b1;
			end

			else if(tag[3] == Tag_Input[6:0]) begin // realizamos o mesmo processo para bloco[3]
				if (valido[3] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b11;
				reset = 1'b1;
			end

			else begin //so buscamos o bloco mais antigo quando nao ha nenhum bloco com tag e valido desejado
				if(lru[0] == 2'b11) begin //quem possui lru = 3?
					acessado = 2'b00;
				end
				else if(lru[1] == 2'b11) begin
					acessado = 2'b01;
				end
				else if(lru[2] == 2'b11) begin
					acessado = 2'b10;
				end
				else if(lru[3] == 2'b11) begin
					acessado = 2'b11;
				end

				if(dirty[acessado] == 1) begin 	//se dirty != 0, precisamso fazer write-back
					C_Write_M = 1'b1; 				//solicitacao de escrita da cache na memoria
					C_Block_M = bloco[acessado]; 	//bloco da cache que deve ser escrito na memoria
					cache[acessado][14] = 1'b0;	//atualiza dirty
				end

				reset = 1'b1;
			end

			if(hit == 1'b0) begin 					//busca dado da mem e escreve no bloco
				C_Write_M = 1'b0; 					//leitura da mem
				//Tag_Output = tag[acessado];
				cache[acessado][4:0] = mem[Tag_Input][4:0];//IMPORTANTE : Nao consegui obter o dado da memoria
				cache[acessado][14] = 1'b0; 		//atualiza dirty pra 0
				reset = 1'b1;
			end

			BlockOut = cache[acessado][4:0]; 	// leitura do bloco e saidaa no circuito
			cache[acessado][15] = 1'b1; 			//atualiza valido

			//atualiza lru's
			if (reset == 1'b1) begin
				if(cache[acessado][13:12] == 2'b01) begin //lru = 1 - atualiza o 0
					if(cache[0][13:12] == 2'b00) begin
						cache[0][13:12] = cache[0][13:12] + 1'b1;
					end
					else if(cache[1][13:12] == 2'b00) begin
						cache[1][13:12] = cache[1][13:12] + 1'b1;
					end
					else if(cache[2][13:12] == 2'b00) begin
						cache[2][13:12] = cache[2][13:12] + 1'b1;
					end
					else if(cache[3][13:12] == 2'b00) begin
						cache[3][13:12] = cache[3][13:12] + 1'b1;
					end

				end
				if(cache[acessado][13:12] == 2'b10) begin //lru = 2 - atualiza o 0,1
					if(cache[0][13:12] != 2'b10 && cache[0][13:12] != 2'b11) begin
						cache[0][13:12] = cache[0][13:12] + 1'b1;
					end
					else if(cache[1][13:12] != 2'b10 && cache[1][13:12] != 2'b11) begin
						cache[1][13:12] = cache[1][13:12] + 1'b1;
					end
					else if(cache[2][13:12] != 2'b10 && cache[2][13:12] != 2'b11) begin
						cache[2][13:12] = cache[2][13:12] + 1'b1;
					end
					else if(cache[3][13:12] != 2'b10 && cache[3][13:12] != 2'b11) begin
						cache[3][13:12] = cache[3][13:12] + 1'b1;
					end
					
				end
				if(cache[acessado][13:12] == 2'b11) begin //lru = 3 - atualiza o 0,1,2
					cache[0][13:12] = cache[0][13:12] + 2'b01;
					cache[1][13:12] = cache[1][13:12] + 2'b01;
					cache[2][13:12] = cache[2][13:12] + 2'b01;
					cache[3][13:12] = cache[3][13:12] + 2'b01;
				end
				cache[acessado][13:12] = 2'b00;	//o meu bloco acessado agora é o mais recente
				reset = 1'b0;
			end

		end // end leitura


		//>>>>ESCRITA<<<<
		else begin // Write==1 escrita
			hit = 1'b0;
			if(tag[0] == Tag_Input[6:0]) begin 		//primeiro verificamos se a tag bate
				if (valido[0] == 1'b1) begin			//caso sim, verificamos se o bloco é valido
					hit = 1'b1;								//caso sim, hit
				end
			 acessado = 2'b00;							//caso não, tratamos o bloco invalido
			end

			else if(tag[1] == Tag_Input[6:0]) begin //realizamos o mesmo processo para bloco[1]
				if (valido[1] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b01;
			end

			else if(tag[2] == Tag_Input[6:0]) begin //realizamos o mesmo processo para bloco[2]
				if (valido[2] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b10;
			end

			else if(tag[3] == Tag_Input[6:0]) begin //realizamos o mesmo processo para bloco[3]
				if (valido[3] == 1'b1) begin
					hit = 1'b1;
				end
				acessado = 2'b11;
			end

			else begin // caso nao exista nenhum bloco valido ou existe um bloco valido mas nao tem tag correspondente, faz acesso a memoria
				acessado = lru[0];
				if(dirty[acessado] == 1) begin // Verifica o bit dirty para o caso de ele ser valido. Necessidade de right back.
					C_Write_M = 1'b1; // solicitacao de escrita da cache na memoria
					C_Block_M = bloco[acessado]; // bloco da cache que deve ser escrito na memoria
				end
			end

			cache[acessado][4:0] = BlockIn; //escrevendo na cache
			BlockOut = cache[acessado][4:0];
			cache[acessado][11] = 1'b1; //atualizacao do dirty do acessado (dirty = 1)
			cache[acessado][15] = 1'b1; //atualiza valido

			//atualiza lru's
			if (reset == 1'b1) begin
				if(cache[acessado][13:12] == 2'b01) begin //lru = 1 - atualiza o 0
					if(cache[0][13:12] == 2'b00) begin
						cache[0][13:12] = cache[0][13:12] + 1'b1;
					end
					else if(cache[1][13:12] == 2'b00) begin
						cache[1][13:12] = cache[1][13:12] + 1'b1;
					end
					else if(cache[2][13:12] == 2'b00) begin
						cache[2][13:12] = cache[2][13:12] + 1'b1;
					end
					else if(cache[3][13:12] == 2'b00) begin
						cache[3][13:12] = cache[3][13:12] + 1'b1;
					end

				end
				if(cache[acessado][13:12] == 2'b10) begin //lru = 2 - atualiza o 0,1
					if(cache[0][13:12] != 2'b10 && cache[0][13:12] != 2'b11) begin
						cache[0][13:12] = cache[0][13:12] + 1'b1;
					end
					else if(cache[1][13:12] != 2'b10 && cache[1][13:12] != 2'b11) begin
						cache[1][13:12] = cache[1][13:12] + 1'b1;
					end
					else if(cache[2][13:12] != 2'b10 && cache[2][13:12] != 2'b11) begin
						cache[2][13:12] = cache[2][13:12] + 1'b1;
					end
					else if(cache[3][13:12] != 2'b10 && cache[3][13:12] != 2'b11) begin
						cache[3][13:12] = cache[3][13:12] + 1'b1;
					end
					
				end
				if(cache[acessado][13:12] == 2'b11) begin //lru = 3 - atualiza o 0,1,2
					cache[0][13:12] = cache[0][13:12] + 2'b01;
					cache[1][13:12] = cache[1][13:12] + 2'b01;
					cache[2][13:12] = cache[2][13:12] + 2'b01;
					cache[3][13:12] = cache[3][13:12] + 2'b01;
				end
				cache[acessado][13:12] = 2'b00;	//o meu bloco acessado agora é o mais recente
				reset = 1'b0;
			end

		end // end escrita
	end // end always posedge

	//ramlpm MB1 (Tag_Input, Clock, C_Block_M, C_Write_M, M_Block_C);	

endmodule



module decod7_1(cin, cout); // transformar o binario em hexadecimal

	input [3:0]cin;
	output reg [0:6]cout;

 	always @(cin)
	begin
		case(cin) // abcdefg
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
			10: cout = 	7'b0001000; // A
			11: cout = 	7'b1100000; // B
			12: cout = 	7'b0110001; // C
			13: cout = 	7'b1000010; // D
			14: cout = 	7'b0110000; // E
			15: cout = 	7'b0111000; // F
			default : cout = 0;
		endcase
	end

endmodule // fim transformar o binario em hexadecimal

module parte3 (SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, KEY);

	input  [17:0]SW;
	input  [1:0] KEY;
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [17:0] LEDR;

	wire Clock = KEY[0];
	wire Write = SW[17];
	wire [6:0] Tag_Input = SW[14:10];
	wire [4:0] BlockIn = SW[4:0]; // 0:leitura  1:escrita

	wire [6:0] Tag_Output;
	wire [4:0] BlockOut;
	wire [4:0] C_Block_M;
	wire [4:0] M_Block_C;
	wire C_Write_M;
	wire hit;

	cache_totalmente_associativa C1 
	(	Clock, 
		Write, 
		Tag_Input, 
		BlockIn, 
		M_Block_C, 
		
		Tag_Output, 
		BlockOut, 
		C_Block_M, 
		C_Write_M, 
		hit
);

	ramlpm MB1 
	(	Tag_Output, 
		Clock, 
		C_Block_M,
		C_Write_M, 
		M_Block_C
	);
	
	reg Clock_c;



	wire [4:0] exibir_bloco;

	assign exibir_bloco[0] = (BlockOut[0] & hit) | 1'b0;
	assign exibir_bloco[1] = (BlockOut[1] & hit) | 1'b0;
	assign exibir_bloco[2] = (BlockOut[2] & hit) | 1'b0;
	assign exibir_bloco[3] = (BlockOut[3] & hit) | 1'b0;
	assign exibir_bloco[4] = (BlockOut[4] & hit) | 1'b0;

	decod7_1 d0 (Tag_Input[3:0], HEX0);
	decod7_1 d1 ({3'b0,Tag_Input[4]}, HEX1);
	decod7_1 d2 (exibir_bloco[3:0], HEX6);
	decod7_1 d3 ({3'b0,exibir_bloco[4]}, HEX7);

	assign LEDR[0] = hit;

endmodule
