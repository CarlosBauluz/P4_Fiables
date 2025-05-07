library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N     : integer := 4;
        WIDTH : integer := 8
    );
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        din  : in  std_logic_vector(7 downto 0);
        load : in  std_logic;
        dout : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of sma_filter is
    -- Usamos directamente el tipo array como parte del signal
    signal samples : std_logic_vector(7 downto 0) := (others => '0'); -- Dummy para sintaxis
    signal samples_array : std_logic_vector(7 downto 0) := (others => '0'); -- No válido aún

    signal sample0 : unsigned(7 downto 0) := (others => '0');
    signal sample1 : unsigned(7 downto 0) := (others => '0');
    signal sample2 : unsigned(7 downto 0) := (others => '0');
    signal sample3 : unsigned(7 downto 0) := (others => '0');

    signal sum     : unsigned(WIDTH+3 downto 0) := (others => '0');
    signal index   : integer range 0 to 3 := 0;
    signal count   : integer range 0 to 4 := 0;
    signal avg     : unsigned(7 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            sample0 <= (others => '0');
            sample1 <= (others => '0');
            sample2 <= (others => '0');
            sample3 <= (others => '0');
            sum     <= (others => '0');
            index   <= 0;
            count   <= 0;
            dout    <= (others => '0');

        elsif rising_edge(clk) then
            if load = '1' then
                -- Restar el valor antiguo y añadir el nuevo
                case index is
                    when 0 =>
                        sum <= sum - sample0 + unsigned(din);
                        sample0 <= unsigned(din);
                    when 1 =>
                        sum <= sum - sample1 + unsigned(din);
                        sample1 <= unsigned(din);
                    when 2 =>
                        sum <= sum - sample2 + unsigned(din);
                        sample2 <= unsigned(din);
                    when 3 =>
                        sum <= sum - sample3 + unsigned(din);
                        sample3 <= unsigned(din);
                end case;

                if index = 3 then
                    index <= 0;
                else
                    index <= index + 1;
                end if;

                if count < 4 then
                    count <= count + 1;
                end if;
            end if;

            if count = 4 then
                avg  <= resize(sum / to_unsigned(4, sum'length), WIDTH);
                dout <= std_logic_vector(avg);
            else
                dout <= (others => '0');
            end if;
        end if;
    end process;

end architecture;
