LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY System IS
    PORT(clock, reset :IN STD_LOGIC;
        SSCS:IN STD_LOGIC;
        MSC, SSC:IN STD_LOGIC_VECTOR(3 downto 0);
        MSTL, SSTL:OUT STD_LOGIC_VECTOR(2 downto 0));
		  
	END System;


ARCHITECTURE rtl OF System IS

    SIGNAL s_clkM, s_clk100K, s_clk10K, s_clk1K, s_clk100, s_clk10, s_clk1: STD_LOGIC; --The different times options from the divideur
    SIGNAL enablerT: STD_LOGIC; --Clean signal from the debouncer
    SIGNAL current_SS, current_MS, current_SST, current_MST:STD_LOGIC_VECTOR(3 downto 0); --Values after update within the counters
    SIGNAL comp1, comp2:STD_LOGIC_VECTOR(3 downto 0); --Values for the Comparateur
    SIGNAL sel_comp:STD_LOGIC_VECTOR(1 downto 0); --Selector values for Comparateur
    SIGNAL EQ, GT, LT:STD_LOGIC; --Outputs of the comparator

	COMPONENT Controlleur IS
    PORT(i_clk, i_reset, i_rebond:IN STD_LOGIC;
        i_x:IN STD_LOGIC_VECTOR(1 downto 0);
        i_MSTL, i_SSTL: OUT STD_LOGIC_VECTOR(2 downto 0);
        Selec:OUT STD_LOGIC_VECTOR(1 downto 0));
    END COMPONENT;

    COMPONENT Counter IS
	PORT(
		i_resetBar, i_enable, i_load	: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_Value			: OUT	STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;

    COMPONENT fourbitselect IS
	PORT(
		MSTL, SSTL, SST, MST	: IN	STD_LOGIC_VECTOR(3 downto 0);
		sel		: IN	STD_LOGIC_VECTOR(1 downto 0);
        OUTPUT: OUT STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;

    COMPONENT clk_div IS
	PORT(
		clock_25Mhz				: IN	STD_LOGIC;
		clock_1MHz				: OUT	STD_LOGIC;
		clock_100KHz			: OUT	STD_LOGIC;
		clock_10KHz				: OUT	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC;
		clock_100Hz				: OUT	STD_LOGIC;
		clock_10Hz				: OUT	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC);
	END COMPONENT;

    COMPONENT debouncer IS
	PORT(
		i_raw			: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_clean			: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT fourbitcomparator IS
	PORT(
		i_Ai, i_Bi			: IN	STD_LOGIC_VECTOR(3 downto 0);
		o_GT, o_LT, o_EQ		: OUT	STD_LOGIC);
    END COMPONENT;
BEGIN
        div_clk: clk_div
            PORT MAP(clock_25Mhz=>clock,
		    clock_1MHz=>s_clkM,
		    clock_100KHz=>s_clk100K,
		    clock_10KHz=>s_clk10K,
		    clock_1KHz=>s_clk1K,
		    clock_100Hz=>s_clk100,
		    clock_10Hz=>s_clk10,
		    clock_1Hz=>s_clk1);
        
        bouncer: debouncer
            PORT MAP(i_raw=>SSCS,
            i_clock=>s_clkM,
            o_clean=>enablerT);

        count_SS: Counter
            PORT MAP(i_resetBar=>reset AND NOT(sel_comp(0)) AND sel_comp(1),
            i_enable=>NOT(sel_comp(0)) AND sel_comp(1),
				i_load=>NOT(MSC(3) OR MSC(2) OR MSC(1) OR MSC(0)),
            i_clock=>s_clk100K,
            o_Value=>current_SS);

        count_MS: Counter
            PORT MAP(i_resetBar=>reset AND NOT(sel_comp(0)) AND NOT(sel_comp(1)),
            i_enable=>NOT(sel_comp(0)) AND NOT(sel_comp(1)),
				i_load=>NOT(MSC(3) OR MSC(2) OR MSC(1) OR MSC(0)),
            i_clock=>s_clk100K,
            o_Value=>current_MS);
				
		 count_MST: Counter
            PORT MAP(i_resetBar=>reset AND sel_comp(0) AND NOT(sel_comp(1)),
            i_enable=>sel_comp(0) AND NOT(sel_comp(1)),
				i_load=>NOT(MSC(3) OR MSC(2) OR MSC(1) OR MSC(0)),
            i_clock=>s_clk100K,
            o_Value=>current_MST);
    
        count_SST: Counter
            PORT MAP(i_resetBar=>reset AND sel_comp(0) AND sel_comp(1),
            i_enable=>sel_comp(0) AND sel_comp(1),
				i_load=>NOT(MSC(3) OR MSC(2) OR MSC(1) OR MSC(0)),
            i_clock=>s_clk100K,
            o_Value=>current_SST);
        
        select1:fourbitselect
            PORT MAP(MSTL=>current_MS,
            SSTL=>current_SS,
            SST=>current_SST,
            MST=>current_MST,
            sel=> sel_comp,
            OUTPUT=>comp1);

        select2:fourbitselect
            PORT MAP(MSTL=>MSC,
            SSTL=>SSC,
            SST=>"0011", --3 secondes
            MST=>"0100", --4 secondes
            sel=> sel_comp,
            OUTPUT=>comp2);
        
        comparateur:fourbitcomparator
            PORT MAP(i_Ai=>comp1,
            i_Bi=>comp2,
            o_GT=>GT,
            o_LT=>LT,
            o_EQ=>EQ);
        
        control:Controlleur
            PORT MAP(i_clk=>s_clk100K,
            i_reset=>reset,
            i_rebond=>enablerT,
            i_x(1)=>enablerT,
            i_x(0)=>EQ OR GT,
            i_MSTL=>MSTL,
            i_SSTL=>SSTL,
            Selec=>sel_comp);

    END rtl;