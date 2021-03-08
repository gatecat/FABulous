module DSP_bot (N1BEG, N2BEG, N2BEGb, N4BEG, bot2top, N1END, N2MID, N2END, N4END, E1BEG, E2BEG, E2BEGb, E6BEG, E1END, E2MID, E2END, E6END, S1BEG, S2BEG, S2BEGb, S4BEG, S1END, S2MID, S2END, S4END, top2bot, W1BEG, W2BEG, W2BEGb, W6BEG, W1END, W2MID, W2END, W6END, UserCLK, FrameData, FrameStrobe);
	parameter MaxFramesPerCol = 20;
	parameter FrameBitsPerRow = 32;
	parameter NoConfigBits = 368;
	//  NORTH
	output [3:0] N1BEG; //wires:4 X_offset:0 Y_offset:1  source_name:N1BEG destination_name:N1END  
	output [7:0] N2BEG; //wires:8 X_offset:0 Y_offset:1  source_name:N2BEG destination_name:N2MID  
	output [7:0] N2BEGb; //wires:8 X_offset:0 Y_offset:1  source_name:N2BEGb destination_name:N2END  
	output [15:0] N4BEG; //wires:4 X_offset:0 Y_offset:4  source_name:N4BEG destination_name:N4END  
	output [9:0] bot2top; //wires:10 X_offset:0 Y_offset:1  source_name:bot2top destination_name:NULL  
	input [3:0] N1END; //wires:4 X_offset:0 Y_offset:1  source_name:N1BEG destination_name:N1END  
	input [7:0] N2MID; //wires:8 X_offset:0 Y_offset:1  source_name:N2BEG destination_name:N2MID  
	input [7:0] N2END; //wires:8 X_offset:0 Y_offset:1  source_name:N2BEGb destination_name:N2END  
	input [15:0] N4END; //wires:4 X_offset:0 Y_offset:4  source_name:N4BEG destination_name:N4END  
	//  EAST
	output [3:0] E1BEG; //wires:4 X_offset:1 Y_offset:0  source_name:E1BEG destination_name:E1END  
	output [7:0] E2BEG; //wires:8 X_offset:1 Y_offset:0  source_name:E2BEG destination_name:E2MID  
	output [7:0] E2BEGb; //wires:8 X_offset:1 Y_offset:0  source_name:E2BEGb destination_name:E2END  
	output [11:0] E6BEG; //wires:2 X_offset:6 Y_offset:0  source_name:E6BEG destination_name:E6END  
	input [3:0] E1END; //wires:4 X_offset:1 Y_offset:0  source_name:E1BEG destination_name:E1END  
	input [7:0] E2MID; //wires:8 X_offset:1 Y_offset:0  source_name:E2BEG destination_name:E2MID  
	input [7:0] E2END; //wires:8 X_offset:1 Y_offset:0  source_name:E2BEGb destination_name:E2END  
	input [11:0] E6END; //wires:2 X_offset:6 Y_offset:0  source_name:E6BEG destination_name:E6END  
	//  SOUTH
	output [3:0] S1BEG; //wires:4 X_offset:0 Y_offset:-1  source_name:S1BEG destination_name:S1END  
	output [7:0] S2BEG; //wires:8 X_offset:0 Y_offset:-1  source_name:S2BEG destination_name:S2MID  
	output [7:0] S2BEGb; //wires:8 X_offset:0 Y_offset:-1  source_name:S2BEGb destination_name:S2END  
	output [15:0] S4BEG; //wires:4 X_offset:0 Y_offset:-4  source_name:S4BEG destination_name:S4END  
	input [3:0] S1END; //wires:4 X_offset:0 Y_offset:-1  source_name:S1BEG destination_name:S1END  
	input [7:0] S2MID; //wires:8 X_offset:0 Y_offset:-1  source_name:S2BEG destination_name:S2MID  
	input [7:0] S2END; //wires:8 X_offset:0 Y_offset:-1  source_name:S2BEGb destination_name:S2END  
	input [15:0] S4END; //wires:4 X_offset:0 Y_offset:-4  source_name:S4BEG destination_name:S4END  
	input [17:0] top2bot; //wires:18 X_offset:0 Y_offset:-1  source_name:NULL destination_name:top2bot  
	//  WEST
	output [3:0] W1BEG; //wires:4 X_offset:-1 Y_offset:0  source_name:W1BEG destination_name:W1END  
	output [7:0] W2BEG; //wires:8 X_offset:-1 Y_offset:0  source_name:W2BEG destination_name:W2MID  
	output [7:0] W2BEGb; //wires:8 X_offset:-1 Y_offset:0  source_name:W2BEGb destination_name:W2END  
	output [11:0] W6BEG; //wires:2 X_offset:-6 Y_offset:0  source_name:W6BEG destination_name:W6END  
	input [3:0] W1END; //wires:4 X_offset:-1 Y_offset:0  source_name:W1BEG destination_name:W1END  
	input [7:0] W2MID; //wires:8 X_offset:-1 Y_offset:0  source_name:W2BEG destination_name:W2MID  
	input [7:0] W2END; //wires:8 X_offset:-1 Y_offset:0  source_name:W2BEGb destination_name:W2END  
	input [11:0] W6END; //wires:2 X_offset:-6 Y_offset:0  source_name:W6BEG destination_name:W6END  
	// Tile IO ports from BELs
	input UserCLK;
	input [FrameBitsPerRow-1:0] FrameData; //CONFIG_PORT this is a keyword needed to connect the tile to the bitstream frame register
	input [MaxFramesPerCol-1:0] FrameStrobe; //CONFIG_PORT this is a keyword needed to connect the tile to the bitstream frame register 
	//global


