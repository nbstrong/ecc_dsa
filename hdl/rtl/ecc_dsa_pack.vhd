library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ecc_dsa_pack is

    -- Domain Parameters
    constant m  : integer                        := 163;
    constant f  : std_logic_vector(m-1 downto 0) := (7 => '1', 6 => '1', 3 => '1', 0 => '1', others=>'0');
    constant a  : std_logic_vector(m-1 downto 0) := (0 => '1', others => '0');
    constant b  : std_logic_vector(m-1 downto 0) := (0 => '1', others => '0');
    constant Gx : std_logic_vector(m-1 downto 0) := "010" & X"fe13c0537bbc11acaa07d793de4e6d5e5c94eee8";
    constant Gy : std_logic_vector(m-1 downto 0) := "010" & X"89070fb05d38ff58321f2e800536d538ccdaa3d9";
    constant n  : std_logic_vector(m-1 downto 0) := "100" & X"000000000000000000020108a2e0cc0d99f8a5ef";
    constant h  : integer                        := 2;

    --type DOMAIN is record
    --    f  : std_logic_vector(m-1 downto 0);
    --    a  : std_logic_vector(m-1 downto 0);
    --    b  : std_logic_vector(m-1 downto 0);
    --    Gx : std_logic_vector(m-1 downto 0);
    --    Gy : std_logic_vector(m-1 downto 0);
    --    n  : std_logic_vector(m-1 downto 0);
    --    h  : integer;
    --end record DOMAIN;

    --constant BINARY_163 : DOMAIN := (
    --f  => (7 => '1', 6 => '1', 3 => '1', 0 => '1', others=>'0'),
    --a  => (0 => '1', others => '0'),
    --b  => (0 => '1', others => '0'),
    --Gx => "010" & X"fe13c0537bbc11acaa07d793de4e6d5e5c94eee8",
    --Gy => "010" & X"89070fb05d38ff58321f2e800536d538ccdaa3d9",
    --n  => "100" & X"000000000000000000020108a2e0cc0d99f8a5ef",
    --h  => 2);


end ecc_dsa_pack;