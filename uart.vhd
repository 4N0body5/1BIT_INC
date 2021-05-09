-- uart.vhd: UART controller - receiving part
-- Author: Natália Bubáková (xbubak01)
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
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal mid_count	: std_logic_vector(4 downto 0);
signal bit_count	: std_logic_vector(3 downto 0);
signal recieve_en	: std_logic;
signal count_en	 	: std_logic;
signal d_vld	 	: std_logic;
begin

	FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	    =>	CLK,
        RST 	    =>	RST,
        DIN 	    =>	DIN,
		DOUT_VLD	=>	d_vld,
        MID_COUNT 	=>	mid_count,
        BIT_COUNT 	=>	bit_count,
		RECEIVE_EN	=>	recieve_en,
		COUNT_EN	=>	count_en
    );
	
	DOUT_VLD <= d_vld;
	process (CLK) begin
		if rising_edge (CLK) then
			if count_en = '1' then
				mid_count <= mid_count + 1;
			else
				mid_count  <= "00010";
				bit_count  <=  "0000";
			end if;
			if recieve_en = '1' then
				if mid_count(4) = '1' then
					mid_count  <= "00001";
					case bit_count is
						when "0000"  =>  DOUT(0) <= DIN;
						when "0001"  =>  DOUT(1) <= DIN;
						when "0010"  =>  DOUT(2) <= DIN;
						when "0011"  =>  DOUT(3) <= DIN;
						when "0100"  =>  DOUT(4) <= DIN;
						when "0101"  =>  DOUT(5) <= DIN;
						when "0110"  =>  DOUT(6) <= DIN;
						when "0111"  =>  DOUT(7) <= DIN;
						when others  =>  null;
					end case;
					bit_count <= bit_count + 1;
				end if;			
			end if;
		end if;
	end process;
end behavioral;
