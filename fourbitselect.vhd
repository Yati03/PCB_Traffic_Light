LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fourbitselect IS
	PORT(
		MSTL, SSTL, SST, MST	: IN	STD_LOGIC_VECTOR(3 downto 0);
		sel		: IN	STD_LOGIC_VECTOR(1 downto 0);
      OUTPUT: OUT STD_LOGIC_VECTOR(3 downto 0));
END fourbitselect;

ARCHITECTURE behav OF fourbitselect is
BEGIN
	OUTPUT <= MSTL WHEN(sel(0)='0' and sel(1) = '0')
				ELSE MST WHEN (sel(0)='1' and sel(1) = '0')
				ELSE SSTL WHEN (sel(0)='0' and sel(1) = '1')
				ELSE SST;
END behav;