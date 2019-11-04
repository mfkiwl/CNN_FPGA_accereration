module moduleB(

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

  input start,
  output reg finish,
  
  input clk,
  input reset
  
);

reg [3:0] state;

reg [31:0] count, count_2, count_3, count_4, count_max;
// count : for whole loop of calculation ends at 4*(80*84 + 80 ). it indicates convolution position
// count_2 : for loop of read weight
// count_3 : present matrix position
// count_4 : cut at 82th row position.
// count_max : checking max pooling done 

reg [7:0] B_11, B_12, B_13, B_21, B_22, B_23, B_31, B_32, B_33; 
reg [15:0] A_temp;
reg [31:0] mul_temp;
reg [7:0] mul_1, mul_2, mul_3, mul_4, mul_write;

wire [15:0] Bmul_11, Bmul_12, Bmul_13, Bmul_21, Bmul_22, Bmul_23, Bmul_31, Bmul_32, Bmul_33;
wire [7:0] mul;

// these are variables for weight. get abs to calculate multiplication.
assign Bmul_11[7:0] =(B_11[7]==0)? B_11:~B_11+1'b1;
assign Bmul_12[7:0] =(B_12[7]==0)? B_12:~B_12+1'b1; // - sign
assign Bmul_13[7:0] =(B_13[7]==0)? B_13:~B_13+1'b1;
assign Bmul_21[7:0] =(B_21[7]==0)? B_21:~B_21+1'b1; // - sign
assign Bmul_22[7:0] =(B_22[7]==0)? B_22:~B_22+1'b1;
assign Bmul_23[7:0] =(B_23[7]==0)? B_23:~B_23+1'b1; // - sign
assign Bmul_31[7:0] =(B_31[7]==0)? B_31:~B_31+1'b1; // - sign
assign Bmul_32[7:0] =(B_32[7]==0)? B_32:~B_32+1'b1; // - sign
assign Bmul_33[7:0] =(B_33[7]==0)? B_33:~B_33+1'b1;
// Do ReLU 
assign mul = (mul_write[7]==0)? mul_write : 0 ;
// ********************************************************************************************* state

     parameter S0 = 4'd0; // check start signal

     ////////////////////////////read convolution weight///////////////////////////////////  loop1    
     parameter read_wgt_0 = 4'd1; // assign address to read weight value ( 4001_0000[i] ) i < 9
     parameter read_wgt_1 = 4'd9; // change ready in and trans to 0 to use bus ( for convolution matrix )
     parameter save_weight = 4'd2; // save the weight to B11 ~ B33.
     // cheack count_2 if saving the weight is done
     /////////////////////////////read image and do CNN ( whole calculation )//////////////////  loop2
     parameter read_im_0 = 4'd3; // try to read image data ( 4000_0000[j] ) j < 82*82
     parameter read_im_1 = 4'd10; // change ready in and trans to 0 to use bus ( for image data )
     parameter save_Atemp = 4'd4; // save the image data to A_temp
 
     parameter cal_m1 = 4'd11; // calculate 2D convolution & ReLU for matrix 1 ( with moving to read_im 0 )
     parameter cal_m2 = 4'd12; // calculate 2D convolution & ReLU for matrix 2 ( with moving to read_im 0 )
     parameter cal_m3 = 4'd13; // calculate 2D convolution & ReLU for matrix 3 ( with moving to read_im 0 )
     parameter cal_m4 = 4'd14; // calculate 2D convolution & ReLU for matrix 4 ( with moving to read_im 0 )

     parameter cal_max = 4'd15; // find max value from cal_m1-cal_m4 
     ///////////////////////////////write /////////////////////////////
     parameter wrt_0 = 4'd5; // write the data to activation_fpga ( 4002_0000[k] ), k < 1681 (41^2)
     parameter wrt_1 = 4'd6; // change ready in and trans to 0 to use bus ( do write )

     parameter check_0 = 4'd7; // check whether the count(img_matrix position) reaches 4*( 80*84 + 80 )
     // if not count doesn't end, go to read_im_0 ( loop 2 )
     /////////////////////// done
     parameter S_done = 4'd8; // end of the whole loop. get out finish = 1





