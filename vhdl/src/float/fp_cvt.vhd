-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.fp_wire.all;
use work.fp_func.all;

entity fp_cvt is
	generic(
		RISCV : integer := 0
	);
	port(
		fp_cvt_f2i_i : in  fp_cvt_f2i_in_type;
		fp_cvt_f2i_o : out fp_cvt_f2i_out_type;
		fp_cvt_i2f_i : in  fp_cvt_i2f_in_type;
		fp_cvt_i2f_o : out fp_cvt_i2f_out_type;
		lzc_i        : out lzc_32_in_type;
		lzc_o        : in  lzc_32_out_type
	);
end fp_cvt;

architecture behavior of fp_cvt is

begin

	CVT_IEEE : if RISCV = 0 generate

		process(fp_cvt_f2i_i)
			variable data  : std_logic_vector(32 downto 0);
			variable op    : std_logic_vector(1 downto 0);
			variable rm    : std_logic_vector(2 downto 0);
			variable class : std_logic_vector(9 downto 0);

			variable result : std_logic_vector(31 downto 0);
			variable flags  : std_logic_vector(4 downto 0);

			variable snan : std_logic;
			variable qnan : std_logic;
			variable inf  : std_logic;
			variable zero : std_logic;

			variable sign_cvt      : std_logic;
			variable exponent_cvt  : integer range -4095 to 4095;
			variable mantissa_cvt  : std_logic_vector(58 downto 0);
			variable exponent_bias : natural range 0 to 127;

			variable mantissa_uint : std_logic_vector(32 downto 0);

			variable grs : std_logic_vector(2 downto 0);
			variable odd : std_logic;

			variable rnded : natural range 0 to 1;

			variable oor : std_logic;

			variable or_1 : std_logic;
			variable or_2 : std_logic;
			variable or_3 : std_logic;

			variable oor_32u : std_logic;
			variable oor_32s : std_logic;

		begin
			data := fp_cvt_f2i_i.data;
			op := fp_cvt_f2i_i.op.fcvt_op;
			rm := fp_cvt_f2i_i.rm;
			class := fp_cvt_f2i_i.class;

			flags := (others => '0');
			result := (others => '0');

			snan := class(8);
			qnan := class(9);
			inf := class(0) or class(7);
			zero := '0';

			if op = "00" then
				exponent_bias := 34;
			else
				exponent_bias := 35;
			end if;

			sign_cvt := data(32);
			exponent_cvt := to_integer(unsigned(data(31 downto 23))) - 252;
			mantissa_cvt := X"000000001" & data(22 downto 0);

			if (class(3) or class(4)) = '1' then
				mantissa_cvt(23) := '0';
			end if;

			oor := '0';

			if exponent_cvt > exponent_bias then
				oor := '1';
			elsif exponent_cvt > 0 then
				mantissa_cvt := std_logic_vector(shift_left(unsigned(mantissa_cvt), exponent_cvt));
			end if;

			mantissa_uint := mantissa_cvt(58 downto 26);

			grs := mantissa_cvt(25 downto 24) & or_reduce(mantissa_cvt(23 downto 0));
			odd := mantissa_uint(0) or or_reduce(grs(1 downto 0));

			flags(0) := or_reduce(grs);

			rnded := 0;

			case rm is
				when "000" =>               --rne--
					if (grs(2) and odd) = '1' then
						rnded := 1;
					end if;
				when "001" =>               --rtz--
					null;
				when "010" =>               --rdn--
					if (sign_cvt and flags(0)) = '1' then
						rnded := 1;
					end if;
				when "011" =>               --rup--
					if (not sign_cvt and flags(0)) = '1' then
						rnded := 1;
					end if;
				when "100" =>               --rmm--
					if (grs(2) and flags(0)) = '1' then
						rnded := 1;
					end if;
				when others =>
					null;
			end case;

			mantissa_uint := std_logic_vector(unsigned(mantissa_uint) + rnded);

			or_1 := mantissa_uint(32);
			or_2 := mantissa_uint(31);
			or_3 := or_reduce(mantissa_uint(30 downto 0));

			zero := or_1 or or_2 or or_3;

			oor_32u := or_1;
			oor_32s := or_1;

			if sign_cvt = '1' then
				if op = "00" then
					oor_32s := oor_32s or (or_2 and or_3);
				elsif op = "01" then
					oor := oor or zero;
				end if;
			else
				oor_32s := oor_32s or or_2;
			end if;

			oor_32u := to_std_logic(op = "01") and (oor_32u or oor or inf or snan or qnan);
			oor_32s := to_std_logic(op = "00") and (oor_32s or oor or inf or snan or qnan);

			if sign_cvt = '1' then
				mantissa_uint := std_logic_vector(-signed(mantissa_uint));
			end if;

			if op = "00" then
				result := mantissa_uint(31 downto 0);
				if oor_32s = '1' then
					result := X"80000000";
					flags := "10000";
				end if;
			elsif op = "01" then
				result := mantissa_uint(31 downto 0);
				if oor_32u = '1' then
					result := X"FFFFFFFF";
					flags := "10000";
				end if;
			end if;

			fp_cvt_f2i_o.result <= result;
			fp_cvt_f2i_o.flags <= flags;

		end process;

	end generate CVT_IEEE;

	CVT_RISCV : if RISCV = 1 generate

		process(fp_cvt_f2i_i)
			variable data  : std_logic_vector(32 downto 0);
			variable op    : std_logic_vector(1 downto 0);
			variable rm    : std_logic_vector(2 downto 0);
			variable class : std_logic_vector(9 downto 0);

			variable result : std_logic_vector(31 downto 0);
			variable flags  : std_logic_vector(4 downto 0);

			variable snan : std_logic;
			variable qnan : std_logic;
			variable inf  : std_logic;
			variable zero : std_logic;

			variable sign_cvt      : std_logic;
			variable exponent_cvt  : integer range -4095 to 4095;
			variable mantissa_cvt  : std_logic_vector(58 downto 0);
			variable exponent_bias : natural range 0 to 127;

			variable mantissa_uint : std_logic_vector(32 downto 0);

			variable grs : std_logic_vector(2 downto 0);
			variable odd : std_logic;

			variable rnded : natural range 0 to 1;

			variable oor : std_logic;

			variable or_1 : std_logic;
			variable or_2 : std_logic;
			variable or_3 : std_logic;

			variable oor_32u : std_logic;
			variable oor_32s : std_logic;

		begin
			data := fp_cvt_f2i_i.data;
			op := fp_cvt_f2i_i.op.fcvt_op;
			rm := fp_cvt_f2i_i.rm;
			class := fp_cvt_f2i_i.class;

			flags := (others => '0');
			result := (others => '0');

			snan := class(8);
			qnan := class(9);
			inf := class(0) or class(7);
			zero := '0';

			if op = "00" then
				exponent_bias := 34;
			else
				exponent_bias := 35;
			end if;

			sign_cvt := data(32);
			exponent_cvt := to_integer(unsigned(data(31 downto 23))) - 252;
			mantissa_cvt := X"000000001" & data(22 downto 0);

			if (class(3) or class(4)) = '1' then
				mantissa_cvt(23) := '0';
			end if;

			oor := '0';

			if exponent_cvt > exponent_bias then
				oor := '1';
			elsif exponent_cvt > 0 then
				mantissa_cvt := std_logic_vector(shift_left(unsigned(mantissa_cvt), exponent_cvt));
			end if;

			mantissa_uint := mantissa_cvt(58 downto 26);

			grs := mantissa_cvt(25 downto 24) & or_reduce(mantissa_cvt(23 downto 0));
			odd := mantissa_uint(0) or or_reduce(grs(1 downto 0));

			flags(0) := or_reduce(grs);

			rnded := 0;

			case rm is
				when "000" =>               --rne--
					if (grs(2) and odd) = '1' then
						rnded := 1;
					end if;
				when "001" =>               --rtz--
					null;
				when "010" =>               --rdn--
					if (sign_cvt and flags(0)) = '1' then
						rnded := 1;
					end if;
				when "011" =>               --rup--
					if (not sign_cvt and flags(0)) = '1' then
						rnded := 1;
					end if;
				when "100" =>               --rmm--
					if (grs(2) and flags(0)) = '1' then
						rnded := 1;
					end if;
				when others =>
					null;
			end case;

			mantissa_uint := std_logic_vector(unsigned(mantissa_uint) + rnded);

			or_1 := mantissa_uint(32);
			or_2 := mantissa_uint(31);
			or_3 := or_reduce(mantissa_uint(30 downto 0));

			zero := or_1 or or_2 or or_3;

			oor_32u := or_1;
			oor_32s := or_1;

			if sign_cvt = '1' then
				if op = "00" then
					oor_32s := oor_32s or (or_2 and or_3);
				elsif op = "01" then
					oor := oor or zero;
				end if;
			else
				oor_32s := oor_32s or or_2;
			end if;

			oor_32u := to_std_logic(op = "01") and (oor_32u or oor or inf or snan or qnan);
			oor_32s := to_std_logic(op = "00") and (oor_32s or oor or inf or snan or qnan);

			if sign_cvt = '1' then
				mantissa_uint := std_logic_vector(-signed(mantissa_uint));
			end if;

			if op = "00" then
				result := mantissa_uint(31 downto 0);
				if oor_32s = '1' then
					result := X"7FFFFFFF";
					flags := "10000";
					if sign_cvt = '1' then
						if (snan or qnan) = '0' then
							result := X"80000000";
						end if;
					end if;
				end if;
			elsif op = "01" then
				result := mantissa_uint(31 downto 0);
				if oor_32u = '1' then
					result := X"FFFFFFFF";
					flags := "10000";
				end if;
				if sign_cvt = '1' then
					if (snan or qnan) = '0' then
						result := X"00000000";
					end if;
				end if;
			end if;

			fp_cvt_f2i_o.result <= result;
			fp_cvt_f2i_o.flags <= flags;

		end process;

	end generate CVT_RISCV;

	process(fp_cvt_i2f_i, lzc_o)
		variable data : std_logic_vector(31 downto 0);
		variable op   : std_logic_vector(1 downto 0);
		variable fmt  : std_logic_vector(1 downto 0);
		variable rm   : std_logic_vector(2 downto 0);

		variable snan : std_logic;
		variable qnan : std_logic;
		variable dbz  : std_logic;
		variable inf  : std_logic;
		variable zero : std_logic;

		variable sign_uint     : std_logic;
		variable exponent_uint : natural range 0 to 31;
		variable mantissa_uint : std_logic_vector(31 downto 0);
		variable counter_uint  : natural range 0 to 31;
		variable exponent_bias : natural range 0 to 127;

		variable sign_rnd     : std_logic;
		variable exponent_rnd : integer range -1023 to 1023;
		variable mantissa_rnd : std_logic_vector(24 downto 0);

		variable grs : std_logic_vector(2 downto 0);

	begin
		data := fp_cvt_i2f_i.data;
		op := fp_cvt_i2f_i.op.fcvt_op;
		fmt := fp_cvt_i2f_i.fmt;
		rm := fp_cvt_i2f_i.rm;

		snan := '0';
		qnan := '0';
		dbz := '0';
		inf := '0';
		zero := '0';

		exponent_bias := 127;

		sign_uint := '0';
		if op = "00" then
			sign_uint := data(31);
		end if;

		if sign_uint = '1' then
			data := std_logic_vector(-signed(data));
		end if;

		mantissa_uint := X"FFFFFFFF";
		exponent_uint := 0;
		if op(1) = '0' then
			mantissa_uint := data(31 downto 0);
			exponent_uint := 31;
		end if;

		zero := nor_reduce(mantissa_uint);

		lzc_i.a <= mantissa_uint;
		counter_uint := to_integer(unsigned(not lzc_o.c));

		mantissa_uint := std_logic_vector(shift_left(unsigned(mantissa_uint),counter_uint));

		sign_rnd := sign_uint;
		exponent_rnd := exponent_uint + exponent_bias - counter_uint;

		mantissa_rnd := "0" & mantissa_uint(31 downto 8);
		grs := mantissa_uint(7 downto 6) & or_reduce(mantissa_uint(5 downto 0));

		fp_cvt_i2f_o.fp_rnd.sig <= sign_rnd;
		fp_cvt_i2f_o.fp_rnd.expo <= exponent_rnd;
		fp_cvt_i2f_o.fp_rnd.mant <= mantissa_rnd;
		fp_cvt_i2f_o.fp_rnd.rema <= "00";
		fp_cvt_i2f_o.fp_rnd.fmt <= fmt;
		fp_cvt_i2f_o.fp_rnd.rm <= rm;
		fp_cvt_i2f_o.fp_rnd.grs <= grs;
		fp_cvt_i2f_o.fp_rnd.snan <= snan;
		fp_cvt_i2f_o.fp_rnd.qnan <= qnan;
		fp_cvt_i2f_o.fp_rnd.dbz <= dbz;
		fp_cvt_i2f_o.fp_rnd.inf <= inf;
		fp_cvt_i2f_o.fp_rnd.zero <= zero;
		fp_cvt_i2f_o.fp_rnd.diff <= '0';

	end process;

end behavior;
