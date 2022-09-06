-- uart.vhd: UART controller - receiving part
-- Author(s): xbabus01
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic := '0'
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal rx_en    : std_logic;
signal cnt_en   : std_logic;
signal out_vld  : std_logic;
signal cnt1     : std_logic_vector(4 downto 0);
signal cnt2     : std_logic_vector(3 downto 0);
begin
    FSM: entity work.UART_FSM(behavioral)
    port map(
        CLK             => CLK,
		  CNT1            => cnt1,
        RST             => RST,
        DATA            => DIN,
        DATA_READ       => cnt2(3),
		  RX_EN           => rx_en,
        CNT_EN          => cnt_en,
        VLD             => out_vld
    );

    DOUT_VLD <= out_vld;
    process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                cnt1 <= "00000";
                cnt2 <= "0000";
            else
                if cnt_en = '1' then
                    cnt1 <= cnt1 + 1;
                else
                    cnt1 <= "00000";
                end if;
                if rx_en = '1' and cnt1(4) = '1' then
                    DOUT(conv_integer(cnt2)) <= DIN;
                    cnt2 <= cnt2 + 1;
                    cnt1 <= "00001";
                end if;
                if rx_en = '0' then
                    cnt2 <= "0000";
                end if;
            end if;
        end if;
    end process;
end behavioral;