//signal declarations
//BEL ports (e.g., slices)
	wire A7;
	wire A6;
	wire A5;
	wire A4;
	wire A3;
	wire A2;
	wire A1;
	wire A0;
	wire B7;
	wire B6;
	wire B5;
	wire B4;
	wire B3;
	wire B2;
	wire B1;
	wire B0;
	wire C19;
	wire C18;
	wire C17;
	wire C16;
	wire C15;
	wire C14;
	wire C13;
	wire C12;
	wire C11;
	wire C10;
	wire C9;
	wire C8;
	wire C7;
	wire C6;
	wire C5;
	wire C4;
	wire C3;
	wire C2;
	wire C1;
	wire C0;
	wire clr;
	wire Q19;
	wire Q18;
	wire Q17;
	wire Q16;
	wire Q15;
	wire Q14;
	wire Q13;
	wire Q12;
	wire Q11;
	wire Q10;
	wire Q9;
	wire Q8;
	wire Q7;
	wire Q6;
	wire Q5;
	wire Q4;
	wire Q3;
	wire Q2;
	wire Q1;
	wire Q0;
//jump wires
	wire [4-1:0] J2MID_ABa_BEG;
	wire [4-1:0] J2MID_CDa_BEG;
	wire [4-1:0] J2MID_EFa_BEG;
	wire [4-1:0] J2MID_GHa_BEG;
	wire [4-1:0] J2MID_ABb_BEG;
	wire [4-1:0] J2MID_CDb_BEG;
	wire [4-1:0] J2MID_EFb_BEG;
	wire [4-1:0] J2MID_GHb_BEG;
	wire [4-1:0] J2END_AB_BEG;
	wire [4-1:0] J2END_CD_BEG;
	wire [4-1:0] J2END_EF_BEG;
	wire [4-1:0] J2END_GH_BEG;
	wire [8-1:0] JN2BEG;
	wire [8-1:0] JE2BEG;
	wire [8-1:0] JS2BEG;
	wire [8-1:0] JW2BEG;
	wire [4-1:0] J_l_AB_BEG;
	wire [4-1:0] J_l_CD_BEG;
	wire [4-1:0] J_l_EF_BEG;
	wire [4-1:0] J_l_GH_BEG;
//internal configuration data signal to daisy-chain all BELs (if any and in the order they are listed in the fabric.csv)
	wire [NoConfigBits-1:0] ConfigBits;

// Cascading of routing for wires spanning more than one tile
	assign N4BEG[15-4:0] = N4END[15:4];
	assign E6BEG[11-2:0] = E6END[11:2];
	assign S4BEG[15-4:0] = S4END[15:4];
	assign W6BEG[11-2:0] = W6END[11:2];

// configuration storage latches
	DSP_bot_ConfigMem Inst_DSP_bot_ConfigMem (
	.FrameData(FrameData),
	.FrameStrobe(FrameStrobe),
	.ConfigBits(ConfigBits)
	);

