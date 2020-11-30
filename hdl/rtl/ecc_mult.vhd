library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.ecc_dsa_pack.all;
--------------------------------------------------------------------------------
-- Binary Method of ECC Multiplication
-- Implements algorithm 3 defined in
-- https://pdfs.semanticscholar.org/90df/43ffed22bd7f7bd1a1bfc6f866e5cfd0246f.pdf
--------------------------------------------------------------------------------
entity ecc_mult is
    port (
        clkIn   : in    std_logic;
        rstIn   : in    std_logic;
        enIn    : in    std_logic;
        xIn     : in    std_logic_vector(m-1 downto 0);
        yIn     : in    std_logic_vector(m-1 downto 0);
        kIn     : in    std_logic_vector(m-1 downto 0);
        doneOut :   out std_logic_vector(m-1 downto 0);
        xOut    :   out std_logic_vector(m-1 downto 0);
        yOut    :   out std_logic_vector(m-1 downto 0));
end entity ecc_mult;
--------------------------------------------------------------------------------
architecture rtl of ecc_mult is
    signal   en : std_logic;
    variable k  : unsigned(m-1 downto 0);
    variable i  : integer;
    variable R  : unsigned(m*2-1 downto 0);
    variable S  : unsigned(m*2-1 downto 0);
begin
    process (clkIn)
    begin
        if rising_edge(clkIn) then
            if (rstIn /= '0') then
                doneOut <= 0;
                en <= 0;
                i := 0;
            elsif (en = '1') then
                if (i = (m)) then
                    en <= 0;
                    doneOut <= 1;
                else
                    if (k(i) = 1) then
                        if (R = X"0") then
                            R := S;
                        else
                            R := R + S;
                        end if;
                    end if;
                    S := 2 * S;
                    i := i + 1;
            elsif (enIn = '1') then
                en <= '1';
                k := kIn;
                i := 0;
                R := (others => '0');
                S := unsigned(xIn) & unsigned(yIn);
            end if;
        end if;
    end process;
    xOut <= std_logic_vector(R(R'left downto m+1));
    yOut <= std_logic_vector(R(m-1 downto 0));
end architecture rtl;