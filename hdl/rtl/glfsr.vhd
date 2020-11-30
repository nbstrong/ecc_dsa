library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.ecc_dsa_pack.all;
--------------------------------------------------------------------------------
-- Galoi Linear Feedback Shift Register
-- Generates pseudo-random integers
-- n = 256, so must be able to generate between 1...[n-1]
-- This, 8 bits suffice
-- Source : http://emmanuel.pouly.free.fr/fibo.html
-- Taps Source: https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
--------------------------------------------------------------------------------
entity GLFSR is
    port (
        clkIn : in    std_logic;
        rstIn : in    std_logic;
        dOut  :   out std_logic_vector(m-1 downto 0));
end entity GLFSR;
--------------------------------------------------------------------------------
architecture rtl of GLFSR is
    signal   temp       : unsigned(dOut'range) := (0=>'1', others=>'0');
begin
    process (clkIn)
        variable lsb : std_logic;
        variable ext_inbit : unsigned(dOut'range);
    begin
        lsb := temp(0);
        for i in dOut'range loop
            ext_inbit(i) := lsb;
        end loop;

        if rising_edge(clkIn) then
            if (rstIn /= '0') then
                temp <= (0=>'1', others=>'0');
            else
                temp <= ('0' & temp(m-1 downto 1)) xor (ext_inbit and unsigned(f));
            end if;
        end if;
    end process;
    dOut <= std_logic_vector(temp);
end architecture rtl;