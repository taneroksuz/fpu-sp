-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_wire.all;
use work.all;

library std;
use std.textio.all;
use std.env.all;

entity test_float is
end entity test_float;

architecture behavior of test_float is

	component fp_unit
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			fp_unit_i : in  fp_unit_in_type;
			fp_unit_o : out fp_unit_out_type
		);
	end component;

	type fpu_test_reg_type is record
		data1       : std_logic_vector(31 downto 0);
		data2       : std_logic_vector(31 downto 0);
		data3       : std_logic_vector(31 downto 0);
		result      : std_logic_vector(31 downto 0);
		flags       : std_logic_vector(4 downto 0);
		fmt         : std_logic_vector(1 downto 0);
		rm          : std_logic_vector(2 downto 0);
		op          : fp_operation_type;
		enable      : std_logic;
		result_orig : std_logic_vector(31 downto 0);
		result_calc : std_logic_vector(31 downto 0);
		result_diff : std_logic_vector(31 downto 0);
		flags_orig  : std_logic_vector(4 downto 0);
		flags_calc  : std_logic_vector(4 downto 0);
		flags_diff  : std_logic_vector(4 downto 0);
		ready_calc  : std_logic;
		terminate   : std_logic;
	end record;

	constant init_fpu_test_reg : fpu_test_reg_type := (
		data1       => (others => '0'),
		data2       => (others => '0'),
		data3       => (others => '0'),
		result      => (others => '0'),
		flags       => (others => '0'),
		fmt         => (others => '0'),
		rm          => (others => '0'),
		op          => init_fp_operation,
		enable      => '0',
		result_orig => (others => '0'),
		result_calc => (others => '0'),
		result_diff => (others => '0'),
		flags_orig  => (others => '0'),
		flags_calc  => (others => '0'),
		flags_diff  => (others => '0'),
		ready_calc  => '0',
		terminate   => '0'
	);

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	signal r   : fpu_test_reg_type;
	signal rin : fpu_test_reg_type;

	signal fpu_i : fp_unit_in_type;
	signal fpu_o : fp_unit_out_type;

	procedure print(
		msg : in string) is
		variable buf : line;
	begin
		write(buf, msg);
		writeline(output, buf);
	end procedure print;

	function read(
		a : in string) return std_logic_vector is
		variable ret : std_logic_vector(a'length*4-1 downto 0);
		variable val : std_logic_vector(7 downto 0);
	begin
			for i in a'range loop
					if (character'pos(a(i)) >= 48 and character'pos(a(i)) <= 57) then
						val := std_logic_vector(to_unsigned(character'pos(a(i)), 8)-48);
					elsif (character'pos(a(i)) >= 65 and character'pos(a(i)) <= 70) then
						val := std_logic_vector(to_unsigned(character'pos(a(i)), 8)-55);
					else
						val := (others => '0');
					end if;
					ret((a'length-i)*4+3 downto (a'length-i)*4) := val(3 downto 0);
			end loop;
			return ret;
	end function read;

begin

	reset <= '1' after 10 ps;
	clock <= not clock after 1 ps;

	fp_unit_comp : fp_unit
		port map(
			reset     => reset,
			clock     => clock,
			fp_unit_i => fpu_i,
			fp_unit_o => fpu_o
		);

	process(reset, clock)
		file infile     : text open read_mode is "f32_le.hex";
		variable inline : line;

		variable data1  : string(1 to 8) := "00000000";
		variable data2  : string(1 to 8) := "00000000";
		variable data3  : string(1 to 8) := "00000000";
		variable result : string(1 to 8) := "00000000";
		variable flags  : string(1 to 2) := "00";

		variable v : fpu_test_reg_type;

	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_fpu_test_reg;

			else

				v := r;

				if endfile(infile) then
					v.terminate := '1';
					v.enable := '1';
					data1 := "00000000";
					data2 := "00000000";
					data3 := "00000000";
					result := "00000000";
					flags := "00";
				else
					v.terminate := '0';
					v.enable := '1';
					readline(infile, inline);
					data1 := inline.all(1 to 8);
					data2 := inline.all(10 to 17);
					data3 := "00000000";
					result := "0000000" & inline.all(19 to 19);
					flags := inline.all(21 to 22);
				end if;

				v.data1 := read(data1);
				v.data2 := read(data2);
				v.data3 := read(data3);
				v.result := read(result);
				v.flags := read(flags)(4 downto 0);
				v.fmt := "00";
				v.rm := "000";
				v.op.fmadd := '0';
				v.op.fadd := '0';
				v.op.fsub := '0';
				v.op.fmul := '0';
				v.op.fdiv := '0';
				v.op.fsqrt := '0';
				v.op.fcmp := '1';
				v.op.fcvt_i2f := '0';
				v.op.fcvt_f2i := '0';
				v.op.fcvt_op := "00";

				fpu_i.fp_exe_i.data1 <= v.data1;
				fpu_i.fp_exe_i.data2 <= v.data2;
				fpu_i.fp_exe_i.data3 <= v.data3;
				fpu_i.fp_exe_i.op <= v.op;
				fpu_i.fp_exe_i.fmt <= v.fmt;
				fpu_i.fp_exe_i.rm <= v.rm;
				fpu_i.fp_exe_i.enable <= v.enable;

				v.result_orig := r.result;
				v.flags_orig := r.flags;

				v.result_calc := fpu_o.fp_exe_o.result;
				v.flags_calc := fpu_o.fp_exe_o.flags;
				v.ready_calc := fpu_o.fp_exe_o.ready;

				if (v.ready_calc = '1') then
					if (v.op.fcvt_f2i = '0' and v.op.fcmp = '0') and (v.result_calc = x"7FC00000") then
						v.result_diff := "0" & (v.result_orig(30 downto 22) xor v.result_calc(30 downto 22)) & "00" & x"00000";
					else
						v.result_diff := v.result_orig xor v.result_calc;
					end if;
					v.flags_diff := v.flags_orig xor v.flags_calc;
				end if;

				if (v.ready_calc = '1') then
					if (v.terminate = '1') then
						print(character'val(27) & "[1;32m" & "TEST SUCCEEDED" & character'val(27) & "[0m");
						finish;
					elsif (or v.result_diff = '1') or (or v.flags_diff = '1') then
						print(character'val(27) & "[1;31m" & "TEST FAILED");
						print("A                 = 0x" & to_hstring(r.data1));
						print("B                 = 0x" & to_hstring(r.data2));
						print("C                 = 0x" & to_hstring(r.data3));
						print("RESULT DIFFERENCE = 0x" & to_hstring(v.result_diff));
						print("RESULT REFERENCE  = 0x" & to_hstring(v.result_orig));
						print("RESULT CALCULATED = 0x" & to_hstring(v.result_calc));
						print("FLAGS DIFFERENCE  = 0x" & to_hstring(v.flags_diff));
						print("FLAGS REFERENCE   = 0x" & to_hstring(v.flags_orig));
						print("FLAGS CALCULATED  = 0x" & to_hstring(v.flags_calc) & character'val(27) & "[0m");
						finish;
					end if;
				end if;

				r <= v;

			end if;

		end if;

	end process;

end architecture;
