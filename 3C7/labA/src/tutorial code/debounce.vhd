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
--  Debounce circuit
-------------------------------------------------------------------
entity debounce is
  port
  (
    clk       : in  std_logic;
    button_in  : in  std_logic;
    button_db : out std_logic
  );
end entity;

architecture Mixed of debounce is
--  signal count : std_logic_vector (21 downto 0) := (others => '0');
  signal count : std_logic_vector (2 downto 0) := (others => '0');  
  constant all_ones : std_logic_vector (2 downto 0) := (others => '1');
begin

  REG:process(clk)
  begin	 
    if (rising_edge(clk)) then
      if (button_in = '1') then
        if (count /= all_ones) then
          count <= count + 1;
        end if;
      else
        count <= (others => '0');
      end if;
      if (count = all_ones) then
        button_db <= '1';
      else
        button_db <= '0';
      end if;
    end if;
  end process REG;
  
end architecture Mixed;
