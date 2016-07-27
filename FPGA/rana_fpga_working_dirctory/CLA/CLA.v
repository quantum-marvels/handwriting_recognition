`timescale 1ns / 1ps
module CLA(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output Carry,
	 output PG, GG,
    input Cin
    );
wire [7:0] G, P, C ;
assign G = A & B;  //Generate 
assign P = A ^ B;	 //Propogate	
assign S = P ^ C;  // Sum
assign C[0] = Cin;
assign C[1] = G[0] | (P[0] & C[0]);
assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
assign C[3] = G[2] | (P[2] & G[1] ) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
assign C[4] = G[3] | (P[3] & G[2] ) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);
assign C[5] = G[4] | (P[4] & G[3] ) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & G[0]) | (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
assign C[6] = G[5] | (P[5] & G[4] ) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2]) | (P[5] & P[4] & P[3] & P[2] & G[1]) | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]) ;
assign C[7] = G[6] | (P[6] & G[5] ) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3]) | (P[6] & P[5] & P[4] & P[3] & G[2]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]) ; 
assign Carry = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]) | (P[7] & P[6] & P[5] & P[4] & G[3]) | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
assign PG = P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0];		
assign GG = G[7] | (P[7] & G[7]) | (P[7] & P[6] & G[6]) | (P[7] & P[6] & P[5] & G[5]) | (P[7] & P[6] & P[5] & P[4] & G[4]) | (P[7] & P[6] & P[5] & P[4] & P[3] & G[3]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[2]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & G[0] ) ; 
endmodule