always @(posedge clk) begin
    if ( !reset ) begin
        ADDR <= 0;
        READY_in <= 0;

        TRANS <= 0;
        BURST <= 0;
        hsize <= 0;
        
        SEL <= 0;
        PROT <= 0;

        HWRITE <= 0;
        WDATA <= 0;
               
        count <= 0;
    
        finish <= 0;
        state <= S0;
    end
    else begin
        case(state)
        S0: begin
            if ( start ) 
                state <= read_wgt_0;
             end

/////////////////////////////////////////////////////////////// loop 1
        read_wgt_0: begin 
            if ( READY_out == 1 ) begin
                ADDR <= 32'h4001_0000 + count_2;
                READY_in <= 1;

                TRANS <= 2'b10;
                BURST <= 0;
                hsize <= 3'b010;
                
                SEL <= 1;
                PROT <= 1;
                
                state <= read_wgt_1;                
            end
        end

        read_wgt_1: begin
            READY_in <= 0;
            TRANS <= 0;
            state <= save_weight;    
        end

        save_weight: begin 
            if ( READY_out == 1 ) begin
            
                READY_in <= 1;

                SEL <= 0;
                PROT <= 0;
                
                end
                if ( count_2 == 0) begin
                B_11 <= RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 4) begin
                B_12 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 8) begin
                B_13 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 12) begin
                B_21 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 16) begin
                B_22 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 20) begin
                B_23 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 24) begin
                B_31 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
                else if (count_2 == 28) begin
                B_32 <=RDATA[31:24];
                count_2 <= count_2 + 4;
                state <= read_wgt_0;
                end
               
                else if ( count_2 == 32 ) begin 
                    B_33 <=RDATA[31:24];
                    state <= read_im_0;
                end
  
        end

        
            
