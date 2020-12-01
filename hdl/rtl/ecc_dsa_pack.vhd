library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ecc_dsa_pack is

    -- Domain Parameters
    constant m  : integer                        := 163;
    constant f  : unsigned(m-1 downto 0) := (7 => '1', 6 => '1', 3 => '1', 0 => '1', others=>'0');
    constant a  : unsigned(m-1 downto 0) := (0 => '1', others => '0');
    constant b  : unsigned(m-1 downto 0) := (0 => '1', others => '0');
    constant Gx : unsigned(m-1 downto 0) := "010" & X"fe13c0537bbc11acaa07d793de4e6d5e5c94eee8";
    constant Gy : unsigned(m-1 downto 0) := "010" & X"89070fb05d38ff58321f2e800536d538ccdaa3d9";
    constant n  : unsigned(m-1 downto 0) := "100" & X"000000000000000000020108a2e0cc0d99f8a5ef";
    constant h  : integer                        := 2;

    -- Point Vector (m*2-1 downto 0) is x concat y
    subtype x is natural range m*2-1 downto m;
    subtype y is natural range m-1   downto 0;

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

function ECC_ADD(
    A : unsigned(m*2-1 downto 0);
    B : unsigned(m*2-1 downto 0))
    return unsigned;

function ECC_MUL(
    A : unsigned(m*2-1 downto 0);
    B : unsigned(m*2-1 downto 0))
    return unsigned;

function point_add(
    A : unsigned(m-1 downto 0);
    B : unsigned(m-1 downto 0))
    return unsigned;

function point_square(
    A : unsigned(m-1 downto 0))
    return unsigned;

function point_mul(
    A : unsigned(m-1 downto 0);
    B : unsigned(m-1 downto 0))
    return unsigned;

function point_inv(
    A : unsigned(m-1 downto 0))
    return unsigned;

end ecc_dsa_pack;
package body ecc_dsa_pack is

function ECC_ADD(
    A : unsigned(m*2-1 downto 0);
    B : unsigned(m*2-1 downto 0))
    return unsigned is
    variable C : unsigned(m*2-1 downto 0);
    variable TH : unsigned(m-1 downto 0);
    variable XR : unsigned(m-1 downto 0);
    variable YR : unsigned(m-1 downto 0);
begin
    -- TH = y2+y1/x2+x1
    TH := point_mul( point_add(B(y), A(y)), point_inv(point_add(B(x), A(x))));
    -- XR = th^2 + th + Ax + Bx + a
    XR  := point_add( point_add( point_add( point_add( point_square(TH), TH), A(x)), B(x)), a);
    -- YR = th*(Ax + x) + x + Ay
    YR  := point_add( point_add( point_mul( th, point_add( A(x), XR)), XR), A(y));
    C   := XR & YR;
    return C;
end ECC_ADD;

function ECC_SQUARE(
    A : unsigned(m*2-1 downto 0))
    return unsigned is
    variable C : unsigned(m*2-1 downto 0);
    variable TH : unsigned(m-1 downto 0);
    variable XR : unsigned(m-1 downto 0);
    variable YR : unsigned(m-1 downto 0);
begin
    -- TH = Ax + Ay / Ax
    TH := point_add(A(x), point_mul(A(y), point_inv(A(x))));
    -- x = th^2 + th + a
    --XR  := point_add( point_add( point_square(TH), TH), a);
    -- y = th*(Ax + x) + x + Ay
    YR  := point_add( point_add( point_mul(TH, point_add(A(x), XR)), XR), A(y));
    C   := XR & YR;
    return C;
end ECC_SQUARE;

-- Implements algorithm 5 defined in
-- https://pdfs.semanticscholar.org/90df/43ffed22bd7f7bd1a1bfc6f866e5cfd0246f.pdf
function point_add(
    A : unsigned(m-1 downto 0);
    B : unsigned(m-1 downto 0))
    return unsigned is
    variable C : unsigned(m-1 downto 0);
begin
    for i in 0 to A'left loop
        C(i) := A(i) xor B(i);
    end loop;
    return C;
end point_add;

-- Implements squaring defined in
-- https://pdfs.semanticscholar.org/90df/43ffed22bd7f7bd1a1bfc6f866e5cfd0246f.pdf
function point_square(
    A : unsigned(m-1 downto 0))
    return unsigned is
    variable C : unsigned(m-1 downto 0);
    variable tmp : unsigned(m*2-1 downto 0) := (others => '0');
begin
    for i in 0 to C'left loop
        if i mod 2 = 0 then
            tmp(i) := A(i/2);
        end if;
    end loop;
    C := tmp mod f;
    return C;
end point_square;

-- Implements algorithm 6 defined in
-- https://pdfs.semanticscholar.org/90df/43ffed22bd7f7bd1a1bfc6f866e5cfd0246f.pdf
function point_mul(
    A : unsigned(m-1 downto 0);
    B : unsigned(m-1 downto 0))
    return unsigned is
    variable C : unsigned(m-1 downto 0);
    constant ONE : unsigned(m-1 downto 0) := (0 => '1', others => '0');
begin
    if A = ONE then
        C := B;
    else
        C := (others => '0');
    end if;
    --for i in 1 to A'right loop

    --end loop;
    return C;
end point_mul;

-- Implements squaring defined in
-- https://pdfs.semanticscholar.org/90df/43ffed22bd7f7bd1a1bfc6f866e5cfd0246f.pdf
function point_inv(
    A : unsigned(m-1 downto 0))
    return unsigned is
    variable C : unsigned(m-1 downto 0);
begin

    return C;
end point_inv;

end ecc_dsa_pack;