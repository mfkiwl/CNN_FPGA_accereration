module moduleB(
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
  
  input start,
  output reg finish,
  
  input clk,
  input reset
  
);

reg [3:0] state;

reg [31:0] count, count_2, count_3, count_4, count_max;

reg [31:0] data_A;

reg [7:0] B_11, B_12, B_13, B_21, B_22, B_23, B_31, B_32, B_33; 

reg [15:0] A_temp;
reg [31:0] mul_temp;
reg [7:0] mul_1, mul_2, mul_3, mul_4, mul_write;

wire [15:0] Bmul_11, Bmul_12, Bmul_13, Bmul_21, Bmul_22, Bmul_23, Bmul_31, Bmul_32, Bmul_33;
wire [7:0] mul;

assign Bmul_11[7:0] =(B_11[7]==0)? B_11:~B_11+1'b1;
assign Bmul_12[7:0] =(B_12[7]==0)? B_12:~B_12+1'b1; // - sign
assign Bmul_13[7:0] =(B_13[7]==0)? B_13:~B_13+1'b1;
assign Bmul_21[7:0] =(B_21[7]==0)? B_21:~B_21+1'b1; // - sign
assign Bmul_22[7:0] =(B_22[7]==0)? B_22:~B_22+1'b1;
assign Bmul_23[7:0] =(B_23[7]==0)? B_23:~B_23+1'b1; // - sign
assign Bmul_31[7:0] =(B_31[7]==0)? B_31:~B_31+1'b1; // - sign
assign Bmul_32[7:0] =(B_32[7]==0)? B_32:~B_32+1'b1; // - sign
assign Bmul_33[7:0] =(B_33[7]==0)? B_33:~B_33+1'b1;

