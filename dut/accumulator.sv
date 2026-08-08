module accumulator #(
    parameter PARTIAL_W = 18,
    N = 3,
    ACC_W = (PARTIAL_W + $clog2(N)) 
    ) (
    input signed [PARTIAL_W - 1:0] partial_sum [0 : N-1],
    input partial_valid, partial_last,
    output signed [ACC_W-1:0] conv_result,
    output conv_valid, conv_last
);



always@(*) begin

    if(partial_valid) begin
        int i;
        conv_result = 0;
        conv_valid = 1;
        for(i = 0; i < N; i++) begin
            conv_result = conv_result + partial_sum[i];
        end
        conv_last = partial_last;
    end
    else begin
        conv_valid = 0;
        conv_result = 0;
        conv_last = 0;
    end
end

endmodule
