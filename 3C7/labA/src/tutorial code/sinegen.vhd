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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity sinegen is
  port
  (
    clk   : in    std_logic;
    reset : in    std_logic;
    sel   : in    std_logic_vector(1 downto 0);
    sine  : out std_logic_vector(19 downto 0)
  );
end sinegen;

architecture kintex of sinegen is

  attribute syn_noprune : boolean;
  attribute syn_noprune of kintex : architecture is TRUE;
   COMPONENT sine_high
    PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_axis_phase_tvalid : IN STD_LOGIC;
      s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
    END COMPONENT;
    COMPONENT sine_mid
    PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_axis_phase_tvalid : IN STD_LOGIC;
      s_axis_phase_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
    END COMPONENT;   
    COMPONENT sine_low
    PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
    END COMPONENT;

  attribute syn_black_box : boolean;

  signal count    : std_logic_vector(9 downto 0) := (others => '0');
  signal sine_h   : std_logic_vector(19 downto 0);
  signal sine_m   : std_logic_vector(17 downto 0);
  signal sine_l   : std_logic_vector(15 downto 0);

  signal sine_h_dly            : std_logic_vector(19 downto 0);
  signal sine_m_plus_l         : std_logic_vector(19 downto 0);
  signal sine_h_minus_m_plus_l : std_logic_vector(20 downto 0); 
  -- Added by Douang
  signal s_axis_phase_tvalid, m_axis_data_tvalid    : std_logic;
  signal aclk, aresetn    : std_logic;
  signal aresetn_sig	: std_logic := '1';
  signal aresetn_sig_r, aresetn_sig_rr, aresetn_sig_rrr 	: std_logic;
  
  signal s_axis_phase_tdata_sine_high	: std_logic_vector(15 downto 0) := (others => '0');
  signal m_axis_data_tdata_sine_high    : std_logic_vector(23 downto 0) := (others => '0');
  signal s_axis_phase_tdata_sine_mid	: std_logic_vector(7 downto 0) := (others => '0');
  signal m_axis_data_tdata_sine_mid     : std_logic_vector(23 downto 0) := (others => '0');
  signal s_axis_phase_tdata_sine_low	: std_logic_vector(7 downto 0) := (others => '0');
  signal m_axis_data_tdata_sine_low     : std_logic_vector(15 downto 0) := (others => '0');
  
 
begin
    aclk <= clk;
    s_axis_phase_tvalid <= '1';
    m_axis_data_tvalid <= '1';
    aresetn <= aresetn_sig_rrr;
    
    s_axis_phase_tdata_sine_high(9 downto 0) <= count(9 downto 0);
    sine_h <= m_axis_data_tdata_sine_high(19 downto 0);
    s_axis_phase_tdata_sine_mid(7 downto 0) <= count(7 downto 0);
    sine_m <= m_axis_data_tdata_sine_mid(17 downto 0);
    s_axis_phase_tdata_sine_low(5 downto 0) <= count(5 downto 0);
    --sine_l <= m_axis_data_tdata_sine_low;

-- Added by Douang
----------------------------------------------------------------------------------------------------
-- Make synchronous active-low reset in clk clock domain for aresetn signal
-- Notice that the reset signal for all AXI4 IP is an active low signal and it has to be held low at 
-- least for two consecutive clock cycles
----------------------------------------------------------------------------------------------------

process (clk)			
begin
  if rising_edge(clk) then
	 aresetn_sig_r <= not reset;
	 aresetn_sig_rr <= aresetn_sig_r;
	 aresetn_sig_rrr <= aresetn_sig_rr;
  end if;
end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        count <= (others => '0');
        sine_h_minus_m_plus_l <= (others => '0');
        sine  <= (others => '0');
      else
        count <= count + 1;
        sine_h_dly <= sine_h;
        sine_m_plus_l <= (sine_m(17) & sine_m(17) & sine_m) +
                         (sine_l(15) & sine_l(15) & sine_l(15) & sine_l(15) & sine_l);
        sine_h_minus_m_plus_l <= (sine_h_dly(19) & sine_h_dly) - (sine_m_plus_l(19) & sine_m_plus_l);
        
        if (sel = "00") then
          sine <= (sine_l(15) & sine_l(15) & sine_l(15) & sine_l(15) & sine_l);
        elsif (sel = "01") then
          sine <= (sine_m(17) & sine_m(17) & sine_m);
        elsif (sel = "10") then
          sine <= sine_h;
        elsif (sel = "11") then
          sine <= sine_h_minus_m_plus_l(20 downto 1);
        end if;
      end if;
    end if;
  end process;
   
    U_SH : sine_high
    PORT MAP (
      aclk => aclk,
      aresetn => aresetn,
      s_axis_phase_tvalid => s_axis_phase_tvalid,
      s_axis_phase_tdata => s_axis_phase_tdata_sine_high,
      m_axis_data_tvalid => open,
      m_axis_data_tdata => m_axis_data_tdata_sine_high
    );
    U_SM : sine_mid
      PORT MAP (
        aclk => aclk,
        aresetn => aresetn,
        s_axis_phase_tvalid => s_axis_phase_tvalid,
        s_axis_phase_tdata => s_axis_phase_tdata_sine_mid,
        m_axis_data_tvalid => open,
        m_axis_data_tdata => m_axis_data_tdata_sine_mid
      );
    U_SL : sine_low
    PORT MAP (
      aclk => aclk,
      aresetn => aresetn,
      s_axis_phase_tvalid => s_axis_phase_tvalid,
      s_axis_phase_tdata => s_axis_phase_tdata_sine_low,
      m_axis_data_tvalid => open,
      m_axis_data_tdata => m_axis_data_tdata_sine_low
    );

end kintex;