assign mul = (mul_write[7]==0)? mul_write : 0 ;
     parameter S0 = 4'd0; // idle1, DEFUALT
     parameter S1 = 4'd1; // read ready
     parameter S2 = 4'd2; // read + vector addition ï¿½ï¿½Ù¸ï¿???
     parameter S3 = 4'd3; // write
     parameter S4 = 4'd4;   // idle 3
     parameter S5 = 4'd5; 
     parameter S6 = 4'd6;
     parameter S7 = 4'd7;
     parameter S8 = 4'd8;
     parameter S9 = 4'd9;
     parameter S10 = 4'd10;
     parameter S11 = 4'd11;
     parameter S12 = 4'd12;
     parameter S13 = 4'd13;
     parameter S14 = 4'd14;
     parameter S15 = 4'd15;


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
        
        count <= 0;
    
        finish <= 0;
        state <= S0;
    end
    else begin
        case(state)
        S0: begin
            if ( start )
                state <= S1;
             end


        S1: begin //try read B
            if ( READY_out == 1 ) begin
                TRANS <= 2'b10;
                ADDR <= 32'h4001_0000 + count_2;
                BURST <= 0;
                hsize <= 3'b010;
                READY_in <= 1;
                SEL <= 1;
                PROT <= 1;
                
                state <= S9;                
            end
        end

        S9: begin
            READY_in <= 0;
            TRANS <= 0;
            state <= S2;    
        end

        S2: begin // read convolution data and save until 4*9
            if ( READY_out == 1 ) begin
                //data_A <= RDATA;
                SEL <= 0;
                PROT <= 0;
                READY_in <= 1;
                end
                if ( count_2 == 0) begin
                B_11 <= RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 4) begin
                B_12 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 8) begin
                B_13 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 12) begin
                B_21 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 16) begin
                B_22 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 20) begin
                B_23 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 24) begin
                B_31 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
                else if (count_2 == 28) begin
                B_32 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= S1;
                end
               
                else if ( count_2 == 32 ) begin // = 32'hfffc
                    B_33 <=RDATA[31:24];
                    state <= S3;
                end
  
        end

        
            

        S3: begin //try read A
            if ( READY_out == 1 ) begin
                TRANS <= 2'b10;
                ADDR <= 32'h4000_0000 + count +count_3 + count_max;
                BURST <= 0;
                hsize <= 3'b010;
                READY_in <= 1;
                SEL <= 1;
                PROT <= 1;
                
                state <= S10;                
            end
        end
        S10: begin
            READY_in <= 0;
            TRANS <= 0;
            state <= S4;
        end
        S4: begin // read the data A
                if ( READY_out == 1 ) begin
                    
                A_temp[12:5] <= RDATA[31:24];
                SEL <= 0;
                PROT <= 0;
                READY_in <= 1;
                end
                if ( count_max ==0 ) state <= S11;
                else if (count_max ==4 ) state <= S12;
                else if (count_max ==4*84 ) state <= S13;    
                else if (count_max ==4*85 ) state <= S14;                  
                
                //state <= S11;
            end
        S11 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=S3;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=S3;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=S3;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=S3;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=S3;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=S3;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=S3;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=S3;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 

                    state <=S11;
                end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4;
                mul_1[7:0] <= mul_temp[19:12]; // ReLU completed
                mul_temp <=0;
                state <= S3;


                end
            end
           end
           
          
        S12 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=S3;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=S3;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=S3;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=S3;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=S3;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=S3;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=S3;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=S3;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=S12;
                 end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4*84;
                mul_2[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= S3;


                end
               end
              end
         S13 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=S3;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=S3;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=S3;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=S3;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=S3;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=S3;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=S3;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=S3;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=S13;
                  end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4*85;
                mul_3[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= S3;


                end
            end
        end
         S14 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=S3;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=S3;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=S3;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=S3;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=S3;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=S3;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=S3;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=S3;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=S14;
                 end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 0;
                mul_4[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= S15;


                end
        end
    end

        S15 : begin
            if ( READY_out == 1 ) begin
                if ( mul_1 >= mul_2 ) begin
                    if( mul_1>= mul_3) begin
                        if (mul_1 >= mul_4) begin
                        mul_write <= mul_1;
                        state <= S5;
                     end
                        else begin // 4 > 1,2,3
                        mul_write <= mul_4;
                        state <= S5;                        
                     end
                     end
                     else begin // mul_3 > 1,2
                        if (mul_3 >= mul_4) begin
                            mul_write <= mul_3;
                            state <= S5;
                        end
                        else begin
                            mul_write <= mul_4;
                            state <= S5;
                        end
                       end
                      end
               else begin // 2 >1
                    if( mul_2>= mul_3) begin
                     if (mul_2 >= mul_4) begin
                          mul_write <= mul_2;
                          state <= S5;
                        end
                           else begin // 4 > 1,2,3
                           mul_write <= mul_4;
                           state <= S5;                        
                         end
                        end
                                else begin // mul_3 > 1,2
                                   if (mul_3 >= mul_4) begin
                                        mul_write <= mul_3;
                                         state <= S5;
                                         end
                                    else begin
                                       mul_write <= mul_4;
                                         state <= S5;
                                     end
                                     end                    
               end
             end

          end 
        S5: begin // write finish code
            if ( READY_out == 1 && RESP == 0 ) begin
                TRANS <= 2'b10;
                ADDR <= 32'h4002_0000 + count;
                BURST <= 0;
                hsize <= 3'b010; 
                READY_in <= 1;
                SEL <= 1;
                PROT <= 9;
                WDATA <= {mul,mul,mul,mul}; 
                HWRITE <= 1;
                state <= S6;
            end
        end
        S6: begin
            TRANS <= 0;
            READY_in <= 0;
            state <= S7;
        end
        S7: begin
            if ( READY_out == 0 && RESP == 0) begin
                SEL <= 0;
                PROT <= 0;
                WDATA <= 0;
                HWRITE <= 0;
                READY_in <= 1;
                
                if ( count >= 27200 ) begin // = 32'hfffc // 56448, 28224 , 4*1681=6724 // 27536-8
                    state <= S8;
                end
                else begin
                    if ( count_4 < 41) begin
                        count <= count + 8;
                        count_4 <= count_4 + 1'd1;
                    end
                    else if (count_4 == 41) begin
                        count_4<=0;
                        count <= count +16 + 4*84;
                      end
                    state <= S3;
                end
            end
        end
        S8: begin // out finish signal
            finish <= 1;
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