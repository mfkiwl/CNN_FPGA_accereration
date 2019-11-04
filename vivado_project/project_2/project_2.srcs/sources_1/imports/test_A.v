module moduleA(
  output reg [31:0]ADDR,
  output reg [2:0]BURST,
  output reg [3:0]PROT,
  input [31:0]RDATA,
  output reg READY_in,
  input READY_out,
  input RESP,
  output reg [2:0]hsize,
  output reg [1:0]TRANS,
  output reg [31:0]WDATA,
  output reg HWRITE,
  output reg SEL,
  
  output reg start,
  input finish,
  
  input clk,
  input reset
);

reg [3:0] state;

wire [31:0] start_code;
wire [31:0] finish_code;
assign start_code = 32'h01020304;
assign finish_code = 32'h04030201;

reg [31:0] temp;

always @(posedge clk) begin
    if ( !reset ) begin
        ADDR <= 0;
        BURST <= 0;
        PROT <= 0;
        READY_in <= 0;
        hsize <= 0;
        TRANS <= 0;
        WDATA <= 0;
        HWRITE <= 0;
        SEL <= 0;
        
        start <= 0;
        state <= 0;
    end
    else begin
    case(state)
        4'd0: begin // try to read
            if ( READY_out == 1 ) begin
                TRANS <= 2'b10;
                ADDR <= 32'h5000_0000; // start code position
                BURST <= 0;
                hsize <= 3'b010;
                READY_in <= 1;
                SEL <= 1;
                PROT <= 1;
                
                state <= 4'd1;                
            end
        end
        4'd1: begin // read the data
            if ( READY_out == 1 ) begin
                temp <= RDATA;
                SEL <= 0;
                PROT <= 0;
                READY_in <= 1;
                
                state <= 4'd2;
            end
            else begin
                READY_in <= 0;
            end
            TRANS <= 0;
        end
        4'd2: begin // compare the data to start code
            if ( temp == start_code ) begin
                start <= 1;
                state <= 4'd3;
            end
            else begin
                state <= 4'd0;
            end
        end
        4'd3: begin // wait for finish signal from processing module
            if ( finish == 1 ) begin
                state <= 4'd4;
            end
            ADDR <= 0;
            BURST <= 0;
            PROT <= 0;
            READY_in <= 0;
            hsize <= 0;
            TRANS <= 0;
            WDATA <= 0;
            HWRITE <= 0;
            SEL <= 0;
        end
        4'd4: begin // write finish code
            if ( READY_out == 1 && RESP == 0) begin
                TRANS <= 2'b10;
                ADDR <= 32'h5000_0004;
                BURST <= 0;
                hsize <= 3'b010; //Byte
                READY_in <= 1;
                SEL <= 1;
                PROT <= 9;
                WDATA <= finish_code;
                HWRITE <= 1;
                state <= 4'd5;
            end
        end
        4'd5: begin
            TRANS <= 0;
            READY_in <= 0;
            state <= 4'd6;
        end
        4'd6: begin
            if ( READY_out == 0 && RESP == 0) begin
                SEL <= 0;
                PROT <= 0;
                WDATA <= 0;
                HWRITE <= 0;
                READY_in <= 1;
                state <= 4'd7;
            end
        end
        default: begin
        ADDR <= 0;
        BURST <= 0;
        PROT <= 0;
        READY_in <= 0;
        hsize <= 0;
        TRANS <= 0;
        WDATA <= 0;
        HWRITE <= 0;
        SEL <= 0;
        end
        
    endcase
    end
end
endmodule