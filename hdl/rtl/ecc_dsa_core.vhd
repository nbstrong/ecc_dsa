library IEEE;
use IEEE.std_logic_1164.all;
--------------------------------------------------------------------------------
-- Implements Elliptic Curve Digital Signature Algorithm
-- Chosen Domain Variables based on recommendations in FIPS-186
-- P-256
-- p = 115792089210356248762697446949407573530086143415290314195533631308867097853951
-- n = 115792089210356248762697446949407573529996955224135760342422259061068512044369
-- SEED = c49d3608 86e70493 6a6678e1 139d26b7 819f7e90
-- c    = 7efba166 2985be94 03cb055c 75d4f7e0 ce8d84a9 c5114abc af317768 0104fa0d
-- b    = 5ac635d8 aa3a93e7 b3ebbd55 769886bc 651d06b0 cc53b0f6 3bce3c3e 27d2604b
-- Gx   = 6b17d1f2 e12c4247 f8bce6e5 63a440f2 77037d81 2deb33a0 f4a13945 d898c296
-- Gy   = 4fe342e2 fe1a7f9b 8ee7eb4a 7c0f9e16 2bce3357 6b315ece cbb64068 37bf51f5
-- q    = Field Size -
-- FR   = indication of basis used -
-- a    = field element in curve definition -
-- b    = field element in curve definition -
-- seed = domain parameter seed -
-- G    = (Xg,Yg) base point of prime order on curve -
-- n    = order of G
-- h    = cofactor
--------------------------------------------------------------------------------
entity ecc_dsa is
    port (
        clkIn : in    std_logic;
        rstIn : in    std_logic
    );
end ecc_dsa;
--------------------------------------------------------------------------------
architecture rtl of ecc_dsa is
    -- CONSTANTS ---------------------------------------------------------------
    constant L : integer := 256;
    constant p : std_logic_vector(L-1 downto 0) := X"ffffffff00000001000000000000000000000000ffffffffffffffffffffffff";
    constant n : std_logic_vector(L-1 downto 0) := X"ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551";
    constant FR : std_logic_vector() := X"";
    -- SIGNALS -----------------------------------------------------------------
    -- ALIASES -----------------------------------------------------------------
    -- ATTRIBUTES --------------------------------------------------------------
begin

    ----------------------------------------------------------------------------
    -- GLFSR
    ----------------------------------------------------------------------------
    glfsr_ent : entity work.GLFSR(rtl)
        port map (
            clkIn => clkIn,
            rstIn => rstIn,
            dOut  => rand);
    ----------------------------------------------------------------------------
    -- Generate Key

        -- Select random 1 <= d <= (n-1)
        -- Compute Q = dG
        -- Output public key Q and private key d

    keygen_ent : entity work.ecc_dsa_keygen(rtl)
        port map (
            clkIn   =>,
            rstIn   =>,
            enIn    =>,
            qIn     =>,
            FR_In   =>,
            aIn     =>,
            bIn     =>,
            seedIn  =>,
            G_In    =>,
            nIn     =>,
            hIn     =>,
            statOut =>, -- 1 = success, 0 = error
            dOut    =>,
            qOut    =>);

    -- Generate Signature

        -- Select random 1 <= k <= (n-1)
        -- Compute P = (x,y) = kG
        -- Compute r = x mod n
            -- If r = 0, select new k
        -- Compute r = k^-1 mod n
        -- Compute e = SHA(m)
        -- Compute s = k^-1(e + dr) mod n
            -- If s = 0, select new k
        -- Signature is (r,s)

    siggen_ent : entity work.ecc_dsa_keygen(rtl)
        port map (
            clkIn  =>,
            rstIn  =>,
            enIn   =>,
            kIn    =>,
            mSHAIn =>,
            sigOut =>);

    -- Authenticate

        -- Verify 1 <= r,s <= (n-1)
        -- Compute e = SHA(m)
        -- Compute w = s^-1 mod n
        -- Compute u1 = ew
        -- Compute u2 = rw
        -- Compute X = (x1,x2) = u1*G+u2*Q
        -- If X = 0, reject
        -- Else compute v = x1 mod n
        -- Accept if v = r

    auth_ent : entity work.ecca_dsa_auth(rtl)
        port map (
            clkIn   => ,
            rstIn   => ,
            enIn    => ,
            sigIn   => ,
            mSHAIn  => ,
            authOut => );

end rtl;

--------------------------------------------------------------------------------
-- Galoi Linear Feedback Shift Register
-- Generates pseudo-random integers
-- n = 256, so must be able to generate between 1...[n-1]
-- This, 8 bits suffice
-- Source : http://emmanuel.pouly.free.fr/fibo.html
-- Taps Source: https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
--------------------------------------------------------------------------------
entity GLFSR is
    generic (
        N     : integer := 64);
    port (
        clkIn : in    std_logic;
        rstIn : in    std_logic;
        dOut  :   out std_logic_vector(N-1 downto 0));
end entity GLFSR;
--------------------------------------------------------------------------------
architecture rtl of GLFSR is
    signal   temp       : std_logic_vector(dOut'range) := (0=>'1', others=>'0');
    constant polynomial : std_logic_vector(dOut'range) := (63=>'1',62=>'1',60=>'1',59=>'1', others=>'0'); -- Verify this further
begin
    process (clkIn, rstIn)
        variable lsb : std_logic;
        variable ext_inbit : std_logic_vector(dOut'range);
    begin
        lsb := temp(0);
        for i in dOut'range loop
            ext_inbit(i) := lsb;
        end loop;

        if rising_edge(clkIn) then
            if (rstIn /= '0') then
                temp <= (0=>'1', others=>'0');
            elsif then
                lfsr_tmp <= ('0' & temp(dOut'range)) xor (ext_inbit and polynomial);
            end if;
        end if;
    end process;
end architecture rtl;