//BEL component instantiations
	MULADD Inst_MULADD (
	.A7(A7),
	.A6(A6),
	.A5(A5),
	.A4(A4),
	.A3(A3),
	.A2(A2),
	.A1(A1),
	.A0(A0),
	.B7(B7),
	.B6(B6),
	.B5(B5),
	.B4(B4),
	.B3(B3),
	.B2(B2),
	.B1(B1),
	.B0(B0),
	.C19(C19),
	.C18(C18),
	.C17(C17),
	.C16(C16),
	.C15(C15),
	.C14(C14),
	.C13(C13),
	.C12(C12),
	.C11(C11),
	.C10(C10),
	.C9(C9),
	.C8(C8),
	.C7(C7),
	.C6(C6),
	.C5(C5),
	.C4(C4),
	.C3(C3),
	.C2(C2),
	.C1(C1),
	.C0(C0),
	.clr(clr),
	.Q19(Q19),
	.Q18(Q18),
	.Q17(Q17),
	.Q16(Q16),
	.Q15(Q15),
	.Q14(Q14),
	.Q13(Q13),
	.Q12(Q12),
	.Q11(Q11),
	.Q10(Q10),
	.Q9(Q9),
	.Q8(Q8),
	.Q7(Q7),
	.Q6(Q6),
	.Q5(Q5),
	.Q4(Q4),
	.Q3(Q3),
	.Q2(Q2),
	.Q1(Q1),
	.Q0(Q0),
	//I/O primitive pins go to tile top level module (not further parsed)  
	.UserCLK(UserCLK),
	.ConfigBits(ConfigBits[6-1:0])
	);


