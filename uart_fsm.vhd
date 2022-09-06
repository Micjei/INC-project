-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xbabus01
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK              : in    std_logic;
	CNT1             : in    std_logic_vector(4 downto 0);
   RST              : in    std_logic;
   DATA             : in    std_logic;
   DATA_READ        : in    std_logic;
	RX_EN            : out   std_logic;
   CNT_EN           : out   std_logic;
   VLD              : out   std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type state_type is (WAIT_START_BIT, WAIT_FIRST_BIT, DATA_RECIEVE, WAIT_STOP_BIT, VALID_DATA);
signal state : state_type := WAIT_START_BIT;
begin
    RX_EN <= '1' when state = DATA_RECIEVE else '0';
    VLD <= '1' when state = VALID_DATA else '0';
    CNT_EN <= '0' when state = VALID_DATA or state = WAIT_START_BIT else '1';
    process (CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= WAIT_START_BIT;
            else
                case state is
                when WAIT_START_BIT => 
                    if DATA = '0' then
                        state <= WAIT_FIRST_BIT;
                    end if;
                when WAIT_FIRST_BIT =>
                    if CNT1 = "11000" then
                        state <= DATA_RECIEVE;
                    end if;
                when DATA_RECIEVE =>
                    if DATA_READ = '1' then
                        state <= WAIT_STOP_BIT;
                    end if;
                when WAIT_STOP_BIT =>
                    if CNT1 = "10000" then
                        state <= VALID_DATA;
                    end if;
                when VALID_DATA => state <= WAIT_START_BIT;
                end case;
            end if;
        end if;
    end process;
end behavioral;
