-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lzc_wire is

	type lzc_32_in_type is record
		a : std_logic_vector(31 downto 0);
	end record;

	type lzc_32_out_type is record
		c : std_logic_vector(4 downto 0);
	end record;

	type lzc_128_in_type is record
		a : std_logic_vector(127 downto 0);
	end record;

	type lzc_128_out_type is record
		c : std_logic_vector(6 downto 0);
	end record;

end package;
