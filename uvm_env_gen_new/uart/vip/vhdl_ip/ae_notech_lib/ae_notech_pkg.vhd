-- ----------------------------------------------------
-- AE Notech IP stub (simulated vendor IP)
-- ----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ae_notech_top is
    port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        dout  : out std_logic_vector(3 downto 0);
        din   : in  std_logic_vector(3 downto 0)
    );
end entity ae_notech_top;

architecture stub of ae_notech_top is
begin
    dout <= din;
end architecture stub;
