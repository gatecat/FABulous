module Frame_Select (FrameStrobe_I, FrameStrobe_O, FrameSelect, FrameStrobe);
	parameter MaxFramesPerCol = 20;
	parameter FrameSelectWidth = 5;
	parameter Col = 18;
	input [$clog2(MaxFramesPerCol+1)-1:0] FrameStrobe_I;
	output reg [MaxFramesPerCol-1:0] FrameStrobe_O;
	input [FrameSelectWidth-1:0] FrameSelect;
	input FrameStrobe;

//FrameStrobe_O = 0;
	always @ (*) begin
		FrameStrobe_O = 'd0;
		if (FrameStrobe && (FrameSelect==Col) && FrameStrobe_I != 0 && FrameStrobe_I <= MaxFramesPerCol)
			FrameStrobe_O[FrameStrobe_I-1] = 1'b1;
	end
endmodule