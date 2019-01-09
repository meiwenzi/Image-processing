// 灰度直方图
// 2019-01-04 ycc 初始
// 
module histogram#(
   parameter V_SIZE,
   parameter H_SIZE

)(
   input clk,
   input reset,
   
   output reg rd_pixel,
   output reg [V_SIZE * H_SIZE - 1:0] addr_pixel,
   
   input pixel_val,
   input [23:0] pixel_in,
   
   output reg [V_SIZE * H_SIZE * 8 - 1:0] hist, 
   
   output reg done
);


localparam IMG_SIZE = V_SIZE * H_SIZE;

reg [2:0] state;

localparam RD_PIXEL = 3'b001;
localparam WR_PIXEL = 3'b010;
localparam DONE     = 3'b100;


integer i,j;

always @(posedge clk, posedge reset) begin 
   if(reset == 1'd1) begin 
      state <= RD_PIXEL;
      rd_pixel <= 1'd0;
      done <= 1'd0;
      addr_pixel <= 'd0;
      
      for(i=0;i<256;i=i+1) begin 
         hist[i] <= 8'h0;
         
      end 
   end 
   else begin 
      case(state)
         RD_PIXEL: begin
            rd_pixel <= 1'd1;
            state <= WR_PIXEL;
         end 
         WR_PIXEL: begin 
            rd_pixel <= 1'd0;
            
            if(pixel_val == 1'd1) begin 
               if(addr_pixel == (IMG_SIZE-1)) begin 
                  state <= DONE;
                  addr_pixel <= 'd0;
               end 
               else begin 
                  state <= RD_PIXEL;
                  addr_pixel <= addr_pixel + 'd1;
               end 
            end 
            
            if(pixel_val == 1'd1) begin 
               //pixel_out[23:16] <= pixel_in[23:16];
               //pixel_out[15:8] <= pixel_in[23:16];
               //pixel_out[7:0] <= pixel_in[23:16];
               //wr_pixel <= 1'd1;
               
               hist[pixel_in[23:16]] <= hist[pixel_in[23:16]] + 8'd1;
               //$display("%d gray number:%d", pixel_in[23:16], hist[pixel_in[23:16]] <= hist[pixel_in[23:16]] + 8'd1);
               
            end 
         
         end 
         DONE: begin 
            rd_pixel <= 1'd0;
            done <= 1'd1;
            addr_pixel <= 'd0;
            
            for(j=0;j<256;j=j+1)
               $display("%d gray number:%d", j, hist[j]);
         end 
         default:state <= DONE;
         
      endcase 
   end 
end 








endmodule 