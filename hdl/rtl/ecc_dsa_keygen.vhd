library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.ecc_dsa_pack.all;

entity ecc_dsa_keygen is
    port (
        clkIn   : in    std_logic;
        rstIn   : in    std_logic;
        enIn    : in    std_logic;
        statOut :   out std_logic;
        dOut    :   out std_logic_vector(m-1 downto 0);
        qOut    :   out std_logic_vector(m-1 downto 0));
end entity ecc_dsa_keygen;
--------------------------------------------------------------------------------
architecture rtl of ecc_dsa_keygen is
    signal rand : std_logic_vector(m-1 downto 0);
    signal rand_unsign : unsigned(rand'range);
    signal en : std_logic;
    signal Qx : std_logic_vector(m-1 downto 0);
    signal Qy : std_logic_vector(m-1 downto 0);
    variable d : unsigned(dOut'range);
    variable q : unsigned(qOut'range);
begin

    -- TODO: Calculate N=len(n)
    -- TODO: Check security strength of random number
    -- TODO: Generate N+64 for random number according to NIST guidelines
    ----------------------------------------------------------------------------
    -- GLFSR
    ----------------------------------------------------------------------------
    glfsr_ent : entity work.GLFSR(rtl)
        port map (
            clkIn => clkIn,
            rstIn => rstIn,
            dOut  => rand);

    rand_unsign <= unsigned(rand);

    key_gen_proc : process (clkIn)
    begin
        if rising_edge(clkIn) then
            if (rstIn /= '0' or enIn = '0') then
                en <= '0';
                d := (others=>'0');
                q := (others=>'0');
            elsif (enIn = '1') then
                en <= '1';
                d := (rand_unsign mod (m-1)) + 1;
                dOut <= std_logic_vector(d);
            end if;
        end if;
    end process key_gen_proc;

    ecc_mult_ent : entity work.ecc_mult(rtl)
        port map (
            clkIn   => clkIn,
            rstIn   => rstIn,
            enIn    => en,
            xIn     => Gx,
            yIn     => Gy,
            kIn     => std_logic_vector(d),
            doneOut => statOut,
            xOut    => Qx,
            yOut    => Qy);

    qOut <= Qx & Qy;

end architecture rtl;