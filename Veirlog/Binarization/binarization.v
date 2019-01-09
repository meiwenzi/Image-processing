// 二值化
// 2019-01-01 ycc 初始
// 
module binarization#(
   parameter V_SIZE,
   parameter H_SIZE
)(
   input clk,
   input reset,
   
   output reg rd_pixel,
   output reg [V_SIZE * H_SIZE - 1:0] addr_pixel,
   
   input pixel_val,
   input [23:0] pixel_in,
   
   input [23:0] threshold,
   input [23:0] color_0,
   input [23:0] color_1,
   
   output reg wr_pixel,
   output reg [23:0] pixel_out,
   
   output reg done
);


localparam IMG_SIZE = V_SIZE * H_SIZE;

reg [2:0] state;

localparam RD_PIXEL = 3'b001;
localparam WR_PIXEL = 3'b010;
localparam DONE     = 3'b100;


always @(posedge clk, posedge reset) begin 
   if(reset == 1'd1) begin 
      state <= RD_PIXEL;
      rd_pixel <= 1'd0;
      done <= 1'd0;
      addr_pixel <= 'd0;
      pixel_out <= 24'd0;
   end 
   else begin 
      case(state)
         RD_PIXEL: begin
            rd_pixel <= 1'd1;
            wr_pixel <= 1'd0;
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
               if(pixel_in < threshold) begin 
                  pixel_out <= color_0;
               end 
               else begin 
                  pixel_out <= color_1;
               end 
               wr_pixel <= 1'd1;
            end 
         
         end 
         DONE: begin 
            wr_pixel <= 1'd0;
            rd_pixel <= 1'd0;
            done <= 1'd1;
            addr_pixel <= 'd0;
         end 
         default:state <= DONE;
         
      endcase 
   end 
end 








endmodule 