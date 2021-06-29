`timescale 1ns/ 1ps

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--library std;
--use std.env.all;

library work;
use work.all;

entity tb is 
end tb;

architecture behavior of tb is
    signal isys_clk: std_logic := '0';
    signal istart: std_logic := '0';
    signal itick: std_logic := '0';
begin
    isys_clk <= not isys_clk after 5ns;
    istart <= '1' after 300ns, '0' after 350ns;

    process
    begin
        for i in 1 to 10 loop
            wait for 50ns;
            itick <= '1';
            wait for 50ns;
            itick <= '0';
        end loop;
        -- stop(1);
    end process;

    dut: entity work.top(struct)
    port map (
        isys_clk    	=> isys_clk,
    
        istart      	=> istart,
        itick       	=> itick,
        
        ovga_hs     	=> open,
        ovga_vs   	=> open,
        R   			=> open,
        G   			=> open,
        B   			=> open
    );
end behavior;