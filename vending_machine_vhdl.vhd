library ieee;
use ieee.std_logic_1164.all;

entity button_press_debounce_vhdl is
    generic (
        CLK_HZ      : positive := 27000000;
        DEBOUNCE_MS : positive := 10
    );
    port (
        clk      : in  std_logic;
        button_n : in  std_logic;
        press    : out std_logic
    );
end entity button_press_debounce_vhdl;

architecture rtl of button_press_debounce_vhdl is
    constant LIMIT : positive := (CLK_HZ / 1000) * DEBOUNCE_MS;
    signal sync_1   : std_logic := '1';
    signal sync_2   : std_logic := '1';
    signal stable_n : std_logic := '1';
    signal count    : natural range 0 to LIMIT - 1 := 0;
    signal press_reg : std_logic := '0';
begin
    press <= press_reg;

    process (clk)
    begin
        if rising_edge(clk) then
            sync_1 <= button_n;
            sync_2 <= sync_1;
            press_reg <= '0';

            if sync_2 = stable_n then
                count <= 0;
            elsif count = LIMIT - 1 then
                stable_n <= sync_2;
                count <= 0;
                if sync_2 = '0' then
                    press_reg <= '1';
                end if;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine_vhdl is
    port (
        clk               : in  std_logic;
        btn_coin_n        : in  std_logic;
        btn_buy50_n       : in  std_logic;
        led_bought30_n    : out std_logic;
        led_bought50_n    : out std_logic;
        led_insufficient_n : out std_logic;
        led_reached50_n   : out std_logic
    );
end entity vending_machine_vhdl;

architecture rtl of vending_machine_vhdl is
    signal coin_press   : std_logic;
    signal buy50_press  : std_logic;
    signal balance_tens : unsigned(2 downto 0) := (others => '0');
    signal bought30     : std_logic := '0';
    signal bought50     : std_logic := '0';
    signal insufficient : std_logic := '0';
begin
    coin_button : entity work.button_press_debounce_vhdl
        port map (clk => clk, button_n => btn_coin_n, press => coin_press);

    buy50_button : entity work.button_press_debounce_vhdl
        port map (clk => clk, button_n => btn_buy50_n, press => buy50_press);

    process (clk)
    begin
        if rising_edge(clk) then
            if buy50_press = '1' then
                if balance_tens >= to_unsigned(5, balance_tens'length) then
                    balance_tens <= balance_tens - to_unsigned(5, balance_tens'length);
                    bought30 <= '0';
                    bought50 <= '1';
                    insufficient <= '0';
                else
                    insufficient <= '1';
                end if;
            elsif coin_press = '1' then
                if balance_tens >= to_unsigned(5, balance_tens'length) then
                    balance_tens <= balance_tens - to_unsigned(3, balance_tens'length);
                    bought30 <= '1';
                    bought50 <= '0';
                    insufficient <= '0';
                else
                    balance_tens <= balance_tens + to_unsigned(1, balance_tens'length);
                end if;
            end if;
        end if;
    end process;

    -- Board LEDs are active-low. Status LEDs remain lit until a successful purchase.
    led_bought30_n     <= not bought30;
    led_bought50_n     <= not bought50;
    led_insufficient_n <= not insufficient;
    led_reached50_n    <= '0' when balance_tens >= to_unsigned(5, balance_tens'length) else '1';
end architecture rtl;
