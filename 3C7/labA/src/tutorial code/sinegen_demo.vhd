--------------------------------------------------------------
-- (C) Copyright 2010-2011 Xilinx, Inc. All Rights Reserved.
-- 
-- XILINX, the Xilinx logo, the Brand Window and other 
-- designated brands included herein are trademarks of Xilinx, 
-- Inc. All other trademarks are the property of their 
-- respective owners.
-- 
-- NOTICE OF DISCLAIMER: The information disclosed to you 
-- hereunder (the �Information�) is provided �AS-IS� with no 
-- warranty of any kind, express or implied. Xilinx does not 
-- assume any liability arising from your use of the 
-- Information. You are responsible for obtaining any rights 
-- you may require for your use of this Information. Xilinx 
-- reserves the right to make changes, at any time, to the 
-- Information without notice and at its sole discretion. 
-- Xilinx assumes no obligation to correct any errors contained 
-- in the Information or to advise you of any corrections or 
-- updates. Xilinx expressly disclaims any liability in 
-- connection with technical support or assistance that may be 
-- provided to you in connection with the Information. XILINX 
-- MAKES NO OTHER WARRANTIES, WHETHER EXPRESS, IMPLIED, OR 
-- STATUTORY, REGARDING THE INFORMATION, INCLUDING ANY 
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE, OR NONINFRINGEMENT OF THIRD-PARTY RIGHTS.
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity sinegen_demo is
  port
  (
    CLK_P         : in  std_logic;
    CLK_N         : in  std_logic;
    RESET         : in  std_logic;
    GPIO_BUTTONS  : in  std_logic_vector(1 downto 0);
    GPIO_SWITCH   : in  std_logic;
    LEDS_n        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture Mixed of sinegen_demo is
  signal clk,clk_ibufgds              : std_logic;
  signal sine                         : std_logic_vector(19 downto 0);
  signal sineSel                      : std_logic_vector(1 downto 0);

  signal GPIO_BUTTONS_db              : std_logic_vector(1 downto 0);
  signal GPIO_BUTTONS_dly             : std_logic_vector(1 downto 0);
  signal GPIO_BUTTONS_re              : std_logic_vector(1 downto 0);

  signal DONT_EAT0                    : std_logic;
  signal DONT_EAT1                    : std_logic;
  signal DONT_EAT2                    : std_logic;
  signal DONT_EAT3                    : std_logic;
  signal DONT_EAT4                    : std_logic;
  signal DONT_EAT                     : std_logic ;
  attribute mark_debug : string;
  attribute keep : string;
  attribute mark_debug of GPIO_BUTTONS_db   : signal is "true";
  attribute mark_debug of GPIO_BUTTONS_dly  : signal is "true";
  attribute mark_debug of GPIO_BUTTONS_re   : signal is "true";
  component sinegen
    port
    (
      clk   : in    std_logic;
      reset : in    std_logic;
      sel   : in    std_logic_vector(1 downto 0);
      sine  : out   std_logic_vector(19 downto 0)
    );
  end component;

  component fsm is
    port
    (
      clk       : in  std_logic;
      reset     : in  std_logic;
      button    : in  std_logic;
      Y         : out std_logic_vector(1 downto 0)
    );
  end component;
  
  component debounce is
  port
  (
    clk       : in  std_logic;
    button_in : in  std_logic;
    button_db : out std_logic
  );
  end component;

begin

  ------------------------------------------------------------
  --  Differential clock buffer
  ------------------------------------------------------------
    U_IBUFGDS : ibufgds
    generic map 
    (
    IOSTANDARD => "LVDS"
    )
    port map 
    (   
    O => clk_ibufgds, 
    I => CLK_P,
    IB => CLK_N
    );
    U_BUFG : bufg
    port map 
    (   
    O => clk, 
    I => clk_ibufgds
    );

  ------------------------------------------------------------
  --  Buttons and debouncers
  ------------------------------------------------------------
  U_DEBOUNCE_0 : debounce 
    port map
    (
      clk       => clk,
      button_in => GPIO_BUTTONS(0),
      button_db => GPIO_BUTTONS_db(0)
    ); 

  U_DEBOUNCE_1 : debounce
    port map
    (
      clk       => clk,
      button_in => GPIO_BUTTONS(1),
      button_db => GPIO_BUTTONS_db(1)
    ); 

  -- Rising edge logic for the buttons
  process (clk)
  begin
    if (rising_edge(clk)) then
      if (GPIO_SWITCH = '1') then
        GPIO_BUTTONS_dly(0) <= GPIO_BUTTONS_db(0);
        GPIO_BUTTONS_re(0)  <= not GPIO_BUTTONS_db(0) and GPIO_BUTTONS_dly(0);
        GPIO_BUTTONS_dly(1) <= GPIO_BUTTONS_db(1);
        GPIO_BUTTONS_re(1)  <= not GPIO_BUTTONS_db(1) and GPIO_BUTTONS_dly(1);
      else
        GPIO_BUTTONS_dly(0) <= GPIO_BUTTONS(0);
        GPIO_BUTTONS_re(0)  <= not GPIO_BUTTONS(0) and GPIO_BUTTONS_dly(0);
        GPIO_BUTTONS_dly(1) <= GPIO_BUTTONS(1);
        GPIO_BUTTONS_re(1)  <= not GPIO_BUTTONS(1) and GPIO_BUTTONS_dly(1);
      end if;
    end if;
  end process;
    
  ------------------------------------------------------------
  --  Sine generator
  ------------------------------------------------------------
  U_SINEGEN : sinegen
    port map
    (
      clk   => clk,
--      reset => GPIO_BUTTONS_re(0),
      reset => reset,      
      sel   => sineSel,
      sine  => sine
    ); 
    
  ------------------------------------------------------------
  --  Finite state machine
  ------------------------------------------------------------
  U_FSM : fsm
    port map
    (
      clk    => clk,
--      reset   => GPIO_BUTTONS_re(0),
      reset => reset,            
      button  => GPIO_BUTTONS_re(1),
      Y       => sineSel
    ); 
    
  ------------------------------------------------------------
  --  LEDs
  ------------------------------------------------------------
  LEDS_n(0)   <= sineSel(0);
  LEDS_n(1)   <= sineSel(1);
  LEDS_n(2)   <= GPIO_BUTTONS_re(1);
  LEDS_n(3)   <= DONT_EAT;
 
  
  -- Dummy logic to keep XST from eating the design
  process (clk)
  begin
    if (rising_edge(clk)) then
      DONT_EAT4 <= sine(16) and sine(17) and sine(18) and sine(19);
      DONT_EAT3 <= sine(15) and sine(14) and sine(13) and sine(12);
      DONT_EAT2 <= sine(11) and sine(10) and sine(9) and sine(8);
      DONT_EAT1 <= sine(7) and sine(6) and sine(5) and sine(4);
      DONT_EAT0 <= sine(3) and sine(2) and sine(1) and sine(0);
      DONT_EAT  <= DONT_EAT4 and DONT_EAT3 and DONT_EAT2 and DONT_EAT1 and DONT_EAT0; 
    end if;
  end process;

end Mixed;