//////////////////////////////////////////////////// loop 2
        read_im_0: begin 
            if ( READY_out == 1 ) begin

                ADDR <= 32'h4000_0000 + count + count_3 + count_max;
                READY_in <= 1;

                TRANS <= 2'b10;                
                BURST <= 0;
                hsize <= 3'b010;

                SEL <= 1;
                PROT <= 1;
                
                state <= read_im_1;                
            end
        end
        read_im_1: begin
            READY_in <= 0;
            TRANS <= 0;
            state <= save_Atemp;
        end
        save_Atemp: begin 
                if ( READY_out == 1 ) begin
                    
                A_temp[12:5] <= RDATA[31:24];
                READY_in <= 1;

                SEL <= 0;
                PROT <= 0;

                end
                if ( count_max ==0 ) state <= cal_m1;
                else if (count_max ==4 ) state <= cal_m2;
                else if (count_max ==4*84 ) state <= cal_m3;    
                else if (count_max ==4*85 ) state <= cal_m4;                  
                
            end
        cal_m1 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=read_im_0;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=read_im_0;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 

                    state <=cal_m1;
                end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4;
                mul_1[7:0] <= mul_temp[19:12]; // ReLU completed
                mul_temp <=0;
                state <= read_im_0;


                end
            end
           end
           
          
        cal_m2 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=read_im_0;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=read_im_0;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=cal_m2;
                 end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4*84;
                mul_2[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= read_im_0;


                end
               end
              end
         cal_m3 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=read_im_0;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=read_im_0;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=cal_m3;
                  end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 4*85;
                mul_3[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= read_im_0;


                end
            end
        end
         cal_m4 : begin
           if ( READY_out == 1 ) begin
            if ( count_3 == 0) begin
                    count_3 <= count_3+ 4;
                    mul_temp <= mul_temp + A_temp*Bmul_11; 
                    
                    state <=read_im_0;

                end
                else if ( count_3 == 4) begin
                    count_3 <= count_3+ 4;
                     mul_temp <= mul_temp - A_temp*Bmul_12; 

                    state <=read_im_0;

                end
                else if ( count_3 == 8) begin
                    count_3 <= 4*84;
                     mul_temp <= mul_temp + A_temp*Bmul_13; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*84) begin
                    count_3 <= count_3+ 4;
                
                    mul_temp <= mul_temp - A_temp*Bmul_21; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*85) begin
                    count_3 <= count_3+ 4;

                     mul_temp <= mul_temp + A_temp*Bmul_22; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*86) begin
                    count_3 <= 4*168;
                    mul_temp <= mul_temp - A_temp*Bmul_23; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*168) begin
                    count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_31; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*169) begin
                count_3 <= count_3 +4;
                     mul_temp <= mul_temp - A_temp*Bmul_32; 

                    state <=read_im_0;

                end
                else if ( count_3 == 4*170) begin
                count_3 <= 400;
                    mul_temp <= mul_temp + A_temp*Bmul_33; 
                    state <=cal_m4;
                 end
                else if ( count_3 == 400) begin
                count_3 <=0;
                count_max <= 0;
                mul_4[7:0] <= mul_temp[19:12];
                mul_temp <=0;
                state <= cal_max;


                end
        end
    end

        cal_max : begin
            if ( READY_out == 1 ) begin
                if ( mul_1 >= mul_2 ) begin
                    if( mul_1>= mul_3) begin
                        if (mul_1 >= mul_4) begin
                        mul_write <= mul_1;
                        state <= wrt_0;
                     end
                        else begin // 4 > 1,2,3
                        mul_write <= mul_4;
                        state <= wrt_0;                        
                     end
                     end
                     else begin // mul_3 > 1,2
                        if (mul_3 >= mul_4) begin
                            mul_write <= mul_3;
                            state <= wrt_0;
                        end
                        else begin
                            mul_write <= mul_4;
                            state <= wrt_0;
                        end
                       end
                      end
               else begin // 2 >1
                    if( mul_2>= mul_3) begin
                     if (mul_2 >= mul_4) begin
                          mul_write <= mul_2;
                          state <= wrt_0;
                        end
                           else begin // 4 > 1,2,3
                           mul_write <= mul_4;
                           state <= wrt_0;                        
                         end
                        end
                                else begin // mul_3 > 1,2
                                   if (mul_3 >= mul_4) begin
                                        mul_write <= mul_3;
                                         state <= wrt_0;
                                         end
                                    else begin
                                       mul_write <= mul_4;
                                         state <= wrt_0;
                                     end
                                     end                    
               end
             end

          end 
        wrt_0: begin // write 
            if ( READY_out == 1 && RESP == 0 ) begin
                ADDR <= 32'h4002_0000 + count;
                READY_in <= 1;

                TRANS <= 2'b10;
                BURST <= 0;
                hsize <= 3'b010; 

                SEL <= 1;
                PROT <= 9;

                HWRITE <= 1;
                WDATA <= {mul,mul,mul,mul}; 

                state <= wrt_1;
            end
        end
        wrt_1: begin

            READY_in <= 0;

            TRANS <= 0;

            state <= check_0;
        end
        check_0: begin
            if ( READY_out == 0 && RESP == 0) begin

                READY_in <= 1;

                HWRITE <= 0;
                WDATA <= 0;
                
                SEL <= 0;
                PROT <= 0;
                
                if ( count >= 27200 ) begin // = 32'hfffc // 56448, 28224 , 4*1681=6724 // 27536-8
                    state <= S_done;
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
                    state <= read_im_0;
                end
            end
        end
        S_done: begin // out finish signal

            ADDR <= 0;
            READY_in <= 0;

            TRANS <= 0;
            BURST <= 0;
            hsize <= 0;

            SEL <= 0;
            PROT <= 0;

            HWRITE <= 0;
            WDATA <= 0;


            finish <= 1;
        end
        
        
        
        endcase
    end
end 

endmodule
