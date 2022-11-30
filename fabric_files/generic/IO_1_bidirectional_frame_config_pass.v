//Library UNISIM;
//use UNISIM.vcomponents.all;

module IO_1_bidirectional_frame_config_pass (I, T, O, Q, I_top, T_top, O_top, UserCLK, OutputEnable);//, ConfigBits);
	//parameter NoConfigBits = 0; // has to be adjusted manually (we don't use an arithmetic parser for the value)
	// Pin0
	input I; // from fabric to external pin
	input T; // tristate control
	output O; // from external pin to fabric
	output Q; // from external pin to fabric (registered)
	output I_top; // EXTERNAL has to ge to top-level entity not the switch matrix
	output T_top; // EXTERNAL has to ge to top-level entity not the switch matrix
	input O_top; // EXTERNAL has to ge to top-level entity not the switch matrix
	// Tile IO ports from BELs
	input OutputEnable; // EXTERNAL // SHARED_PORT // ## the EXTERNAL keyword will send this signal all the way to top and the //SHARED Allows multiple BELs using the same port (e.g. for exporting a clock to the top)
	input UserCLK; // EXTERNAL // SHARED_PORT // ## the EXTERNAL keyword will send this signal all the way to top and the //SHARED Allows multiple BELs using the same port (e.g. for exporting a clock to the top)
	// GLOBAL all primitive pins that are connected to the switch matrix have to go before the GLOBAL label
	//input [NoConfigBits-1 : 0] ConfigBits;
//                        _____
//    I////-T_DRIVER////->|PAD|//+//////-> O
//              |         ////-  |
//    T////////-+                +//>FF//> Q

// I am instantiating an IOBUF primitive.
// However, it is possible to connect corresponding pins all the way to top, just by adding an "// EXTERNAL" comment (see PAD in the entity)
	reg Q_pre;
// wire fromPad;
// Slice outputs
	fpga_outbuf q_obuf_i (.I(Q_pre), .GOE(OutputEnable), .O(Q));
	fpga_outbuf o_obuf_i (.I(O_top), .GOE(OutputEnable), .O(O));

	always @ (posedge UserCLK)
	begin
		Q_pre <= O_top;
	end

	assign I_top = I;
	assign T_top = ~T | ~OutputEnable;

// IOBUF IOBUF_inst0(
// .O(fromPad), // 1-bit output: Buffer output
// .I(I), // 1-bit input: Buffer input
// .IO(PAD), // 1-bit inout: Buffer inout (connect directly to top-level port)
// .T(T) // 1-bit input: 3-state enable input
// );

endmodule
