`ifndef PARAM_RED
    `include "../Parametros_Red.v"
`endif

module ULA (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [4:0]  ALUControl, 
    output reg  [31:0] Result,
    output wire        Zero
);
    
    assign Zero = (Result == 32'b0);

    always @(*) begin
        case (ALUControl)
            OPAND: Result = A & B;
            OPOR:  Result = A | B;
            OPADD: Result = A + B;
            OPSUB: Result = A - B;
            OPSLT: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            OPSLL: Result = A << B[4:0];
            OPLUI: Result = B;
            default: Result = 32'b0;
        endcase
    end

endmodule