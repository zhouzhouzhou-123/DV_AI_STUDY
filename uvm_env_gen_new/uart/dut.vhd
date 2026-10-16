-- ----------------------------------------------------
-- Copyright(C) 2026 Chipsea All rights reserved.
-- File Name: dut.vhd
-- Description: Simple DUT with 20 I/O signals (VHDL version)
-- ----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dut is
    port (
        clk       : in  std_logic;
        rst_n     : in  std_logic;
        uart_rx   : in  std_logic;
        gpio_in   : in  std_logic_vector(3 downto 0);
        data_in   : in  std_logic_vector(3 downto 0);
        uart_tx   : out std_logic;
        gpio_out  : out std_logic_vector(3 downto 0);
        data_out  : out std_logic_vector(3 downto 0);
        led       : out std_logic_vector(3 downto 0)
    );
end entity dut;

architecture rtl of dut is
    signal cnt : unsigned(3 downto 0) := (others => '0');
begin

    uart_tx  <= uart_rx;
    gpio_out <= gpio_in;
    data_out <= data_in;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            cnt <= cnt + 1;
        end if;
    end process;

    led <= std_logic_vector(cnt);

end architecture rtl;
