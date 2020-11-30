library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.ecc_dsa_pack.all;
--------------------------------------------------------------------------------
-- Implements Elliptic Curve Digital Signature Algorithm
-- Chosen Domain Variables based on recommendations in FIPS-186 and SEC2
-- Binary Field Degree m = 163
-- Koblitz Curve
-- Polynomial Basis
-- Normal Basis Type T - 4
-- Field polynomial - p(t)=t^163+t^7+t^6+t^3+1
-- Polynomial - (162 => '0', 3 => '1' , 0 => '0')
-- n - order - 5846006549323611672814742442876390689256843201587
-- h - cofactor - 2
-- b - coefficient - 0x20a601907b8c953ca1481eb10512f78744a3205fd
-- Xg - base point - 0x3f0eba16286a2d57ea0991168d4994637e8343e36
-- Yg - base point - 0x0d51fbc6c71a0094fa2cdd545b11c5c0c797324f1
-- q - field size
-- FR - basis used
-- a - field elements
-- b - field elements
-- seed - not used
-- G - base point
-- n - order of G
-- h - cofactor - 2
--------------------------------------------------------------------------------
entity ecc_dsa is
    port (
        clkIn : in    std_logic;
        rstIn : in    std_logic;
        enIn  : in    std_logic
    );
end ecc_dsa;
--------------------------------------------------------------------------------
architecture rtl of ecc_dsa is
    -- CONSTANTS ---------------------------------------------------------------
    constant FR : string := "polynomial";
    constant T  : integer := 4;

    -- SIGNALS -----------------------------------------------------------------
    signal stat : std_logic;
    signal d    : std_logic_vector(m-1 downto 0);
    signal q    : std_logic_vector(m-1 downto 0);
    -- TYPES -------------------------------------------------------------------
    -- ALIASES -----------------------------------------------------------------
    -- ATTRIBUTES --------------------------------------------------------------
begin

    -- Generate Key

        -- Select random 1 <= d <= (n-1)
        -- Compute Q = dG
        -- Output public key Q and private key d

    keygen_ent : entity work.ecc_dsa_keygen(rtl)
        port map (
            clkIn   => clkIn,
            rstIn   => rstIn,
            enIn    => enIn,
            statOut => stat, -- 1 = success, 0 = error
            dOut    => d,
            qOut    => q);

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

    --siggen_ent : entity work.ecc_dsa_keygen(rtl)
    --    port map (
    --        clkIn  =>,
    --        rstIn  =>,
    --        enIn   =>,
    --        kIn    =>,
    --        mSHAIn =>,
    --        sigOut =>);

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

    --auth_ent : entity work.ecca_dsa_auth(rtl)
    --    port map (
    --        clkIn   => ,
    --        rstIn   => ,
    --        enIn    => ,
    --        sigIn   => ,
    --        mSHAIn  => ,
    --        authOut => );

end rtl;
