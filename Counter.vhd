LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY counter IS
	PORT(
		i_resetBar, i_enable, i_load	: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_Value			: OUT	STD_LOGIC_VECTOR(3 downto 0));
END counter;

ARCHITECTURE rtl OF Counter IS
	SIGNAL int_a, int_b, int_c, int_d : STD_LOGIC;
   SIGNAL carry_a, carry_b, carry_c, carry_d : STD_LOGIC;

	COMPONENT oneBitAdder IS
        PORT(
            i_CarryIn		: IN	STD_LOGIC;
				i_clk: IN STD_LOGIC;
            i_Ai		: IN	STD_LOGIC;
            o_Sum, o_CarryOut	: OUT	STD_LOGIC);
    END COMPONENT;

BEGIN

part0: oneBitAdder
	PORT MAP (
            i_CarryIn=>i_enable,
				i_clk=>i_clock,
            i_Ai=>(('0' and i_load) OR (int_a and not(i_load)))AND (i_resetBar),
            o_Sum=>int_a,
            o_CarryOut=>carry_a);

part1: oneBitAdder
    PORT MAP (
            i_CarryIn=>carry_a,
				i_clk=>i_clock,
            i_Ai=>(('0' and i_load) OR (int_b and not(i_load)))AND (i_resetBar),
            o_Sum=>int_b,
            o_CarryOut=>carry_b);

part2: oneBitAdder
    PORT MAP (
            i_CarryIn=>carry_b,
				i_clk=>i_clock,
            i_Ai=>(('0' and i_load) OR (int_c and not(i_load)))AND (i_resetBar),
            o_Sum=>int_c,
            o_CarryOut=>carry_c);

part3: oneBitAdder
    PORT MAP (
            i_CarryIn=>carry_c,
				i_clk=>i_clock,
            i_Ai=>(('0' and i_load) OR (int_d and not(i_load)))AND (i_resetBar),
            o_Sum=>int_d,
            o_CarryOut=>carry_d);

	-- Output Driver
	o_Value(0)		<= int_a;
   o_Value(1)		<= int_b;
   o_Value(2)		<= int_c;
   o_Value(3)		<= int_d;

END rtl;
