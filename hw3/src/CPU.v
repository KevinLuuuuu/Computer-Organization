// Please include verilog file if you write module in other file

module CPU(
    input         clk,
    input         rst,
    output reg    instr_read,
    output reg [31:0] instr_addr,
    input  [31:0] instr_out,
    output reg    data_read,
    output reg [3:0]  data_write,
    output reg [31:0] data_addr,
    output reg [31:0] data_in,
    input  [31:0] data_out
);

reg [4:0] rs1,rs2,rd;
reg [19:0] Utype_imm;
reg [11:0] Itype_imm;
reg [6:0] Btype_imm1,Stype_imm1;
reg [4:0] Btype_imm2,Stype_imm2;
reg [2:0] funct3;
reg [2:0] cc = 3'd0;
reg [6:0] funct7;
reg [6:0] opcode;
reg [31:0] pc = 32'd0;
reg [31:0] registers [31:0];

always@(posedge clk or posedge rst)
begin
	if(!rst)begin
	case(cc)
		3'd0:begin
			instr_read <= 1'd1;
			instr_addr <= pc;
			registers[0] <= 32'd0;
			cc <= 3'd1;
		end
		3'd1:begin
			cc <= 3'd2;//read instr
		end
		3'd2:begin
			pc <= pc+32'd4;
			instr_read <= 1'd0;
			opcode = instr_out[6:0];
			case(opcode)
				7'b0100011:begin //S-type
					Stype_imm1 <= instr_out[31:25];
					rs2 <= instr_out[24:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					Stype_imm2 <= instr_out[11:7];
				end
				7'b0000011:begin //fllowing three are I-type
					Itype_imm <= instr_out[31:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					rd <= instr_out[11:7];
					data_read <= 1'b1;
				end
				7'b0010011:begin
					Itype_imm <= instr_out[31:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					rd <= instr_out[11:7];
				end
				7'b1100111:begin 
					Itype_imm <= instr_out[31:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					rd <= instr_out[11:7];
				end
				7'b0110011:begin //R-type
					funct7 <= instr_out[31:25];
					rs2 <= instr_out[24:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					rd <= instr_out[11:7];
				end
				7'b1100011:begin //B-type
					Btype_imm1 <= instr_out[31:25];
					rs2 <= instr_out[24:20];
					rs1 <= instr_out[19:15];
					funct3 <= instr_out[14:12];
					Btype_imm2 <= instr_out[11:7];
				end
				7'b0010111:begin //fllowing two are U-type
					Utype_imm <= instr_out[31:12];
					rd <= instr_out[11:7];
				end
				7'b0110111:begin
					Utype_imm <= instr_out[31:12];
					rd <= instr_out[11:7];
				end
				7'b1101111:begin //J-type
					Utype_imm <= instr_out[31:12];
					rd <= instr_out[11:7];
				end
			endcase
			cc <= 3'd3;
		end
		3'd3:begin
			case(opcode)
				7'b0100011:begin// S-type
					data_addr = registers[rs1] + {{20{Stype_imm1[6]}},Stype_imm1,Stype_imm2};
					case(funct3)
						3'b010:begin
							data_write =4'b1111;							
							data_in = registers[rs2];
						end
						3'b000:begin
							case(data_addr[1:0])
								2'b00:begin
									data_write<=4'b0001;
									data_in[7:0]=registers[rs2][7:0];
								end
								2'b01:begin
									data_write<=4'b0010;
									data_in[15:8]=registers[rs2][7:0];
								end
								2'b10:begin
									data_write<=4'b0100;
									data_in[23:16]=registers[rs2][7:0];
								end
								2'b11:begin
									data_write<=4'b1000;
									data_in[31:24]=registers[rs2][7:0];
								end
							endcase
						end
						3'b001:begin
							case(data_addr[1:0])
								2'b00:begin
									data_write<=4'b0011;
									data_in[15:0]=registers[rs2][15:0];
								end
								2'b01:begin
									data_write<=4'b0011;
									data_in[15:0]=registers[rs2][15:0];
								end
								2'b10:begin
									data_write<=4'b1100;
									data_in[31:16]=registers[rs2][15:0];
								end
								2'b11:begin
									data_write<=4'b1100;
									data_in[31:16]=registers[rs2][15:0];
								end
							endcase
						end
					endcase
				end
				7'b0000011:begin//fllowing three are I-type
					data_addr<=registers[rs1] + {{20{Itype_imm[11]}},Itype_imm};		
				end
				7'b0010011:begin
					case(funct3)
						3'b000:begin
							registers[rd]<= registers[rs1] + {{20{Itype_imm[11]}},Itype_imm};
						end
						3'b001:begin
							registers[rd]<= registers[rs1]<<Itype_imm[4:0];
						end
						3'b010:begin
							registers[rd]<= ($signed(registers[rs1])<$signed({{20{Itype_imm[11]}},Itype_imm}))? 32'h1:32'h0;
						end
						3'b011:begin
							registers[rd]<= (registers[rs1]<{{20{Itype_imm[11]}},Itype_imm})? 32'h1:32'h0;
						end
						3'b100:begin
							registers[rd]<= registers[rs1]^{{20{Itype_imm[11]}},Itype_imm};
						end
						3'b101:begin
							if(Itype_imm[11:5]==7'd0)begin
								registers[rd]<= registers[rs1] >> Itype_imm[4:0];
							end
							else if(Itype_imm[11:5]==7'b0100000)begin
								registers[rd]<= $signed(registers[rs1]) >>> Itype_imm[4:0];//signed use >>>
							end
						end
						3'b110:begin
							registers[rd] <= registers[rs1]|{{20{Itype_imm[11]}},Itype_imm};
						end
						3'b111:begin
							registers[rd] <= registers[rs1]&{{20{Itype_imm[11]}},Itype_imm};
						end
					endcase
				end
				7'b1100111:begin
					registers[rd]<=pc;
					pc<= registers[rs1] + {{20{Itype_imm[11]}},Itype_imm};
				end
				7'b0110011:begin// R-type
					case(funct3)
						3'b000:begin
							if(funct7==7'b0000000)begin
								registers[rd]<= registers[rs1]+registers[rs2];
							end
							else if(funct7==7'b0100000)begin
								registers[rd]<= registers[rs1]-registers[rs2];
							end
						end
						3'b001:begin
							registers[rd]<= registers[rs1] << registers[rs2][4:0];
						end
						3'b010:begin
							registers[rd]<= ($signed(registers[rs1]) < $signed(registers[rs2]))?32'h1:32'h0;
						end
						3'b011:begin
							registers[rd]<= (registers[rs1] < registers[rs2])?32'h1:32'h0;
						end
						3'b100:begin
							registers[rd]<= registers[rs1] ^ registers[rs2];
						end
						3'b101:begin
							if(funct7==7'b0000000)begin
								registers[rd] <= registers[rs1] >> registers[rs2][4:0];
							end
							else if(funct7==7'b0100000)begin
								registers[rd] <= $signed(registers[rs1]) >>> registers[rs2][4:0];//signed use >>>
							end
						end
						3'b110:begin
							registers[rd] <= registers[rs1] | registers[rs2];
						end
						3'b111:begin
							registers[rd] <= registers[rs1] & registers[rs2];
						end
					endcase
				end
				7'b1100011:begin// B-type
					case(funct3)
						3'b000:begin
							pc =(registers[rs1]==registers[rs2])?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
						3'b001:begin
							pc =(registers[rs1]!=registers[rs2])?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
						3'b100:begin
							pc =($signed(registers[rs1])<$signed(registers[rs2]))?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
						3'b101:begin
							pc =($signed(registers[rs1])>=$signed(registers[rs2]))?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
						3'b110:begin
							pc =(registers[rs1]<registers[rs2])?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
						3'b111:begin
							pc =(registers[rs1]>=registers[rs2])?
							pc +{{19{Btype_imm1[6]}},Btype_imm1[6],Btype_imm2[0],Btype_imm1[5:0],Btype_imm2[4:1],1'd0}-32'd4:pc;
						end
					endcase
				end
				7'b0010111:begin //fllowing two are U-type
					registers[rd] <= pc+{Utype_imm,12'd0}-32'd4;
				end
				7'b0110111:begin
					registers[rd] <= {Utype_imm,12'd0};
				end
				7'b1101111:begin //J-type
					registers[rd] <= pc;
					pc <= pc + {{11{Utype_imm[19]}},Utype_imm[19],Utype_imm[7:0],Utype_imm[8],Utype_imm[18:9],1'd0}-32'd4;
				end
			endcase
			cc <= 3'd4;
		end
		3'd4:begin
			cc <= 3'd5; //wait for data_out
		end		
		3'd5:begin
			case(opcode)
				7'b0100011:begin
					data_write <= 4'b0000;
				end
				7'b0000011:begin
					data_read <= 1'b0;
					case(funct3)
						3'b000:begin
							registers[rd] = {{24{data_out[7]}},data_out[7:0]};//LB
						end
						3'b001:begin
							registers[rd] = {{16{data_out[15]}},data_out[15:0]};//LH
						end
						3'b010:begin
							registers[rd] = data_out;//LW
						end
						3'b100:begin
							registers[rd] = {{24{1'b0}},data_out[7:0]};//sign extended//LBU
						end
						3'b101:begin
							registers[rd] = {{16{1'b0}},data_out[15:0]};//LHU
						end
					endcase
				end
			endcase
			cc <= 3'd0;
		end
	endcase
	end
end

endmodule




