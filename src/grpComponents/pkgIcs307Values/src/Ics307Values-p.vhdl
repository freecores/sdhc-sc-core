--
-- Title: Constants for Ics307Configurator
-- File: Ics307Values-p.vhdl
-- Author: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Ics307Values is
	constant cCrystalLoadCapacitance_C_48MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cReferenceDivider_RDW_48MHz : std_ulogic_vector(6 downto 0) := "0000011";
	constant cVcoDividerWord_VDW_48MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cOutputDutyCycleVoltage_TTL_48MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_48MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_48MHz : std_ulogic_vector(2 downto 0) := "100";

	constant cCrystalLoadCapacitance_C_25MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_25MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_25MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_25MHz : std_ulogic_vector(2 downto 0) := "000";
	constant cVcoDividerWord_VDW_25MHz : std_ulogic_vector(8 downto 0) := "000000111";
	constant cReferenceDivider_RDW_25MHz : std_ulogic_vector(6 downto 0) := "0000001";

	constant cCrystalLoadCapacitance_C_50MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_50MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_50MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_50MHz : std_ulogic_vector(2 downto 0) := "010";
	constant cVcoDividerWord_VDW_50MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cReferenceDivider_RDW_50MHz : std_ulogic_vector(6 downto 0) := "0000001";

	constant cCrystalLoadCapacitance_C_100MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_100MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_100MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_100MHz : std_ulogic_vector(2 downto 0) := "011";
	constant cVcoDividerWord_VDW_100MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cReferenceDivider_RDW_100MHz : std_ulogic_vector(6 downto 0) := "0000001";

end package Ics307Values;

