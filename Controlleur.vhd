LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Controlleur IS
    PORT(i_clk, i_reset, i_rebond:IN STD_LOGIC;
    i_x:IN STD_LOGIC_VECTOR(1 downto 0);
    i_MSTL, i_SSTL: OUT STD_LOGIC_VECTOR(2 downto 0);
    Selec :OUT STD_LOGIC_VECTOR(1 downto 0));
END Controlleur;

ARCHITECTURE rtl OF Controlleur IS
	SIGNAL stateY, nextStateY : STD_LOGIC_VECTOR(1 downto 0);

	COMPONENT enARdFF_2 IS
	PORT(
		i_resetBar	: IN	STD_LOGIC;
		i_d		: IN	STD_LOGIC;
		i_enable	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
    END COMPONENT;

BEGIN
    
    -- Updating the state with D registers
    y0:enARdFF_2
        PORT MAP(i_resetBar=>i_reset,
		i_d	=> (stateY(0) AND NOT(i_x(0))) OR (NOT(stateY(1)) AND stateY(0)) OR (i_x(0) AND i_x(1) AND NOT(stateY(1))),
		i_enable=>'1',
		i_clock	=> i_clk,
		o_q=>nextStateY(0));

    y1:enARdFF_2
        PORT MAP(i_resetBar=>i_reset,
		i_d	=> (stateY(1) AND NOT(i_x(0))) OR (stateY(0) AND i_x(0)) OR (stateY(0) AND stateY(1)),
		i_enable=>'1',
		i_clock	=> i_clk,
		o_q=>nextStateY(1));

    -- Outputs
        i_MSTL(0)<=NOT(stateY(1)) AND NOT(stateY(0));
        i_MSTL(1)<=NOT(stateY(1)) AND stateY(0);
        i_MSTL(2)<=stateY(1);

        i_SSTL(0)<=stateY(1) AND stateY(0);
        i_SSTL(1)<=NOT(stateY(0)) AND stateY(1);
        i_SSTL(2)<=NOT(stateY(1));

        Selec(1)<=stateY(1);
        Selec(0)<=stateY(1) XOR stateY(0);
    -- Update the state
        stateY<=nextStateY;

END rtl;

