module moduleA(

  input [31:0]RDATA,
  input READY_out,
  input RESP,

  output reg [31:0]ADDR,  
  output reg READY_in,

  output reg [1:0]TRANS,  
  output reg [2:0]BURST,
  output reg [2:0]hsize,
  
  output reg SEL,
  output reg [3:0]PROT,

  output reg HWRITE,
  output reg [31:0]WDATA,
  
  output reg start,
  input finish,
  
  input clk,
  input reset
);

wire [31:0] start_signal_0;
wire [31:0] end_signal_0;
assign start_signal_0 = 32'h01020304;
assign end_signal_0 = 32'h04030201;

reg [3:0] state;


reg [31:0] temp;

   parameter S0 = 4'd0; // idle try to read ( address == 5000_0000 )
  parameter S1 = 4'd1; // read the data
  parameter S2 = 4'd2; // check if read data is same as 01020304
  parameter S3 = 4'd3; // waiting fin from module B.
  parameter S4 = 4'd4; // if fin == 1 ( add is end ) change the PC to 5000_0004
  parameter S5 = 4'd5; // trans = 0 and readyin = 0 ( ending the case )
  parameter S6 = 4'd6; // ready = 1 to implement the AHB bus end
  parameter S7 = 4'd7; // idle


    // parameter start_signal_0 = 32'h01020304;
    // parameter end_signal_0 = 32'h04030201;

always @(posedge clk) begin
    if ( !reset ) begin

        start <= 0;

        ADDR <= 0;
        READY_in <= 0;

        TRANS <= 0;
        BURST <= 0;
        hsize <= 0;

        SEL <= 0;
        PROT <= 0;

        HWRITE <= 0;
        WDATA <= 0;
        
        state <= S0;
    end
    else begin
    case(state)
        S0 : begin // assign address for start signal
            if ( READY_out == 1 ) begin

                ADDR <= 32'h5000_0000; // register of start signal
                READY_in <= 1;         // ready ( output )

                TRANS <= 2'b10;         // 00 idle, 10 nenseq
                BURST <= 0;             // burst gogo
                hsize <= 3'b010;        // we use only 010 ( word ), 32bit

                SEL <= 1;               // sel 0
                PROT <= 1;              // 0000 idle, 0001 read 1001 write
                
                state <= S1 ;                
            end
        end
        S1: begin // read the data from 0x5000_0000[0] ( start_ signal )
            if ( READY_out == 1 ) begin
                READY_in <= 1;

                SEL <= 0;
                PROT <= 0;

                temp <= RDATA;

                state <= S2;
            end
            else begin
                READY_in <= 0;
            end
            TRANS <= 0;
        end
        S2: begin // compare the data to 0x01020304
            if ( temp == start_signal_0 ) begin
                state <= S3;
                
                start <= 1; // starting moduleB ( calculation )

            end
            else begin
                state <=  S0;
            end
        end
        S3 : begin // wait until calculation done
            if ( finish == 1 ) begin
                state <= S4;
            end
            ADDR <= 0;
            READY_in <= 0;

            TRANS <= 0;
            BURST <= 0;           
            hsize <= 0;

            SEL <= 0;
            PROT <= 0;

            HWRITE <= 0;
            WDATA <= 0;

        end
        S4: begin // assign address for end signal and write ( resp = 0 ) 
            if ( READY_out == 1 && RESP == 0) begin
                ADDR <= 32'h5000_0004;  // address
                READY_in <= 1;          // ready (output)

                TRANS <= 2'b10;         // 10 nonseq
                BURST <= 0;             // burst 
                hsize <= 3'b010;        // 32 bit

                SEL <= 1;
                PROT <= 9;              // prot 9 is write transfer

                HWRITE <= 1;            // do w
                WDATA <= end_signal_0; // write 0x04030201

                state <= S5;
            end
        end
        S5: begin // write the data

            READY_in <= 0;
            TRANS <= 0;

            state <= S6;
        end
        S6: begin // end of write, then go to default state.
            if ( READY_out == 0 && RESP == 0) begin

                READY_in <= 1;

                SEL <= 0;
                PROT <= 0;

                HWRITE <= 0;
                WDATA <= 0;

                state <= S7;
            end
        end
        default: begin

        ADDR <= 0;
        READY_in <= 0;

        TRANS <= 0;
        BURST <= 0;
        hsize <= 0;

        SEL <= 0;
        PROT <= 0;

        HWRITE <= 0;
        WDATA <= 0;
        
        end
        
    endcase
    end
end
endmodule