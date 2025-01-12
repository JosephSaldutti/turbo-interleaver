library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port(			clk:			in std_logic;
				reset:			in std_logic;
				vld_crc:		in std_logic;
				rdy_out:		in std_logic;
				cbs:			in std_logic;
				rdy_crc:		out std_logic;
				vld_out:		out std_logic;
				enable_rec:		out std_logic;
				enable_send:		out std_logic);
end fsm;

architecture rtl of fsm is

--signals
type state_type is (ready, rec, done, send);
signal state, state_next : state_type;
signal counter, counter_next : integer;

begin

	--on clock edge
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= ready;
		elsif(clk'event and clk = '1') then
			state <= state_next;
			counter <= counter_next;
		end if;
	end process;

	--setting state next
	process(state, vld_crc, rdy_out, counter)
	begin
		case state is
			when ready =>
				if(vld_crc = '1') then
					state_next <= rec;
				else
					state_next <= ready;
				end if;
			when rec =>
				if(counter = 0) then
					state_next <= done;
				else 
					state_next <= rec;
				end if;
			when done =>
				if(rdy_out = '1') then
					state_next <= send;
				else 
					state_next <= done;
				end if;
			when send =>
				if(counter = 0) then
					state_next <= ready;
				else
					state_next <= send;
				end if;
		end case;
	end process;
	
	--setting outputs
	process(state)
	begin
		case state is
			when ready =>
				rdy_crc <= '1';
				vld_out <= '0';
				enable_rec <= '0';
				enable_send <= '0';
			when rec =>
				rdy_crc <= '0';
				vld_out <= '0';
				enable_rec <= '1';
				enable_send <= '0';
			when done =>
				rdy_crc <= '0';
				vld_out <= '1';
				enable_rec <= '0';
				enable_send <= '0';
			when send =>
				rdy_crc <= '0';
				vld_out <= '0';
				enable_rec <= '0';
				enable_send <= '1';
		end case;
	end process;
	
	--counter
	process(state)
	begin
		case state is
			when ready =>
				if(cbs = '1') then
					counter_next <= 10;
				else
					counter_next <= 3;
				end if;
			when rec =>
				counter_next <= counter - 1;
			when done =>
				if(cbs = '1') then
					counter_next <= 10;
				else
					counter_next <= 3;
				end if;
			when send =>
				counter_next <= counter - 1;
		end case;
	end process;
end rtl;

