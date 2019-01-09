`timescale 1ns/1ns

`define GRAY

//`define GRAY_ALGORITHMS_1 // 

`define GRAY_ALGORITHMS_2 // 

module rd_bin;

parameter v_size = 512;
parameter h_size = 512;
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
reg [33:0] subtrahend;

reg [23:0] cnt;

reg [31:0] pixel_out_r;

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
      subtrahend <= 33'd0;
      pixel_out <= 32'd0;
      pixel_out_r <= 32'd0;
      
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
            //pixel_out <= pixel_1_1 * 5 - pixel_0_1 - pixel_1_0 - pixel_2_1 - pixel_1_2;
            
            //$display("#subtrahend:%8h  minuend:%8h", subtrahend, minuend);
            
            minuend[29:20]    <= pixel_0_1[23:16] + pixel_1_0[23:16] + pixel_2_1[23:16] + pixel_1_2[23:16];
            minuend[19:10]    <= pixel_0_1[15: 8] + pixel_1_0[15: 8] + pixel_2_1[15:8 ] + pixel_1_2[15: 8];
            minuend[ 9: 0]    <= pixel_0_1[7 : 0] + pixel_1_0[7 : 0] + pixel_2_1[7 : 0] + pixel_1_2[7 : 0];
            
            subtrahend[32:22] <= {pixel_1_1[23:16], 2'd0} + pixel_1_1[23:16];
            subtrahend[21:11] <= {pixel_1_1[15: 8], 2'd0} + pixel_1_1[15: 8];
            subtrahend[10: 0] <= {pixel_1_1[7 : 0], 2'd0} + pixel_1_1[7 : 0];
            
            
            //minuend    <= pixel_0_1 + pixel_1_0 + pixel_2_1 + pixel_1_2;
            //subtrahend <= {pixel_1_1, 2'd0} + pixel_1_1;
            
            //$display("#minuend[29:20]:%8h minuend[19:10]:%8h minuend[9:0]:%8h", minuend[29:20], minuend[19:10], minuend[9:0]);
            //$display("#subtrahend[29:20]:%8h subtrahend[19:10]:%8h subtrahend[9:0]:%8h", subtrahend[29:20], subtrahend[19:10], subtrahend[9:0]);
            state <= S3; 
            
         end 
         S3: begin 
            //if(subtrahend < minuend) begin 
            //   pixel_out_r <= 32'd0;
            //end 
            //else if(subtrahend > (minuend + 24'hffffff)) begin 
            //   pixel_out_r <= 24'hffffff;
            //end 
            //else begin 
            //   //pixel_out <= (subtrahend - minuend) / 16'hffff; //24‘hffffff/8'hff
            //   //pixel_out <= subtrahend - minuend;
            //   
            //   pixel_out_r <= subtrahend - minuend;
            //   
            //end 
            
            if(subtrahend[32:22] < minuend[29:20]) begin 
               pixel_out_r[23:16] <= 10'd0;
            end 
            else if(subtrahend[32:22] > (minuend[29:20] + 8'hff)) begin 
               pixel_out_r[23:16] <= 8'hff;
            end 
            else begin 
               //pixel_out <= (subtrahend - minuend) / 16'hffff; //24‘hffffff/8'hff
               //pixel_out <= subtrahend - minuend;
               
               pixel_out_r[23:16] <= subtrahend[32:22] - minuend[29:20];
               
            end 
            
            if(subtrahend[21:11] < minuend[19:10]) begin 
               pixel_out_r[15:8] <= 8'd0;
            end 
            else if(subtrahend[21:11] > (minuend[19:10] + 8'hff)) begin 
               pixel_out_r[15:8] <= 8'hff;
            end 
            else begin 
               //pixel_out <= (subtrahend - minuend) / 16'hffff; //24‘hffffff/8'hff
               //pixel_out <= subtrahend - minuend;
               
               pixel_out_r[15:8] <= subtrahend[21:11] - minuend[19:10];
               
            end 
            
            if(subtrahend[10: 0] < minuend[9:0]) begin 
               pixel_out_r[7:0] <= 32'd0;
            end 
            else if(subtrahend[10: 0] > (minuend[9:0] + 8'hff)) begin 
               pixel_out_r[7:0] <= 8'hff;
            end 
            else begin 
               //pixel_out <= (subtrahend - minuend) / 16'hffff; //24‘hffffff/8'hff
               //pixel_out <= subtrahend - minuend;
               
               pixel_out_r[7:0] <= subtrahend[10: 0] - minuend[9:0];
               
            end 
            
            //$display("#subtrahend:%8h  minuend:%8h", subtrahend, minuend);
            
            $display("#minuend[29:20]:%8h minuend[19:10]:%8h minuend[9:0]:%8h", minuend[29:20], minuend[19:10], minuend[9:0]);
            $display("#subtrahend[29:20]:%8h subtrahend[19:10]:%8h subtrahend[9:0]:%8h", subtrahend[29:20], subtrahend[19:10], subtrahend[9:0]);
            
            
            state <= S4; 
            
         end 
         S4: begin 
            //pixel_out <= pixel_out_r[23:16] * 19595 + pixel_out_r[15:8] * 38470 + pixel_out_r[7:0] * 7471; //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536state <= S4; 
            //pixel_out <= pixel_out_r / 32'h10101;
            //pixel_out <= pixel_out_r;
            `ifdef GRAY
               `ifdef GRAY_ALGORITHMS_1
                  pixel_out <= pixel_out_r / 32'h10101;
               `elsif GRAY_ALGORITHMS_2
                  pixel_out <= pixel_out_r[23:16] * 19595 + pixel_out_r[15:8] * 38470 + pixel_out_r[7:0] * 7471;
               `endif 
            `else 
               pixel_out <= pixel_out_r;
            `endif 
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
               `ifdef GRAY_ALGORITHMS_1
                  $fdisplay(fp,"%02h", pixel_out[7:0]);
                  $fdisplay(fp,"%02h", pixel_out[7:0]);
                  $fdisplay(fp,"%02h", pixel_out[7:0]);
               `elsif GRAY_ALGORITHMS_2
                  $fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
                  $fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
                  $fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
               `endif 
            `else 
               $fdisplay(fp,"%02h", pixel_out[23:16]);
               $fdisplay(fp,"%02h", pixel_out[15:8]);
               $fdisplay(fp,"%02h", pixel_out[7:0]);
            `endif 
            
            
            //$fdisplay(fp,"%02h", pixel_out[7:0]);
            //$fdisplay(fp,"%02h", pixel_out[7:0]);
            //$fdisplay(fp,"%02h", pixel_out[7:0]);
            //$fdisplay(fp,"%02h", pixel_out[23:16]);
            //$fdisplay(fp,"%02h", pixel_out[15:8]);
            //$fdisplay(fp,"%02h", pixel_out[7:0]);
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$fdisplay(fp,"%02h", pixel_out[23:16]); //Gray = 0.299 * red + 0.587 * green + 0.114 * blue; * 65536
            //$display("# pixel: %d R: %d G: %d B: %d", cnt, pixel_out[23:16], pixel_out[15:8], pixel_out[7:0]);
            $display("#pixel_out_r:%8h  pixel_out:%8h", pixel_out_r, pixel_out);
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