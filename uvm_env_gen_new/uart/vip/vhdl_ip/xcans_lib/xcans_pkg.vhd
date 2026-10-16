-- ----------------------------------------------------
-- XCANs IP stub (simulated vendor IP)
-- ----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity xcans_top is
    port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        can_tx : out std_logic;
        can_rx : in  std_logic
    );
end entity xcans_top;

architecture stub of xcans_top is
begin
    can_tx <= can_rx;
end architecture stub;