//switch matrix component instantiation
	DSP_bot_switch_matrix Inst_DSP_bot_switch_matrix (
	.N1END0(N1END[0]),
	.N1END1(N1END[1]),
	.N1END2(N1END[2]),
	.N1END3(N1END[3]),
	.N2MID0(N2MID[0]),
	.N2MID1(N2MID[1]),
	.N2MID2(N2MID[2]),
	.N2MID3(N2MID[3]),
	.N2MID4(N2MID[4]),
	.N2MID5(N2MID[5]),
	.N2MID6(N2MID[6]),
	.N2MID7(N2MID[7]),
	.N2END0(N2END[0]),
	.N2END1(N2END[1]),
	.N2END2(N2END[2]),
	.N2END3(N2END[3]),
	.N2END4(N2END[4]),
	.N2END5(N2END[5]),
	.N2END6(N2END[6]),
	.N2END7(N2END[7]),
	.N4END0(N4END[0]),
	.N4END1(N4END[1]),
	.N4END2(N4END[2]),
	.N4END3(N4END[3]),
	.E1END0(E1END[0]),
	.E1END1(E1END[1]),
	.E1END2(E1END[2]),
	.E1END3(E1END[3]),
	.E2MID0(E2MID[0]),
	.E2MID1(E2MID[1]),
	.E2MID2(E2MID[2]),
	.E2MID3(E2MID[3]),
	.E2MID4(E2MID[4]),
	.E2MID5(E2MID[5]),
	.E2MID6(E2MID[6]),
	.E2MID7(E2MID[7]),
	.E2END0(E2END[0]),
	.E2END1(E2END[1]),
	.E2END2(E2END[2]),
	.E2END3(E2END[3]),
	.E2END4(E2END[4]),
	.E2END5(E2END[5]),
	.E2END6(E2END[6]),
	.E2END7(E2END[7]),
	.E6END0(E6END[0]),
	.E6END1(E6END[1]),
	.S1END0(S1END[0]),
	.S1END1(S1END[1]),
	.S1END2(S1END[2]),
	.S1END3(S1END[3]),
	.S2MID0(S2MID[0]),
	.S2MID1(S2MID[1]),
	.S2MID2(S2MID[2]),
	.S2MID3(S2MID[3]),
	.S2MID4(S2MID[4]),
	.S2MID5(S2MID[5]),
	.S2MID6(S2MID[6]),
	.S2MID7(S2MID[7]),
	.S2END0(S2END[0]),
	.S2END1(S2END[1]),
	.S2END2(S2END[2]),
	.S2END3(S2END[3]),
	.S2END4(S2END[4]),
	.S2END5(S2END[5]),
	.S2END6(S2END[6]),
	.S2END7(S2END[7]),
	.S4END0(S4END[0]),
	.S4END1(S4END[1]),
	.S4END2(S4END[2]),
	.S4END3(S4END[3]),
	.top2bot0(top2bot[0]),
	.top2bot1(top2bot[1]),
	.top2bot2(top2bot[2]),
	.top2bot3(top2bot[3]),
	.top2bot4(top2bot[4]),
	.top2bot5(top2bot[5]),
	.top2bot6(top2bot[6]),
	.top2bot7(top2bot[7]),
	.top2bot8(top2bot[8]),
	.top2bot9(top2bot[9]),
	.top2bot10(top2bot[10]),
	.top2bot11(top2bot[11]),
	.top2bot12(top2bot[12]),
	.top2bot13(top2bot[13]),
	.top2bot14(top2bot[14]),
	.top2bot15(top2bot[15]),
	.top2bot16(top2bot[16]),
	.top2bot17(top2bot[17]),
	.W1END0(W1END[0]),
	.W1END1(W1END[1]),
	.W1END2(W1END[2]),
	.W1END3(W1END[3]),
	.W2MID0(W2MID[0]),
	.W2MID1(W2MID[1]),
	.W2MID2(W2MID[2]),
	.W2MID3(W2MID[3]),
	.W2MID4(W2MID[4]),
	.W2MID5(W2MID[5]),
	.W2MID6(W2MID[6]),
	.W2MID7(W2MID[7]),
	.W2END0(W2END[0]),
	.W2END1(W2END[1]),
	.W2END2(W2END[2]),
	.W2END3(W2END[3]),
	.W2END4(W2END[4]),
	.W2END5(W2END[5]),
	.W2END6(W2END[6]),
	.W2END7(W2END[7]),
	.W6END0(W6END[0]),
	.W6END1(W6END[1]),
	.Q19(Q19),
	.Q18(Q18),
	.Q17(Q17),
	.Q16(Q16),
	.Q15(Q15),
	.Q14(Q14),
	.Q13(Q13),
	.Q12(Q12),
	.Q11(Q11),
	.Q10(Q10),
	.Q9(Q9),
	.Q8(Q8),
	.Q7(Q7),
	.Q6(Q6),
	.Q5(Q5),
	.Q4(Q4),
	.Q3(Q3),
	.Q2(Q2),
	.Q1(Q1),
	.Q0(Q0),
	.J2MID_ABa_END0(J2MID_ABa_BEG[0]),
	.J2MID_ABa_END1(J2MID_ABa_BEG[1]),
	.J2MID_ABa_END2(J2MID_ABa_BEG[2]),
	.J2MID_ABa_END3(J2MID_ABa_BEG[3]),
	.J2MID_CDa_END0(J2MID_CDa_BEG[0]),
	.J2MID_CDa_END1(J2MID_CDa_BEG[1]),
	.J2MID_CDa_END2(J2MID_CDa_BEG[2]),
	.J2MID_CDa_END3(J2MID_CDa_BEG[3]),
	.J2MID_EFa_END0(J2MID_EFa_BEG[0]),
	.J2MID_EFa_END1(J2MID_EFa_BEG[1]),
	.J2MID_EFa_END2(J2MID_EFa_BEG[2]),
	.J2MID_EFa_END3(J2MID_EFa_BEG[3]),
	.J2MID_GHa_END0(J2MID_GHa_BEG[0]),
	.J2MID_GHa_END1(J2MID_GHa_BEG[1]),
	.J2MID_GHa_END2(J2MID_GHa_BEG[2]),
	.J2MID_GHa_END3(J2MID_GHa_BEG[3]),
	.J2MID_ABb_END0(J2MID_ABb_BEG[0]),
	.J2MID_ABb_END1(J2MID_ABb_BEG[1]),
	.J2MID_ABb_END2(J2MID_ABb_BEG[2]),
	.J2MID_ABb_END3(J2MID_ABb_BEG[3]),
	.J2MID_CDb_END0(J2MID_CDb_BEG[0]),
	.J2MID_CDb_END1(J2MID_CDb_BEG[1]),
	.J2MID_CDb_END2(J2MID_CDb_BEG[2]),
	.J2MID_CDb_END3(J2MID_CDb_BEG[3]),
	.J2MID_EFb_END0(J2MID_EFb_BEG[0]),
	.J2MID_EFb_END1(J2MID_EFb_BEG[1]),
	.J2MID_EFb_END2(J2MID_EFb_BEG[2]),
	.J2MID_EFb_END3(J2MID_EFb_BEG[3]),
	.J2MID_GHb_END0(J2MID_GHb_BEG[0]),
	.J2MID_GHb_END1(J2MID_GHb_BEG[1]),
	.J2MID_GHb_END2(J2MID_GHb_BEG[2]),
	.J2MID_GHb_END3(J2MID_GHb_BEG[3]),
	.J2END_AB_END0(J2END_AB_BEG[0]),
	.J2END_AB_END1(J2END_AB_BEG[1]),
	.J2END_AB_END2(J2END_AB_BEG[2]),
	.J2END_AB_END3(J2END_AB_BEG[3]),
	.J2END_CD_END0(J2END_CD_BEG[0]),
	.J2END_CD_END1(J2END_CD_BEG[1]),
	.J2END_CD_END2(J2END_CD_BEG[2]),
	.J2END_CD_END3(J2END_CD_BEG[3]),
	.J2END_EF_END0(J2END_EF_BEG[0]),
	.J2END_EF_END1(J2END_EF_BEG[1]),
	.J2END_EF_END2(J2END_EF_BEG[2]),
	.J2END_EF_END3(J2END_EF_BEG[3]),
	.J2END_GH_END0(J2END_GH_BEG[0]),
	.J2END_GH_END1(J2END_GH_BEG[1]),
	.J2END_GH_END2(J2END_GH_BEG[2]),
	.J2END_GH_END3(J2END_GH_BEG[3]),
	.JN2END0(JN2BEG[0]),
	.JN2END1(JN2BEG[1]),
	.JN2END2(JN2BEG[2]),
	.JN2END3(JN2BEG[3]),
	.JN2END4(JN2BEG[4]),
	.JN2END5(JN2BEG[5]),
	.JN2END6(JN2BEG[6]),
	.JN2END7(JN2BEG[7]),
	.JE2END0(JE2BEG[0]),
	.JE2END1(JE2BEG[1]),
	.JE2END2(JE2BEG[2]),
	.JE2END3(JE2BEG[3]),
	.JE2END4(JE2BEG[4]),
	.JE2END5(JE2BEG[5]),
	.JE2END6(JE2BEG[6]),
	.JE2END7(JE2BEG[7]),
	.JS2END0(JS2BEG[0]),
	.JS2END1(JS2BEG[1]),
	.JS2END2(JS2BEG[2]),
	.JS2END3(JS2BEG[3]),
	.JS2END4(JS2BEG[4]),
	.JS2END5(JS2BEG[5]),
	.JS2END6(JS2BEG[6]),
	.JS2END7(JS2BEG[7]),
	.JW2END0(JW2BEG[0]),
	.JW2END1(JW2BEG[1]),
	.JW2END2(JW2BEG[2]),
	.JW2END3(JW2BEG[3]),
	.JW2END4(JW2BEG[4]),
	.JW2END5(JW2BEG[5]),
	.JW2END6(JW2BEG[6]),
	.JW2END7(JW2BEG[7]),
	.J_l_AB_END0(J_l_AB_BEG[0]),
	.J_l_AB_END1(J_l_AB_BEG[1]),
	.J_l_AB_END2(J_l_AB_BEG[2]),
	.J_l_AB_END3(J_l_AB_BEG[3]),
	.J_l_CD_END0(J_l_CD_BEG[0]),
	.J_l_CD_END1(J_l_CD_BEG[1]),
	.J_l_CD_END2(J_l_CD_BEG[2]),
	.J_l_CD_END3(J_l_CD_BEG[3]),
	.J_l_EF_END0(J_l_EF_BEG[0]),
	.J_l_EF_END1(J_l_EF_BEG[1]),
	.J_l_EF_END2(J_l_EF_BEG[2]),
	.J_l_EF_END3(J_l_EF_BEG[3]),
	.J_l_GH_END0(J_l_GH_BEG[0]),
	.J_l_GH_END1(J_l_GH_BEG[1]),
	.J_l_GH_END2(J_l_GH_BEG[2]),
	.J_l_GH_END3(J_l_GH_BEG[3]),
	.N1BEG0(N1BEG[0]),
	.N1BEG1(N1BEG[1]),
	.N1BEG2(N1BEG[2]),
	.N1BEG3(N1BEG[3]),
	.N2BEG0(N2BEG[0]),
	.N2BEG1(N2BEG[1]),
	.N2BEG2(N2BEG[2]),
	.N2BEG3(N2BEG[3]),
	.N2BEG4(N2BEG[4]),
	.N2BEG5(N2BEG[5]),
	.N2BEG6(N2BEG[6]),
	.N2BEG7(N2BEG[7]),
	.N2BEGb0(N2BEGb[0]),
	.N2BEGb1(N2BEGb[1]),
	.N2BEGb2(N2BEGb[2]),
	.N2BEGb3(N2BEGb[3]),
	.N2BEGb4(N2BEGb[4]),
	.N2BEGb5(N2BEGb[5]),
	.N2BEGb6(N2BEGb[6]),
	.N2BEGb7(N2BEGb[7]),
	.N4BEG0(N4BEG[12]),
	.N4BEG1(N4BEG[13]),
	.N4BEG2(N4BEG[14]),
	.N4BEG3(N4BEG[15]),
	.bot2top0(bot2top[0]),
	.bot2top1(bot2top[1]),
	.bot2top2(bot2top[2]),
	.bot2top3(bot2top[3]),
	.bot2top4(bot2top[4]),
	.bot2top5(bot2top[5]),
	.bot2top6(bot2top[6]),
	.bot2top7(bot2top[7]),
	.bot2top8(bot2top[8]),
	.bot2top9(bot2top[9]),
	.E1BEG0(E1BEG[0]),
	.E1BEG1(E1BEG[1]),
	.E1BEG2(E1BEG[2]),
	.E1BEG3(E1BEG[3]),
	.E2BEG0(E2BEG[0]),
	.E2BEG1(E2BEG[1]),
	.E2BEG2(E2BEG[2]),
	.E2BEG3(E2BEG[3]),
	.E2BEG4(E2BEG[4]),
	.E2BEG5(E2BEG[5]),
	.E2BEG6(E2BEG[6]),
	.E2BEG7(E2BEG[7]),
	.E2BEGb0(E2BEGb[0]),
	.E2BEGb1(E2BEGb[1]),
	.E2BEGb2(E2BEGb[2]),
	.E2BEGb3(E2BEGb[3]),
	.E2BEGb4(E2BEGb[4]),
	.E2BEGb5(E2BEGb[5]),
	.E2BEGb6(E2BEGb[6]),
	.E2BEGb7(E2BEGb[7]),
	.E6BEG0(E6BEG[10]),
	.E6BEG1(E6BEG[11]),
	.S1BEG0(S1BEG[0]),
	.S1BEG1(S1BEG[1]),
	.S1BEG2(S1BEG[2]),
	.S1BEG3(S1BEG[3]),
	.S2BEG0(S2BEG[0]),
	.S2BEG1(S2BEG[1]),
	.S2BEG2(S2BEG[2]),
	.S2BEG3(S2BEG[3]),
	.S2BEG4(S2BEG[4]),
	.S2BEG5(S2BEG[5]),
	.S2BEG6(S2BEG[6]),
	.S2BEG7(S2BEG[7]),
	.S2BEGb0(S2BEGb[0]),
	.S2BEGb1(S2BEGb[1]),
	.S2BEGb2(S2BEGb[2]),
	.S2BEGb3(S2BEGb[3]),
	.S2BEGb4(S2BEGb[4]),
	.S2BEGb5(S2BEGb[5]),
	.S2BEGb6(S2BEGb[6]),
	.S2BEGb7(S2BEGb[7]),
	.S4BEG0(S4BEG[12]),
	.S4BEG1(S4BEG[13]),
	.S4BEG2(S4BEG[14]),
	.S4BEG3(S4BEG[15]),
	.W1BEG0(W1BEG[0]),
	.W1BEG1(W1BEG[1]),
	.W1BEG2(W1BEG[2]),
	.W1BEG3(W1BEG[3]),
	.W2BEG0(W2BEG[0]),
	.W2BEG1(W2BEG[1]),
	.W2BEG2(W2BEG[2]),
	.W2BEG3(W2BEG[3]),
	.W2BEG4(W2BEG[4]),
	.W2BEG5(W2BEG[5]),
	.W2BEG6(W2BEG[6]),
	.W2BEG7(W2BEG[7]),
	.W2BEGb0(W2BEGb[0]),
	.W2BEGb1(W2BEGb[1]),
	.W2BEGb2(W2BEGb[2]),
	.W2BEGb3(W2BEGb[3]),
	.W2BEGb4(W2BEGb[4]),
	.W2BEGb5(W2BEGb[5]),
	.W2BEGb6(W2BEGb[6]),
	.W2BEGb7(W2BEGb[7]),
	.W6BEG0(W6BEG[10]),
	.W6BEG1(W6BEG[11]),
	.A7(A7),
	.A6(A6),
	.A5(A5),
	.A4(A4),
	.A3(A3),
	.A2(A2),
	.A1(A1),
	.A0(A0),
	.B7(B7),
	.B6(B6),
	.B5(B5),
	.B4(B4),
	.B3(B3),
	.B2(B2),
	.B1(B1),
	.B0(B0),
	.C19(C19),
	.C18(C18),
	.C17(C17),
	.C16(C16),
	.C15(C15),
	.C14(C14),
	.C13(C13),
	.C12(C12),
	.C11(C11),
	.C10(C10),
	.C9(C9),
	.C8(C8),
	.C7(C7),
	.C6(C6),
	.C5(C5),
	.C4(C4),
	.C3(C3),
	.C2(C2),
	.C1(C1),
	.C0(C0),
	.clr(clr),
	.J2MID_ABa_BEG0(J2MID_ABa_BEG[0]),
	.J2MID_ABa_BEG1(J2MID_ABa_BEG[1]),
	.J2MID_ABa_BEG2(J2MID_ABa_BEG[2]),
	.J2MID_ABa_BEG3(J2MID_ABa_BEG[3]),
	.J2MID_CDa_BEG0(J2MID_CDa_BEG[0]),
	.J2MID_CDa_BEG1(J2MID_CDa_BEG[1]),
	.J2MID_CDa_BEG2(J2MID_CDa_BEG[2]),
	.J2MID_CDa_BEG3(J2MID_CDa_BEG[3]),
	.J2MID_EFa_BEG0(J2MID_EFa_BEG[0]),
	.J2MID_EFa_BEG1(J2MID_EFa_BEG[1]),
	.J2MID_EFa_BEG2(J2MID_EFa_BEG[2]),
	.J2MID_EFa_BEG3(J2MID_EFa_BEG[3]),
	.J2MID_GHa_BEG0(J2MID_GHa_BEG[0]),
	.J2MID_GHa_BEG1(J2MID_GHa_BEG[1]),
	.J2MID_GHa_BEG2(J2MID_GHa_BEG[2]),
	.J2MID_GHa_BEG3(J2MID_GHa_BEG[3]),
	.J2MID_ABb_BEG0(J2MID_ABb_BEG[0]),
	.J2MID_ABb_BEG1(J2MID_ABb_BEG[1]),
	.J2MID_ABb_BEG2(J2MID_ABb_BEG[2]),
	.J2MID_ABb_BEG3(J2MID_ABb_BEG[3]),
	.J2MID_CDb_BEG0(J2MID_CDb_BEG[0]),
	.J2MID_CDb_BEG1(J2MID_CDb_BEG[1]),
	.J2MID_CDb_BEG2(J2MID_CDb_BEG[2]),
	.J2MID_CDb_BEG3(J2MID_CDb_BEG[3]),
	.J2MID_EFb_BEG0(J2MID_EFb_BEG[0]),
	.J2MID_EFb_BEG1(J2MID_EFb_BEG[1]),
	.J2MID_EFb_BEG2(J2MID_EFb_BEG[2]),
	.J2MID_EFb_BEG3(J2MID_EFb_BEG[3]),
	.J2MID_GHb_BEG0(J2MID_GHb_BEG[0]),
	.J2MID_GHb_BEG1(J2MID_GHb_BEG[1]),
	.J2MID_GHb_BEG2(J2MID_GHb_BEG[2]),
	.J2MID_GHb_BEG3(J2MID_GHb_BEG[3]),
	.J2END_AB_BEG0(J2END_AB_BEG[0]),
	.J2END_AB_BEG1(J2END_AB_BEG[1]),
	.J2END_AB_BEG2(J2END_AB_BEG[2]),
	.J2END_AB_BEG3(J2END_AB_BEG[3]),
	.J2END_CD_BEG0(J2END_CD_BEG[0]),
	.J2END_CD_BEG1(J2END_CD_BEG[1]),
	.J2END_CD_BEG2(J2END_CD_BEG[2]),
	.J2END_CD_BEG3(J2END_CD_BEG[3]),
	.J2END_EF_BEG0(J2END_EF_BEG[0]),
	.J2END_EF_BEG1(J2END_EF_BEG[1]),
	.J2END_EF_BEG2(J2END_EF_BEG[2]),
	.J2END_EF_BEG3(J2END_EF_BEG[3]),
	.J2END_GH_BEG0(J2END_GH_BEG[0]),
	.J2END_GH_BEG1(J2END_GH_BEG[1]),
	.J2END_GH_BEG2(J2END_GH_BEG[2]),
	.J2END_GH_BEG3(J2END_GH_BEG[3]),
	.JN2BEG0(JN2BEG[0]),
	.JN2BEG1(JN2BEG[1]),
	.JN2BEG2(JN2BEG[2]),
	.JN2BEG3(JN2BEG[3]),
	.JN2BEG4(JN2BEG[4]),
	.JN2BEG5(JN2BEG[5]),
	.JN2BEG6(JN2BEG[6]),
	.JN2BEG7(JN2BEG[7]),
	.JE2BEG0(JE2BEG[0]),
	.JE2BEG1(JE2BEG[1]),
	.JE2BEG2(JE2BEG[2]),
	.JE2BEG3(JE2BEG[3]),
	.JE2BEG4(JE2BEG[4]),
	.JE2BEG5(JE2BEG[5]),
	.JE2BEG6(JE2BEG[6]),
	.JE2BEG7(JE2BEG[7]),
	.JS2BEG0(JS2BEG[0]),
	.JS2BEG1(JS2BEG[1]),
	.JS2BEG2(JS2BEG[2]),
	.JS2BEG3(JS2BEG[3]),
	.JS2BEG4(JS2BEG[4]),
	.JS2BEG5(JS2BEG[5]),
	.JS2BEG6(JS2BEG[6]),
	.JS2BEG7(JS2BEG[7]),
	.JW2BEG0(JW2BEG[0]),
	.JW2BEG1(JW2BEG[1]),
	.JW2BEG2(JW2BEG[2]),
	.JW2BEG3(JW2BEG[3]),
	.JW2BEG4(JW2BEG[4]),
	.JW2BEG5(JW2BEG[5]),
	.JW2BEG6(JW2BEG[6]),
	.JW2BEG7(JW2BEG[7]),
	.J_l_AB_BEG0(J_l_AB_BEG[0]),
	.J_l_AB_BEG1(J_l_AB_BEG[1]),
	.J_l_AB_BEG2(J_l_AB_BEG[2]),
	.J_l_AB_BEG3(J_l_AB_BEG[3]),
	.J_l_CD_BEG0(J_l_CD_BEG[0]),
	.J_l_CD_BEG1(J_l_CD_BEG[1]),
	.J_l_CD_BEG2(J_l_CD_BEG[2]),
	.J_l_CD_BEG3(J_l_CD_BEG[3]),
	.J_l_EF_BEG0(J_l_EF_BEG[0]),
	.J_l_EF_BEG1(J_l_EF_BEG[1]),
	.J_l_EF_BEG2(J_l_EF_BEG[2]),
	.J_l_EF_BEG3(J_l_EF_BEG[3]),
	.J_l_GH_BEG0(J_l_GH_BEG[0]),
	.J_l_GH_BEG1(J_l_GH_BEG[1]),
	.J_l_GH_BEG2(J_l_GH_BEG[2]),
	.J_l_GH_BEG3(J_l_GH_BEG[3]),
	.ConfigBits(ConfigBits[368-1:6])
	);

endmodule
