-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- : this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

	component control_unit is 
	  port(i_Op       : in std_logic_vector(6-1 downto 0); 	-- input opcode
	       i_Funct    : in std_logic_vector(6-1 downto 0);	-- input function
	       o_Halt	  : out std_logic;			-- Halt signal
	       o_ALUsrc   : out std_logic;			-- output for ALU source, 0 for B, 1 for Imm
	       o_SignExt  : out std_logic;			-- output for imm sign extend, 0 for zero-extend, 1 for sign-extend
	       o_ALUop	  : out std_logic_vector(5-1 downto 0);	-- output for ALU opcode
	       o_MemToReg : out std_logic_vector(2-1 downto 0); -- output whether reg writes ALU, Dmem, PC, or repl.qb
	       s_DMemWr   : out std_logic;			-- whether dmem writes or not
	       s_RegWr	  : out std_logic;			-- whether RegFile writes or not
	       o_branch   : out std_logic;			-- whether branch instruction or not
	       o_jump     : out std_logic_vector(2-1 downto 0);	-- whether jump instruction or not
	       o_RegDst   : out std_logic_vector(2-1 downto 0));-- output whether RegFile dest input is rt, rd, or 31

	end component;

	signal s_ALUsrc : std_logic;
	signal s_SignExt : std_logic;
	signal s_ALUop : std_logic_vector(5-1 downto 0);
	signal s_MemToReg : std_logic_vector(2-1 downto 0);
	signal s_branch : std_logic;
	signal s_jump : std_logic_vector(2-1 downto 0);
	signal s_RegDst : std_logic_vector(2-1 downto 0);

	component ALU is 
	  port(i_ALUop	     : in std_logic_vector(5-1 downto 0); --ALUopcode
	       i_A	     : in std_logic_vector(32-1 downto 0); --ALU input A
	       i_B 	     : in std_logic_vector(32-1 downto 0); --ALU input B
	       i_shift	     : in std_logic_vector(5-1 downto 0); --shift amount
	       i_repl        : in std_logic_vector(8-1 downto 0); --repl input
	       o_OV	     : out std_logic; --overflow Flag
	       o_Zero	     : out std_logic; --zero Flag
	       o_Carry	     : out std_logic; --Carry Out
	       o_ALUout	     : out std_logic_vector(32-1 downto 0)); --ALU output

	end component;
	signal s_Zero : std_logic;
	signal s_Carryout : std_logic;

	component RegFile32x32b is
	    port(i_rs : in std_logic_vector(4 downto 0); --read register 0
		 i_rt : in std_logic_vector(4 downto 0); --read register 1
		 i_rd : in std_logic_vector(4 downto 0); --write register
		 i_ld : in std_logic_vector(31 downto 0); --load data
		 i_CLK : in std_logic; --CLOCK
		 i_WE : in std_logic; --Write Enable
		 i_CLR : in std_logic; --CLEAR '1' is clear, '0' is hold
		 o_RD0 : out std_logic_vector(31 downto 0); --load data
		 o_RD1 : out std_logic_vector(31 downto 0)); --load data
	end component;
	signal s_RegData0 : std_logic_vector(31 downto 0);
	Signal s_RegData1 : std_logic_vector(31 downto 0);
	signal s_ALU_i_B : std_logic_vector(31 downto 0);
	


	component mux4t1_N is
	    generic(N : integer := 32);
	    port(i_S                  : in std_logic_vector(2-1 downto 0);
		 i_D0                 : in std_logic_vector(N-1 downto 0);
		 i_D1                 : in std_logic_vector(N-1 downto 0);
		 i_D2                 : in std_logic_vector(N-1 downto 0);
		 i_D3                 : in std_logic_vector(N-1 downto 0);
		 o_O                  : out std_logic_vector(N-1 downto 0));
	end component;

	component mux2t1_N is
	  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
	  port(i_S          : in std_logic;
	       i_D0         : in std_logic_vector(N-1 downto 0);
	       i_D1         : in std_logic_vector(N-1 downto 0);
	       o_O          : out std_logic_vector(N-1 downto 0));
	end component;

	component sign_extend is 
	  port(i_sign     : in std_logic;-- sign control
	       i_imm      : in std_logic_vector(16-1 downto 0);-- immediate input
	       o_ext      : out std_logic_vector(32-1 downto 0));-- extended output

	end component;

	component Fetch is
	    port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_immExt : in std_logic_vector(31 downto 0);
		o_add4: out std_logic_vector(31 downto 0);
		i_zero: in std_logic; --Input from ALU Zero
		i_jump: in std_logic_vector(1 downto 0); --Jump control
		i_branch: in std_logic; --Branch conrol
		i_JumpR: in std_logic_vector(31 downto 0);
		o_PC: out std_logic_vector(31 downto 0);
		i_inst: in std_logic_vector(31 downto 0));
	end component;

	signal s_immExt : std_logic_vector(31 downto 0);
	signal s_jumpAddr : std_logic_vector(31 downto 0);
	signal undefined : std_logic_vector(31 downto 0);
	

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  --: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  ControlLogic0: control_unit port map (s_Inst(31 downto 26), s_Inst(5 downto 0), s_Halt, s_ALUsrc, s_SignExt, s_ALUop, s_MemToReg, s_DMemWr, s_RegWr, s_branch, s_jump, s_RegDst);

  --: Ensure that s_Ovfl is connected to the overflow output of your ALU
  ALU0: ALU port map(s_ALUop, s_RegData0, s_ALU_i_B, s_Inst(10 downto 6), s_Inst(23 downto 16), s_Ovfl, s_Zero, s_Carryout, s_DMemAddr);
  oALUOut <=  s_DMemAddr ;

  -- TODO: Implement the rest of your processor below this comment! 
	
  regDestMux0: mux4t1_N generic map (5) port map (s_RegDst, s_Inst(20 downto 16), s_Inst(15 downto 11), "11111", "-----", s_RegWrAddr);
  RegFile0: RegFile32x32b port map(s_Inst(25 downto 21), s_Inst(20 downto 16), s_RegWrAddr, s_RegWrData, iCLK, s_RegWr, iRST, s_RegData0, s_DMemData);

  aluSrcMux0: mux2t1_N generic map (32) port map (s_ALUsrc, s_DMemData, s_immExt, s_ALU_i_B);
  
  signExt0: sign_extend port map (s_SignExt, s_Inst(15 downto 0), s_immExt);

  memToRegMux0: mux4t1_N generic map (32) port map (s_MemToReg, s_DMemAddr, s_DMemOut, s_jumpAddr, undefined, s_RegWrData);

  fetch0: Fetch port map (iCLK, iRST, s_immExt, s_jumpAddr, s_Zero, s_jump, s_branch, s_RegData0, s_NextInstAddr, s_Inst);
 
end structure;

