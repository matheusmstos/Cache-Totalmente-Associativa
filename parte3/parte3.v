module cache_totalmente_associativa (	
	input[4:0] Address, 
	input clock,
	input Write,	
	input[4:0] BlockIn, // dado que esta indo do circuito para a cache
	input[4:0] M_Block_C, // dado que esta indo da memoria para a cache
	
	output reg[4:0] BlockOut, // o bloco da cache que está sendo enviado para o circuito
	output reg C_Write_M, // sinal de acesso à memoria
	output reg[4:0] C_Block_M, // o bloco da cache que está sendo enviado para a memoria
	output reg hit
	);

	wire index = Address[4];
	
	reg [15:0] cache[3:0]; //4 blocos com palavras de 16bits

	wire valido;
	wire dirty;
	wire lru   [1:0];
	wire tag   [6:0];
	wire bloco [3:0];
	/*
		Cache:
			Valido Dirty LRU#1 LRU#2 TAG Dado
			  x      x     x     x 
	*/
	
	assign  valido = cache[index][15];
	assign  dirty  = cache[index][14];
	assign  lru    = cache[index][13:12];
	assign  tag    = cache[index][11:5];
	assign  bloco  = cache[index][4:0];

	reg acessado,caso_especial;

	initial begin
		//INICIALIZAÇÃO DOS CONJUNTOS
		
		//([15]validade, [14]dirty, [13:12]lru, [11:5]tag, [4:0]bloco)
		cache[0] = 12'b{1 0 00 1100100 00101}; //tag = 1100100(100) , valor = 00101(5)
		cache[1] = 12'b{1 0 01 1100110 00001}; //tag = 1100110(102) , valor = 00001(1)
		cache[2] = 12'b{0 0 11 1101001 00101}; //tag = 1101001(105) , valor = 00101(5)
		cache[3] = 12'b{1 0 10 1100101 00011}; //tag = 1100101(101) , valor = 00011(3)
		
		//cache[index]
		caso_especial = 1'b0;
		
		hit = 1'b0;
	end

	always@(posedge clock) begin
		if(caso_especial) begin // caso especial de escrita ocorrendo ao mesmo tempo de uma leitura
			cache[index][acessado][4:0] = M_Block_C;	
			cache[index][acessado][11] = 1'b1;
			caso_especial = 1'b0;
		end // fim caso especial
		
		
		//>>>>LEITURA<<<<
		if(Write == 0) begin 
			if(tag[0] == Address[3:0] && valido[0] == 1) begin // caso exista uma tag valida
				acessado = 1'b0; 
				hit = 1'b1;
			end 
		
			else if(tag[1] == Address[3:0] && valido[1] == 1) begin // caso nao exista a primeira tag, verifica a seguinte
				acessado = 1'b1; 
				hit = 1'b1;
			end
			
			else begin // caso nao exista nenhum bloco valido ou existe um bloco valido mas nao tem tag correspondente, faz acesso a memoria
				acessado = lru[0];
				if(dirty[acessado] == 1) begin // verifica o bit dirty para o caso de ele ser valido
					C_Write_M = 1'b1; // solicitacao de escrita da cache na memoria
					C_Block_M = bloco[acessado]; // bloco da cache que deve ser escrito na memoria
					caso_especial = 1'b1; // CASO ESPECIAL: quando le bloco dirty, é necessario tanto ler quanto escrever algo na memoria
				end			
			end
			
			BlockOut = cache[index][acessado][4:0]; // leitura do bloco e saída no circuito
			cache[index][acessado][10] = 1'b1; // atualizacao do lru acessado: vai para o mais novo
			cache[index][~acessado][10] = 1'b0; // atualizacao do lru nao acessado: vai pro mais antigo
		end // end leitura
		
		
		//>>>>ESCRITA<<<<
		else begin // Write==1 escrita 
			if(tag[0] == Address[3:0] && valido[0] == 1) begin // caso a tag confira
				acessado = 1'b0; 
				hit = 1'b1;	
			end
			
			else if(tag[1] == Address[3:0] && valido[1] == 1) begin // caso nao confira a primeira tag, verifica a seguinte
				acessado = 1'b1; 
				hit = 1'b1;
			end
			
			else begin // caso nao exista nenhum bloco valido ou existe um bloco valido mas nao tem tag correspondente, faz acesso a memoria
				acessado = lru[0];
				if(dirty[acessado] == 1) begin // Verifica o bit dirty para o caso de ele ser valido. Necessidade de right back. 
					C_Write_M = 1'b1; // solicitacao de escrita da cache na memoria
					C_Block_M = bloco[acessado]; // bloco da cache que deve ser escrito na memoria
				end
			end	
			
			cache[index][acessado][4:0] = BlockIn; //escrevendo na cache
			cache[index][acessado][11] = 1'b1; // atualizacao do dirty do acessado (dirty = 1)
			cache[index][acessado][10] = 1'b1; // atualizacao da lru: vai para o mais novo
			cache[index][~acessado][10] = 1'b0; // atualizacao da lru: vai para o mais antigo
		end // end escrita
	end // end always posedge

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

module parte_1 (SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, KEY);

	input  [17:0]SW;
	input  [1:0] KEY;
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [17:0] LEDR;

	wire clock_m = KEY[0];
	wire Write = SW[17];
	wire [4:0] Address = SW[14:10];
	wire [4:0] BlockIn = SW[4:0]; // 0:leitura  1:escrita

	wire [4:0] BlockOut;
	wire [4:0] C_Block_M;
	wire [4:0] M_Block_C;
	wire C_Write_M;
	wire hit;

	reg clock_c;

	cache_ass2vias C1 (Address, clock_c, Write, BlockIn, M_Block_C, BlockOut, C_Write_M, C_Block_M, hit);

	ramlpm m1 (Address, C_Block_M, clock_m, C_Write_M , M_Block_C);

	wire [4:0] exibir_bloco;

	assign exibir_bloco[0] = (BlockOut[0] & hit) | 1'b0;
	assign exibir_bloco[1] = (BlockOut[1] & hit) | 1'b0;
	assign exibir_bloco[2] = (BlockOut[2] & hit) | 1'b0;
	assign exibir_bloco[3] = (BlockOut[3] & hit) | 1'b0;
	assign exibir_bloco[4] = (BlockOut[4] & hit) | 1'b0;       

	decod7_1 d0 (Address[3:0], HEX0);
	decod7_1 d1 ({3'b0,Address[4]}, HEX1);
	decod7_1 d2 (exibir_bloco[3:0], HEX6);
	decod7_1 d3 ({3'b0,exibir_bloco[4]}, HEX7);

	assign LEDR[0] = hit;

	always@(posedge clock_m) begin
		clock_c = ~clock_c;
	end

endmodule
