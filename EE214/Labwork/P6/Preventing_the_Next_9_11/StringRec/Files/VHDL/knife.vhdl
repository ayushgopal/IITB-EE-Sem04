library ieee;
use ieee.std_logic_1164.all;

entity Knife is
   port (u1: in std_logic_vector(7 downto 0); y1: out std_logic; r1, clk: in std_logic);
end entity;

architecture Behave of Knife is
  type InputSymbol  is (RST,k,n,i,f,e,none);
  signal input_symbol: InputSymbol;

  function InputSymbolDecode (r1: std_logic;x1:std_logic_vector(7 downto 0))
	return  InputSymbol is
      variable ret_var: InputSymbol;
  begin
      ret_var := none;
      if(r1='1') then ret_var:=RST; end  if;
		if(r1='0') then
      if(x1="01101011") then ret_var:=k; end  if;
      if(x1="01101110") then ret_var:=n; end  if;
      if(x1="01101001") then ret_var:=i; end  if;
      if(x1="01100110") then ret_var:=f; end  if;
      if(x1="01100101") then ret_var:=e; end  if;
		end if;
      return ret_var;
  end function InputSymbolDecode;

  type OutputSymbol is (y,n);
  signal output_symbol: OutputSymbol;
  function OutputSymbolEncode (op: OutputSymbol)
	return std_logic is
    variable ret_var: std_logic;
  begin
    ret_var := '1';
    if (op = n)  then
      ret_var := '0';
    end if;
    return(ret_var);
  end function OutputSymbolEncode;

  type StateSymbol  is (R,k1,n1,i1,f1);
  signal fsm_state_symbol: StateSymbol;


begin
  -- decode input..
  input_symbol <= InputSymbolDecode(r1,u1);

  -- encode output...
  y1 <= OutputSymbolEncode(output_symbol);

  process(input_symbol, fsm_state_symbol, clk)
     variable nq_var : StateSymbol;
     variable y_var  : OutputSymbol;
  begin
     nq_var := fsm_state_symbol; 
     y_var  := n;

     -- compute next-state, output
     case fsm_state_symbol is
       when k1 =>
          if (input_symbol = none) then
             nq_var := k1;
	     y_var := n;
          end if;
          if (input_symbol = n) then
             nq_var := n1;
	     y_var := n;
          end if;
       when n1 =>
          if (input_symbol = none) then
             nq_var := n1;
	     y_var := n;
          end if;
          if (input_symbol = i) then
             nq_var := i1;
	     y_var := n;
          end if;
       when i1 =>
          if (input_symbol = none) then
             nq_var := i1;
	     y_var := n;
          end if;
          if (input_symbol = f) then
             nq_var :=f1;
	     y_var := n;
          end if;
       when f1 =>
          if (input_symbol = none) then
             nq_var := f1;
	     y_var := n;
          end if;
          if (input_symbol = e) then
             nq_var :=R;
	     y_var := y;
          end if;
			 

			 
			  when R =>
          if (input_symbol = k) then
             nq_var := k1;
             y_var  := n;
          else
             nq_var := R;
				 y_var := n;
          end if;
			 
       when others => null;
     end case;
  
     -- y(k)
     output_symbol <= y_var;
  
     -- q(k+1) = nq(k)
     if(clk'event and clk = '1') then
          if (input_symbol = RST) then
             fsm_state_symbol <= R;
          else
             fsm_state_symbol <= nq_var;
          end if;
     end if;

  end process;

end Behave;


