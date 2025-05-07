library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N     : integer;
        WIDTH : integer
    );
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        din  : in  std_logic_vector(WIDTH-1 downto 0);
        load : in  std_logic;
        dout : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture beh of sma_filter is
    type sample_array is array (0 to N-1) of unsigned(WIDTH-1 downto 0);
    signal samples  : sample_array := (others => (others => '0'));
    signal sum      : unsigned(WIDTH+N-3 downto 0) := (others => '0');
    signal index    : integer range 0 to N-1 := 0;
    signal count    : integer range 0 to N := 0;
    signal avg      : unsigned(WIDTH-1 downto 0);
    
begin

    process(clk, rst)
    begin
        if rst = '1' then
            samples <= (others => (others => '0'));
            sum     <= (others => '0');
            index   <= 0;
            count   <= 0;
            dout    <= (others => '0');

        elsif rising_edge(clk) then
            if load = '1' then
                sum <= sum - samples(index) + unsigned(din);
                samples(index) <= unsigned(din);

                if index = N-1 then
                    index <= 0;
                else
                    index <= index + 1;
                end if;

                if count < N then
                    count <= count + 1;
                end if;
            end if;

            if count = N then
                avg  <= resize(sum / to_unsigned(N, sum'length), WIDTH);
                dout <= std_logic_vector(avg);
            else
                dout <= (others => '0');
            end if;
        end if;
    end process;

end architecture;