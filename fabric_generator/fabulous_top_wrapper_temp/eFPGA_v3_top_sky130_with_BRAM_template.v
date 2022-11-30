module eFPGA_top (I_top, T_top, O_top, A_config_C, B_config_C, CLK, OutputEnable, FrameRegister, FrameSelect);

	localparam include_eFPGA = 1;
	localparam NumberOfRows = 16;
	localparam NumberOfCols = 19;
	localparam FrameBitsPerRow = 32;
	localparam MaxFramesPerCol = 20;
	localparam desync_flag = 20;
	localparam FrameSelectWidth = 5;
	localparam RowSelectWidth = 5;

	// External USER ports 
	//inout [16-1:0] PAD; // these are for Dirk and go to the pad ring
	output wire [32-1:0] I_top; 
	output wire [32-1:0] T_top;
	input wire [32-1:0] O_top;
	output wire [64-1:0] A_config_C;
	output wire [64-1:0] B_config_C;

	input wire [XXX:0] FrameRegister;
	input wire [XXX:0] FrameSelect;

	input wire CLK; // This clock can go to the CPU (connects to the fabric LUT output flops
	input wire OutputEnable; // This clock can go to the CPU (connects to the fabric LUT output flops

	wire [(FrameBitsPerRow*(NumberOfRows+2))-1:0] FrameData;

	// L: if include_eFPGA = 1 generate

