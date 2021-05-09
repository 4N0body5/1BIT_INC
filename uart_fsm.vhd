-- uart_fsm.vhd: UART controller - finite state machine
-- Author: Natália Bubáková (xbubak01)
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK         :  in std_logic;
   RST         :  in std_logic;
   DIN         :  in std_logic;
   MID_COUNT   :  in std_logic_vector (4 downto 0);
   BIT_COUNT   :  in std_logic_vector (3 downto 0);
   DOUT_VLD    :  out std_logic;
   RECEIVE_EN  :  out std_logic;
   COUNT_EN    :  out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (START_BIT, TILL_MIDBIT, TILL_END, STOP_BIT, VALID);
signal state: STATE_TYPE := START_BIT;
begin

   process (CLK) begin
      if rising_edge (CLK) then
         if RST = '1' then
            state <= START_BIT;
         else
            case state is              --states during the process of receiving data
               when START_BIT   =>  if DIN = '0' then
                                       COUNT_EN <= '1';
                                       state <= TILL_MIDBIT;
                                    end if;
               when TILL_MIDBIT =>  if MID_COUNT = "11000" then
                                       RECEIVE_EN <= '1';
                                       state <= TILL_END;      --it begins receiving
                                    end if;
               when TILL_END    =>  if BIT_COUNT = "1000" then  
                                       COUNT_EN <= '0';   
                                       state <= STOP_BIT;      --it's got all 8 bits
                                    end if;
               when STOP_BIT    =>  RECEIVE_EN <= '0';
                                    if DIN = '1' then
                                       state <= VALID;
                                       DOUT_VLD <= '1';
                                    end if;
               when VALID  =>  state <= START_BIT;
                               DOUT_VLD <= '0';              
               when others => null;
            end case;
         end if;
      end if;
   end process;

end behavioral;
