--------------------------------------------------------------
-- (C) Copyright 2010-2011 Xilinx, Inc. All Rights Reserved.
-- 
-- XILINX, the Xilinx logo, the Brand Window and other 
-- designated brands included herein are trademarks of Xilinx, 
-- Inc. All other trademarks are the property of their 
-- respective owners.
-- 
-- NOTICE OF DISCLAIMER: The information disclosed to you 
-- hereunder (the “Information”) is provided “AS-IS” with no 
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

-------------------------------------------------------------------
--  Finite state machine
-------------------------------------------------------------------
entity fsm is
  port
  (
    clk       : in  std_logic;
    reset     : in  std_logic;
    button    : in  std_logic;
    Y         : out std_logic_vector(1 downto 0)
  );
end entity;

architecture Mixed of fsm is
  type StateType is (Select_Sine_Low, Select_Sine_Mid, Select_Sine_High, Select_Sine_Combo);
  signal CUR_STATE:StateType;
  signal NEXT_STATE:StateType;
begin
  REG:process(clk)
  begin	 
    if (rising_edge(clk)) then
      if (reset = '1') then
        CUR_STATE <= Select_Sine_Low;
      else
        CUR_STATE <= NEXT_STATE;
      end if;
    end if;
  end process REG;
  
  COMB:process(button, CUR_STATE)	
  begin
    case (CUR_STATE) is
      when Select_Sine_Low =>
        Y <= "00";
        if (button = '1') then
          NEXT_STATE <= Select_Sine_Mid;
        else
          NEXT_STATE <= Select_Sine_Low;
        end if;
     when Select_Sine_Mid =>
        Y <= "01";
        if (button = '1') then
          NEXT_STATE <= Select_Sine_High;
        else
          NEXT_STATE <= Select_Sine_Mid;
        end if;
      when Select_Sine_High =>
        Y <= "10";
        if (button = '1') then
          NEXT_STATE <= Select_Sine_Combo;
        else
          NEXT_STATE <= Select_Sine_High;
        end if;
      when Select_Sine_Combo =>
        Y <= "11";
        if (button = '1') then
          NEXT_STATE <= Select_Sine_Low;
        else
          NEXT_STATE <= Select_Sine_Combo;
        end if;
    end case;
  end process COMB;
       
end architecture Mixed;
