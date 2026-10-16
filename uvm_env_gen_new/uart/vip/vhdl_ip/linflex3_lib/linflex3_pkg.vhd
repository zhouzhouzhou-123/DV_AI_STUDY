-- ----------------------------------------------------
-- LinFlex3 IP stub (simulated vendor IP)
-- ----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity linflex3_top is
    port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        tx    : out std_logic;
        rx    : in  std_logic
    );
end entity linflex3_top;

architecture stub of linflex3_top is
begin
    tx <= rx;
end architecture stub;
