`include "alu.v"
`include "and.v"
`include "banco_de_registradores.v"
`include "controle.v"
`include "deslocamento2.v"
`include "extensor_sinal.v"
`include "memoria_de_dados.v"
`include "memoria_de_instrucao.v"
`include "monta_instrucao.v"
`include "mux_ALU.v"
`include "mux_desvio.v"
`include "mux_instrucao.v"
`include "mux_memoria_dados.v"
`include "pc.v"
`include "somador_de_desvio.v"
`include "somador_pc.v"
`include "controle_ALU.v"
//`include "div_frequencia.v"
//`include "display.v"

module main(input clock);

	wire RegDst,
		 WriteReg,
		 OrigALU,
		 Branch,
		 Jump,
		 ReadMem,
		 WriteMem,
		 MemtoReg,
		 zero,
		 clk,
		 Exit_AND;
	wire [1:0]Op_ALU;
	wire [3:0]saida_alu_control;
	wire [4:0] Register_rs,
			   Register_rt,
			   Register_rd,
			   Shamt,
			   register_write;
	wire [5:0] Op_code,
			   Funct;
	wire [15:0] Endereco;
	wire [31:0] endereco_pc,
				prox_endereco,
				proximo_endereco,
				endereco32,
				end_deslocado,
				instrucao,
				Valor_Reg1,
				Valor_Reg2,
				Read_data02,
				alu_resultado,
				Exit_DataMem,
				desvio_saida,
				Write_Data,
				NewInput_Pc;

	//div_frequencia div_frequencia(.clk(clock), .clock(clk));

	pc inst_pc (.clk(clock), .endereco_pc (endereco_pc), .prox_endereco(NewInput_Pc));

	somador_pc inst_somador_pc (.endereco_pc(endereco_pc), .clk(clock), .proximo_endereco(proximo_endereco));

	memoria_de_instrucao inst_memoria_de_instrucao(.endereco(endereco_pc), .instrucao(instrucao));

	monta_instrucao inst_monta_instrucao (.instrucao(instrucao), .Op_code(Op_code), .Funct(Funct), .Register_rs(Register_rs), .Register_rt(Register_rt), .Register_rd(Register_rd), .Shamt(Shamt), .Endereco(Endereco));

	Controle Inst_Controle (.Op_code(Op_code), .Op_ALU(Op_ALU), .RegDst(RegDst), .WriteReg(WriteReg), .OrigALU(OrigALU), .Branch(Branch), .ReadMem(ReadMem), .WriteMem(WriteMem), .MemtoReg(MemtoReg));

	extensor inst_extensor(.endereco16(Endereco), .endereco32(endereco32));

	deslocamento inst_deslocamento(.endereco(endereco32), .end_deslocado(end_deslocado));

	mux_instrucao ins_mux_instrucao (.RegDst(RegDst), .register_rt(Register_rt), .register_rd(Register_rd), .register_write(register_write));

	banco_registrador inst_banco_registrador (.RegWrite(WriteReg), .Numero_Reg1(Register_rs), .Numero_Reg2(Register_rt), .Numero_Reg_Escrita(register_write), .Dado_escrita(Write_Data), .clk(clock),  .Valor_Reg1(Valor_Reg1), .Valor_Reg2(Valor_Reg2));

	controle_ALU inst_controle_ALU (.Op_ALU(Op_ALU), .Campo_16_Bits(Endereco), .saida_alu_control(saida_alu_control));

	mux_ALU inst_mux_ALU(.ALUSrc(OrigALU), .register_rd(Valor_Reg2), .endereco_32bits(endereco32), .Read_data02(Read_data02));

	alu inst_alu (.data1(Valor_Reg1), .saida_mux_registrador(Read_data02), .saida_alu_control(saida_alu_control), .zero(zero), .alu_resultado(alu_resultado));

	memoria_de_dados inst_memoria_de_dados (.ReadMem(ReadMem), .WriteMem(WriteMem), .clk(clock), .result_ALU(alu_resultado), .Exit_DataMem(Exit_DataMem));

	mux_memoria_dados inst_mux_memoria_dados (.MemtoReg(MemtoReg), .Exit_DataMem(Exit_DataMem), .ResultadoF_ALU(alu_resultado), .Write_Data(Write_Data));

	somador_de_desvio inst_somador_de_desvio (.endereco_pc(proximo_endereco), .clk(clock), .desvio(end_deslocado), .desvio_saida(desvio_saida));

	mux_and inst_mux_and (.Branch(Branch), .Reg_Zero(zero), .Exit_AND(Exit_AND));

	mux_desvio inst_mux_desvio (.Result_AND(Exit_AND), .Exit_ALU_Pc(proximo_endereco), .Exit_ALU_Desvio(desvio_saida), .NewInput_Pc(NewInput_Pc));

	/*display display(endereco_pc, saida_fpga);

	display2 display2(proximo_endereco, saida_fpga2);
	
	display3 display3(Register_rs, saida_fpga3);
	
	display4 display4(Register_rt, saida_fpga4);*/

endmodule

module Teste_Bench();
	reg clk;
	main mips_main(clk);
	initial begin
		$dumpfile("ondas.vcd");
		$dumpvars;
		clk = 0;
	end

	always #1 clk = ~clk; 

	initial begin
		#26 $finish; 
	end
endmodule
