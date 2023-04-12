// Copyright 2021 University of Manchester
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	  http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

(*FABulous, BelMap,
INIT=0,
INIT_1=1,
INIT_2=2,
INIT_3=3,
INIT_4=4,
INIT_5=5,
INIT_6=6,
INIT_7=7,
INIT_8=8,
INIT_9=9,
INIT_10=10,
INIT_11=11,
INIT_12=12,
INIT_13=13,
INIT_14=14,
INIT_15=15,
INIT_16=16,
INIT_17=17,
INIT_18=18,
INIT_19=19,
INIT_20=20,
INIT_21=21,
INIT_22=22,
INIT_23=23,
INIT_24=24,
INIT_25=25,
INIT_26=26,
INIT_27=27,
INIT_28=28,
INIT_29=29,
INIT_30=30,
INIT_31=31,
INIT_32=32,
INIT_33=33,
INIT_34=34,
INIT_35=35,
INIT_36=36,
INIT_37=37,
INIT_38=38,
INIT_39=39,
INIT_40=40,
INIT_41=41,
INIT_42=42,
INIT_43=43,
INIT_44=44,
INIT_45=45,
INIT_46=46,
INIT_47=47,
INIT_48=48,
INIT_49=49,
INIT_50=50,
INIT_51=51,
INIT_52=52,
INIT_53=53,
INIT_54=54,
INIT_55=55,
INIT_56=56,
INIT_57=57,
INIT_58=58,
INIT_59=59,
INIT_60=60,
INIT_61=61,
INIT_62=62,
INIT_63=63,
FRAC=64,
CARRY=65,
FF=66,
FF2=67,
SET_NORESET=68,
SET_NORESET2=69
*)
module FABULOUS_LC (I0, I1, I2, I3, I4, I5, O, O2, Ci, Co, SR, EN, UserCLK, ConfigBits);
	parameter NoConfigBits = 70 ; // has to be adjusted manually (we don't use an arithmetic parser for the value)
	// IMPORTANT: this has to be in a dedicated line
	input I0; // LUT inputs
	input I1;
	input I2;
	input I3;
	input I4;
	input I5;
	output O; // LUT output (combinatorial or FF)
	output O2; // fracturable output or second FF output
	input Ci; // carry chain input
	output Co; // carry chain output
	input SR; // SHARED_RESET
	input EN; // SHARED_ENABLE
	(* FABulous, EXTERNAL, SHARED_PORT *) input UserCLK; // EXTERNAL // SHARED_PORT // ## the EXTERNAL keyword will send this sisgnal all the way to top and the //SHARED Allows multiple BELs using the same port (e.g. for exporting a clock to the top)
	// GLOBAL all primitive pins that are connected to the switch matrix have to go before the GLOBAL label
	(* FABulous, GLOBAL *) input [NoConfigBits-1 : 0] ConfigBits;

	wire [63:0] LUT_init = ConfigBits[63:0];
	wire c_FRAC = ConfigBits[64];
	wire c_CARRY = ConfigBits[65];
	wire c_FF = ConfigBits[66];
	wire c_FF2 = ConfigBits[67];
	wire c_reset_value = ConfigBits[68];
	wire c_reset_value2 = ConfigBits[69];

	wire [5:0] LUT_sel = {I5,I4,I3,I2,I1,I0};
	wire [3:0] mux16_o;
	wire [1:0] mux32_o;

	// Instatiate 4x 16:1 BUFs as LUT4s
	generate
		genvar ii;
		for (ii = 0; ii < 4; ii = ii + 1'b1) begin : muxes
			cus_mux161_buf inst_cus_mux161_buf(
				.A0(LUT_init[16*ii + 0]),
				.A1(LUT_init[16*ii + 1]),
				.A2(LUT_init[16*ii + 2]),
				.A3(LUT_init[16*ii + 3]),
				.A4(LUT_init[16*ii + 4]),
				.A5(LUT_init[16*ii + 5]),
				.A6(LUT_init[16*ii + 6]),
				.A7(LUT_init[16*ii + 7]),
				.A8(LUT_init[16*ii + 8]),
				.A9(LUT_init[16*ii + 9]),
				.A10(LUT_init[16*ii + 10]),
				.A11(LUT_init[16*ii + 11]),
				.A12(LUT_init[16*ii + 12]),
				.A13(LUT_init[16*ii + 13]),
				.A14(LUT_init[16*ii + 14]),
				.A15(LUT_init[16*ii + 15]),
				.S0 (LUT_sel[0]),
				.S0N(~LUT_sel[0]),
				.S1 (LUT_sel[1]),
				.S1N(~LUT_sel[1]),
				.S2 (LUT_sel[2]),
				.S2N(~LUT_sel[2]),
				.S3 (LUT_sel[3]),
				.S3N(~LUT_sel[3]),
				.X  (mux16_o[ii])
			);
		end
	endgenerate

	wire top_o, lut6_o, sum_o, comb_o, comb2_o;

	// Make LUT5s out of the LUT4s
	my_mux2 l5mux_0 (.A0(mux16_o[0]), .A1(mux16_o[1]), .S(LUT_sel[4]), .X(mux32_o[0]));
	my_mux2 l5mux_1 (.A0(mux16_o[2]), .A1(mux16_o[3]), .S(LUT_sel[4]), .X(mux32_o[1]));

	// Make a LUT6 out of the LUT5s
	my_mux2 l6mux_0 (.A0(mux16_o[2]), .A1(mux16_o[3]), .S(LUT_sel[4]), .X(lut6_o));

	// Select first output between LUT6 or first LUT5
	my_mux2 frac_sel (.A0(lut6_o), .A1(mux32_o[0]), .S(c_FRAC), .X(top_o));
	// Second comb output is hardwired to second LUT5
	assign comb2_o = mux32_o[1];

	// The carry logic implementation
	assign Co = top_o ? Ci : mux32_o[1];
	assign sum_o = top_o ^ Ci;

	// Select between carry or no carry
	my_mux2 carry_sel (.A0(top_o), .A1(sum_o), .S(c_CARRY), .X(comb_o));

	// The two flipflops on the two combinational outputs
	reg ff_o, ff2_o;
	always @ (posedge UserCLK) begin
		if (EN) begin
			if (SR) begin
				ff_o <= c_reset_value;
				ff2_o <= c_reset_value2;
			end else begin
				ff_o <= comb_o;
				ff2_o <= comb2_o;
			end
		end
	end

	// Select between comb or FF
	my_mux2 ff_sel (.A0(comb_o), .A1(ff_o), .S(c_FF), .X(O));
	my_mux2 ff2_sel (.A0(comb2_o), .A1(ff2_o), .S(c_FF2), .X(O2));

endmodule
