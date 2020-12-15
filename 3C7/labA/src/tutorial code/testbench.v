`timescale 1ns/1ps

module testbench;
   reg sys_clk_p;
   wire sys_clk_n;
   reg reset;
   reg [1:0] gpio_buttons;
   reg 	     gpio_switch;
   wire [3:0] leds_n;
   
   // Clock gen
   initial begin
      sys_clk_p = 1'b0;
      forever sys_clk_p = #2.5 ~sys_clk_p;
   end
   // Differential clock
   assign sys_clk_n = ~sys_clk_p;
 
   // reset logic
   initial begin
      reset = 1'b1;
      #100 reset = 1'b0;
   end

   // Button & Switch Control logic
   initial begin
      gpio_buttons = 0;
      gpio_switch  = 0;
      @(negedge sys_clk_p);
      gpio_buttons = 2'b01;
      gpio_switch  = 1;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b10;
      gpio_switch  = 0;
      repeat(200) @(negedge sys_clk_p);
      gpio_buttons = 2'b10;
      gpio_switch  = 0;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b11;
      gpio_switch  = 1;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b11;
      gpio_switch  = 0;
      repeat(200) @(negedge sys_clk_p);
      gpio_buttons = 2'b00;
      gpio_switch  = 1;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b10;
      gpio_switch  = 1;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b10;
      gpio_switch  = 1;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b11;
      gpio_switch  = 0;
      repeat(200) @(negedge sys_clk_p);
      gpio_buttons = 2'b00;
      gpio_switch  = 0;
      repeat(100) @(negedge sys_clk_p);
      gpio_buttons = 2'b01;
      gpio_switch  = 0;
      repeat(100) @(negedge sys_clk_p);
      $finish;
   end

   // Monitor
   always @(*)
     $strobe("[@%0t] LEDS_n = %b", $time, leds_n);

   
   // DUT instantiation
   sinegen_demo dut (
		     .CLK_P        (sys_clk_p    ),
		     .CLK_N        (sys_clk_n    ),
		     .RESET        (reset        ),
		     .GPIO_BUTTONS (gpio_buttons ),
		     .GPIO_SWITCH  (gpio_switch  ),
		     .LEDS_n       (leds_n       )		     
		     );

endmodule // testbench
