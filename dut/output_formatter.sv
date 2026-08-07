module output_formatter#(parameter ACC_W) (
    input [ACC_W -1 : 0] relu_result,
    input relu_valid, round_en,
    input [4:0] shamt,
    output reg signed [15:0] pixel_out,
    output reg pixel_valid
);

logic signed [ACC_W +1 :0] scalling, pre_shift;
logic signed [ACC_W +5 :0] offcet;

always@(*) begin

    if(relu_valid) begin

        pixel_valid = 1;
        if(round_en && shamt > 0) begin
            offcet = 1 << (shamt-1);
        end
        else if (round_en == 0 || shamt == 0 ) begin
            offcet = 0;
        end

        pre_shift = relu_result + offcet;

        if(shamt)
            scalling = pre_shift >>> shamt;
        else
            scalling = pre_shift;

        if(scalling > 16'sd32767)
            scalling = 16'sd32767;
        else if(scalling <  -16'sd32768)
            scalling = -16'sd32768;

        pixel_out = scalling;
        pixel_valid = 1;

    end
    else begin
        pixel_valid = 0;
        pixel_out = 0;
    end
end

endmodule
