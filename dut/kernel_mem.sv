// module kernel_mem #(
//     parameter N = 3,
//     localparam kernel_addr_width = $clog2(N**2) ) (
//     input clk,
//     input rst_n,
//     input kernel_we, processing_en,
//     input signed [7:0] kernel_data,
//     input [kernel_addr_width - 1 :0] kernel_addr,
//     output reg signed [7:0] kernel_coeff [0:N-1] [0:N-1]
// );

// localparam int size_mem = N*N - 1;
// reg signed [7:0] mem[0 : size_mem];
// reg undefined_mem;                                    // an internal flag to help me prevent loading data that doesnot exit

// always@(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin                                 // if rest so output must be undefined
//         int i, j;
//         undefined_mem <= 1;                          // so prevent loading when no data inside the memory
//         for (i = 0; i < N; i++)
//             for (j = 0; j < N; j++)
//                 kernel_coeff[i][j] <= 8'sbx;
//     end
//     else if(!processing_en) begin 
//         if (kernel_we) begin
//             undefined_mem <= 0;
//             mem[kernel_addr] <= kernel_data;
//         end                                         // when writeing is enabled I will let the kernal data to be driven
//     end
//     else if (!undefined_mem) begin
//     for (int row = 0; row < N; row++)
//         for (int col = 0; col < N; col++)
//             kernel_coeff[row][col] <= mem[row*N + col];
//     end
// end
// endmodule

module kernel_mem #(
    // Parameters
        parameter int unsigned N = 3,
        parameter int unsigned DEPTH = N*N,
        parameter int unsigned KERNEL_MEM_W = $clog2(DEPTH)
) (
    // Inputs
        input  logic                        clk,
        input  logic                        processing_en,
        input  logic                        kernel_we,
        input  logic [KERNEL_MEM_W-1 : 0]   kernel_waddr,
        input  logic signed [7:0]           kernel_wdata,
    // Outputs
        output logic signed [7:0]           kernel_coeff [DEPTH]
);
    always_ff @(posedge clk) begin
        if (kernel_we && !processing_en && (kernel_waddr < DEPTH)) 
            kernel_coeff [kernel_waddr] <= kernel_wdata;
    end

    initial begin
      kernel_coeff = '0;
    end
endmodule
