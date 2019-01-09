`timescale 1ns/1ns
// 图像平滑 8 


`define SIGNAL_COMPONENT
`define GRAY
module rd_bin;




parameter v_size = 193;
parameter h_size = 211;
integer i, fp;

reg [23:0] miage_buffer [v_size * h_size - 1: 0];

reg reset;
reg clk;
reg done;

reg pixel_val;
reg [23:0] pixel_in;

wire wr_pixel;
wire rd_pixel;
wire [v_size * h_size - 1: 0] addr_pixel;
reg [31:0] pixel_out;
reg [31:0] minuend;
reg [31:0] subtrahend;

reg [23:0] cnt;

reg [32:0] pixel_out_r;
reg [32:0] pixel_out_rr;
reg [31:0] thresh;

initial begin 
   cnt = 0;
   reset = 1;
   clk = 0;
   $readmemh("../figureRGB", miage_buffer);
   fp=$fopen("../figureRGB3", "w");
   #1000;
   reset = 0;

end 

always #1 clk = ~clk;

reg [5:0] state; 

localparam S1 = 6'b000001,
           S2 = 6'b000010,
           S3 = 6'b000100,
           S4 = 6'b001000,
           S5 = 6'b010000,
           S6 = 6'b100000;

/*
pixel_0_0   pixel_0_1   pixel_0_2
pixel_1_0   pixel_1_1   pixel_1_2
pixel_2_0   pixel_2_1   pixel_2_2
*/

reg [23:0] pixel_0_0, pixel_0_1, pixel_0_2;
reg [23:0] pixel_1_0, pixel_1_1, pixel_1_2;
reg [23:0] pixel_2_0, pixel_2_1, pixel_2_2;

reg [15:0] v_cnt;
reg [15:0] h_cnt;

always @(posedge clk, posedge reset) begin 
   if(reset == 1'd1) begin 
      state <= S1;
      pixel_0_0 <= 24'd0; pixel_0_1 <= 24'd0; pixel_0_2 <= 24'd0;
      pixel_1_0 <= 24'd0; pixel_1_1 <= 24'd0; pixel_1_2 <= 24'd0;
      pixel_2_0 <= 24'd0; pixel_2_1 <= 24'd0; pixel_2_2 <= 24'd0;
      v_cnt <= 16'd0;
      h_cnt <= 16'd0;
      cnt <= 24'd0;
      
      minuend <= 32'd0;
      subtrahend <= 32'd0;
      pixel_out <= 32'd0;
      pixel_out_r <= 33'd0;
      pixel_out_rr <= 33'd0;
      
      thresh <= 32'd8;
      
   end 
   else begin 
      case(state)
         S1: begin 
            if(v_cnt == 16'd0) begin 
               if(h_cnt == 16'd0) begin 
                  pixel_0_0 <= 24'd0; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0                                       ;
                  pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= 24'd0; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
               end 
               else if(h_cnt == h_size - 1) begin 
                  pixel_0_0 <= 24'd0                                     ; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0;
                  pixel_1_0 <= miage_buffer[ v_cnt   *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  pixel_2_0 <= miage_buffer[(v_cnt+1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= 24'd0;
               end 
               else begin 
                  pixel_0_0 <= 24'd0                                       ; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0                                       ;
                  pixel_1_0 <= miage_buffer[v_cnt      *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
               end 
               
            end 
            else if(v_cnt == v_size -1) begin 
               if(h_cnt == 16'd0) begin 
                  pixel_0_0 <= 24'd0; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= 24'd0; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0                                       ;
               end 
               else if(h_cnt == h_size - 1) begin 
                  pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= 24'd0;
                  pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  pixel_2_0 <= 24'd0                                       ; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0;
               end 
               else begin 
                  pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= 24'd0                                       ; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0;
               end 
            end 
            else begin 
               if(h_cnt == 16'd0) begin 
                  pixel_0_0 <= 24'd0; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= 24'd0; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
               end 
               else if(h_cnt == h_size - 1) begin 
                  pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= 24'd0;
                  pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= 24'd0;
               end 
               else begin 
                  pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
               end 
            end 
            
            state <= S2;
            
         end 
         S2: begin 
            
            `ifdef SIGNAL_COMPONENT
               pixel_out_rr[32:22] <= pixel_0_0[23:16] + pixel_0_1[23:16] + pixel_0_2[23:16] + 
                                       pixel_1_0[23:16] +                    pixel_1_2[23:16] + 
                                       pixel_2_0[23:16] + pixel_2_1[23:16] + pixel_2_2[23:16];
                                    
               pixel_out_rr[21:11] <= pixel_0_0[15:8] + pixel_0_1[15:8] + pixel_0_2[15:8] + 
                                      pixel_1_0[15:8] +                   pixel_1_2[15:8] + 
                                      pixel_2_0[15:8] + pixel_2_1[15:8] + pixel_2_2[15:8];
               
               pixel_out_rr[10:0] <= pixel_0_0[7:0] + pixel_0_1[7:0] + pixel_0_2[7:0] + 
                                     pixel_1_0[7:0] +                  pixel_1_2[7:0] + 
                                     pixel_2_0[7:0] + pixel_2_1[7:0] + pixel_2_2[7:0];
            `else 
               pixel_out_rr <= pixel_0_0 + pixel_0_1 + pixel_0_2 + 
                               pixel_1_0 +             pixel_1_2 + 
                               pixel_2_0 + pixel_2_1 + pixel_2_2;
            `endif
            state <= S3; 
            
            //$display("#pixel_0_0:%8h pixel_0_1:%8h pixel_0_2:%8h pixel_1_:%8h pixel_1_2:%8h pixel_2_0:%8h pixel_2_1:%8h pixel_2_2:%8h", pixel_0_0, pixel_0_1, pixel_0_2, pixel_1_0, pixel_1_2, pixel_2_0, pixel_2_1, pixel_2_2);
            
         end 
         S3: begin 
            if(v_cnt == 16'd0) begin 
               if(h_cnt == 16'd0) begin 
                  //pixel_0_0 <= 24'd0; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0                                       ;
                  //pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= 24'd0; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 3) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/3;
                     end 
                     
                     if(pixel_out_rr[21:11] < 3) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/3;
                     end 
                     
                     if(pixel_out_rr[10:0] < 3) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/3;
                     end 
                  `else 
                     pixel_out_r <= pixel_out_rr/3;
                  `endif 
               end 
               else if(h_cnt == h_size - 1) begin 
                  //pixel_0_0 <= 24'd0                                     ; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0;
                  //pixel_1_0 <= miage_buffer[ v_cnt   *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  //pixel_2_0 <= miage_buffer[(v_cnt+1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= 24'd0;
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 3) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/3;
                     end 
                     
                     if(pixel_out_rr[21:11] < 3) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/3;
                     end 
                  
                     if(pixel_out_rr[10:0] < 3) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/3;
                     end 
                  `else    
                     pixel_out_r <= pixel_out_rr/3;
                  `endif 
               end 
               else begin 
                  //pixel_0_0 <= 24'd0                                       ; pixel_0_1 <= 24'd0                                   ; pixel_0_2 <= 24'd0                                       ;
                  //pixel_1_0 <= miage_buffer[v_cnt      *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 5) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/5;
                     end 
                     
                     if(pixel_out_rr[21:11] < 5) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/5;
                     end 
                     
                     if(pixel_out_rr[10:0] < 5) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/5;
                     end 
                  `else 
                     pixel_out_r <= pixel_out_rr/5;
                  `endif
               end 
               
            end 
            else if(v_cnt == v_size -1) begin 
               if(h_cnt == 16'd0) begin 
                  //pixel_0_0 <= 24'd0; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  //pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= 24'd0; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0                                       ;
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 3) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/3;
                     end 
                     
                     if(pixel_out_rr[21:11] < 3) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/3;
                     end 
                     
                     if(pixel_out_rr[10:0] < 3) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/3;
                     end 
                  `else 
                     pixel_out_r <= pixel_out_rr/3;
                  `endif
               end 
               else if(h_cnt == h_size - 1) begin 
                  //pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= 24'd0;
                  //pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  //pixel_2_0 <= 24'd0                                       ; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0;
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 3) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/3;
                     end 
                     
                     if(pixel_out_rr[21:11] < 3) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/3;
                     end 
                     
                     if(pixel_out_rr[10:0] < 3) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/3;
                     end 
                  `else 
                     pixel_out_r <= pixel_out_rr/3;
                  `endif 
               end 
               else begin 
                  //pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  //pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= 24'd0                                       ; pixel_2_1 <= 24'd0                                   ; pixel_2_2 <= 24'd0;
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 5) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/5;
                     end 
                     
                     if(pixel_out_rr[21:11] < 5) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/5;
                     end 
                     
                     if(pixel_out_rr[10:0] < 5) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/5;
                     end 
                  `else 
                     pixel_out_r <= pixel_out_rr/5;
                  `endif 
               end 
            end 
            else begin 
               if(h_cnt == 16'd0) begin 
                  //pixel_0_0 <= 24'd0; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  //pixel_1_0 <= 24'd0; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= 24'd0; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 5) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/5;
                     end 
                     
                     if(pixel_out_rr[21:11] < 5) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/5;
                     end 
                     
                     if(pixel_out_rr[10:0] < 5) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/5;
                     end 
                  `else
                     pixel_out_r <= pixel_out_rr/5;
                  `endif
               end 
               else if(h_cnt == h_size - 1) begin 
                  //pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= 24'd0;
                  //pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= 24'd0;
                  //pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= 24'd0;
                  
                  `ifdef SIGNAL_COMPONENT
                     if(pixel_out_rr[32:22] < 5) begin 
                        pixel_out_r[23:16] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[23:16] <= pixel_out_rr[32:22]/5;
                     end 
                     
                     if(pixel_out_rr[21:11] < 5) begin 
                        pixel_out_r[15:8] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[15:8] <= pixel_out_rr[21:11]/5;
                     end 
                     
                     if(pixel_out_rr[10:0] < 5) begin 
                        pixel_out_r[7:0] <= 11'd0;
                     end 
                     else begin 
                        pixel_out_r[7:0] <= pixel_out_rr[10:0]/5;
                     end 
                  `else
                     pixel_out_r <= pixel_out_rr/5;
                  `endif
                  
               end 
               else begin 
                  //pixel_0_0 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt - 1]; pixel_0_1 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt]; pixel_0_2 <= miage_buffer[(v_cnt - 1)*h_size + h_cnt + 1];
                  //pixel_1_0 <= miage_buffer[ v_cnt     *h_size + h_cnt - 1]; pixel_1_1 <= miage_buffer[ v_cnt     *h_size + h_cnt]; pixel_1_2 <= miage_buffer[ v_cnt     *h_size + h_cnt + 1];
                  //pixel_2_0 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt - 1]; pixel_2_1 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt]; pixel_2_2 <= miage_buffer[(v_cnt + 1)*h_size + h_cnt + 1];
                  `ifdef SIGNAL_COMPONENT
                     pixel_out_r[23:16] <= (pixel_out_rr[24:22] == 3'd0)? pixel_out_rr[32:25]:pixel_out_rr[32:25] + 1;
                     pixel_out_r[15:8 ] <= (pixel_out_rr[13:11] == 3'd0)? pixel_out_rr[21:14]:pixel_out_rr[21:15] + 1;
                     pixel_out_r[7:0  ] <= (pixel_out_rr[2:0]   == 3'd0)? pixel_out_rr[10:3 ]:pixel_out_rr[10:3 ] + 1;
                  `else 
                     pixel_out_r <= (pixel_out_rr[2:0] == 3'd0)?pixel_out_rr[31:3]:pixel_out_rr[31:3] + 1;
                  `endif 
               end 
            end 
            
            state <= S4; 
            
         end 
         S4: begin 
            
            if(pixel_1_1[23:16] > pixel_out_r[23:16]) begin 
               if((pixel_1_1[23:16] - pixel_out_r[23:16]) < thresh) begin 
                  pixel_out[23:16] <= pixel_1_1[23:16];
               end 
               else begin 
                  pixel_out[23:16] <= pixel_out_r[23:16];
               end 
            end 
            else begin 
               if((pixel_out_r[23:16] - pixel_1_1[23:16]) < thresh) begin 
                  pixel_out[23:16] <= pixel_1_1[23:16];
               end 
               else begin 
                  pixel_out[23:16] <= pixel_out_r[23:16];
               end 
            end 
            
            if(pixel_1_1[15:8] > pixel_out_r[15:8]) begin 
               if((pixel_1_1[15:8] - pixel_out_r[15:8]) < thresh) begin 
                  pixel_out[15:8] <= pixel_1_1[15:8];
               end 
               else begin 
                  pixel_out[15:8] <= pixel_out_r[15:8];
               end 
            end 
            else begin 
               if((pixel_out_r[15:8] - pixel_1_1[15:8]) < thresh) begin 
                  pixel_out[15:8] <= pixel_1_1[15:8];
               end 
               else begin 
                  pixel_out[15:8] <= pixel_out_r[15:8];
               end 
            end 
            
            if(pixel_1_1[7:0] > pixel_out_r[7:0]) begin 
               if((pixel_1_1[7:0] - pixel_out_r[7:0]) < thresh) begin 
                  pixel_out[7:0] <= pixel_1_1[7:0];
               end 
               else begin 
                  pixel_out[7:0] <= pixel_out_r[7:0];
               end 
            end 
            else begin 
               if((pixel_out_r[7:0] - pixel_1_1[7:0]) < thresh) begin 
                  pixel_out[7:0] <= pixel_1_1[7:0];
               end 
               else begin 
                  pixel_out[7:0] <= pixel_out_r[7:0];
               end 
            end 
            
            //pixel_out <= pixel_out_r/32'h10101;
            //pixel_out <= pixel_out_r;
            $display("#pixel_1_1:%8h pixel_out_r:%8h pixel_out_rr[32:22]:%8h pixel_out_rr[21:11]:%8h pixel_out_rr[10:0]:%8h", pixel_1_1, pixel_out_r, pixel_out_rr[32:22], pixel_out_rr[21:11], pixel_out_rr[10:0]);
            
            state <= S5; 
         end 
         S5: begin 
            if(v_cnt == v_size -1) begin 
               if(h_cnt == h_size - 1) begin 
                  state <= S6;
               end 
               else begin 
                  h_cnt <= h_cnt + 16'd1;
                  state <= S1;
               end 
            end 
            else begin 
               if(h_cnt == h_size - 1) begin 
                  v_cnt <= v_cnt + 16'd1;
                  h_cnt <= 16'd0;
                  state <= S1;
               end 
               else begin 
                  h_cnt <= h_cnt + 16'd1;
                  state <= S1;
               end 
            end 
            
            `ifdef GRAY
               $fdisplay(fp,"%02h", pixel_out[7:0]);
               $fdisplay(fp,"%02h", pixel_out[7:0]);
               $fdisplay(fp,"%02h", pixel_out[7:0]);
            `else 
               $fdisplay(fp,"%02h", pixel_out[23:16]);
               $fdisplay(fp,"%02h", pixel_out[15:8]);
               $fdisplay(fp,"%02h", pixel_out[7:0]);
            `endif
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$display("# pixel: %d R: %d G: %d B: %d", cnt, pixel_out[23:16], pixel_out[15:8], pixel_out[7:0]);
            $display("#pixel_out:%8h ", pixel_out);
            cnt <= cnt + 1;
            
         end 
         S6: begin 
            $fclose(fp);
            $stop;
         end 
         default: state <= S5;
      endcase
   end 
end 








endmodule 