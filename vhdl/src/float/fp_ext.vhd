-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_wire.all;
use work.fp_func.all;

entity fp_ext is
	port(
		fp_ext_i : in  fp_ext_in_type;
		fp_ext_o : out fp_ext_out_type;
		lzc_o    : in  lzc_32_out_type;
		lzc_i    : out lzc_32_in_type
	);
end fp_ext;

architecture behavior of fp_ext is

begin

	process(fp_ext_i, lzc_o)
		variable data : std_logic_vector(31 downto 0);
		variable fmt  : std_logic_vector(1 downto 0);

		variable mantissa : std_logic_vector(31 downto 0);
		variable counter  : integer range 0 to 31;

		variable result : std_logic_vector(32 downto 0);
		variable class  : std_logic_vector(9 downto 0);

		variable mantissa_zero : std_logic;
		variable exponent_zero : std_logic;
		variable exponent_ones : std_logic;

	begin
		data := fp_ext_i.data;
		fmt := fp_ext_i.fmt;

		mantissa := (others => '1');
		counter := 0;

		result := (others => '0');
		class := (others => '0');

		mantissa_zero := '0';
		exponent_zero := '0';
		exponent_ones := '0';

		if fmt = "00" then
			mantissa := '0' & data(22 downto 0) & X"FF";
			exponent_zero := nor_reduce(data(30 downto 23));
			exponent_ones := and_reduce(data(30 downto 23));
			mantissa_zero := nor_reduce(data(22 downto 0));
		end if;

		lzc_i.a         <= mantissa;
		counter := to_integer(unsigned(not lzc_o.c));

		if fmt = "00" then
			result(32) := data(31);
			if and_reduce(data(30 downto 23)) = '1' then
				result(31 downto 23) := (others => '1');
				result(22 downto 0) := data(22 downto 0);
			elsif or_reduce(data(30 downto 23)) = '1' then
				result(31 downto 23) := std_logic_vector(resize(unsigned(data(30 downto 23)), 9) + 128);
				result(22 downto 0) := data(22 downto 0);
			elsif counter < 24 then
				result(31 downto 23) := std_logic_vector(to_unsigned(129 - counter, 9));
				result(22 downto 0) := std_logic_vector(shift_left(unsigned(data(22 downto 0)),counter));
			end if;
		end if;

		if result(32) = '1' then
			if exponent_ones = '1' then
				if mantissa_zero = '1' then
					class(0) := '1';
				elsif result(22) = '0' then
					class(8) := '1';
				else
					class(9) := '1';
				end if;
			elsif exponent_zero = '1' then
				if mantissa_zero = '1' then
					class(3) := '1';
				else
					class(2) := '1';
				end if;
			else
				class(1) := '1';
			end if;
		else
			if exponent_ones = '1' then
				if mantissa_zero = '1' then
					class(7) := '1';
				elsif result(22) = '0' then
					class(8) := '1';
				else
					class(9) := '1';
				end if;
			elsif exponent_zero = '1' then
				if mantissa_zero = '1' then
					class(4) := '1';
				else
					class(5) := '1';
				end if;
			else
				class(6) := '1';
			end if;
		end if;

		fp_ext_o.result <= result;
		fp_ext_o.class <= class;

	end process;

end behavior;
