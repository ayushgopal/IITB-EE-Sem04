library ieee;
use ieee.std_logic_1164.all;

entity PTN911G is
   port (u: in std_logic_vector(7 downto 0); y: out std_logic; r, clk: in std_logic);
end entity;

architecture Behave of PTN911G is
  type InputSymbol  is (RST, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, SP, nota);
  signal input_symbol: InputSymbol;

  function InputSymbolDecode (r: std_logic, u: std_logic_vector(7 downto 0)) 
	return  InputSymbol is
      variable ret_var: InputSymbol;
  begin
      ret_var := RST;
      if(r='0') then
	   case u is
		when '01100001' => ret_var := a;
		when '01100010' => ret_var := b;
		when '01100011' => ret_var := c;
		when '01100100' => ret_var := d;
		when '01100101' => ret_var := e;
		when '01100110' => ret_var := f;
		when '01100111' => ret_var := g;
		when '01101000' => ret_var := h;
		when '01101001' => ret_var := i;
		when '01101010' => ret_var := j;
		when '01101011' => ret_var := k;
		when '01101100' => ret_var := l;
		when '01101101' => ret_var := m;
		when '01101110' => ret_var := n;
		when '01101111' => ret_var := o;
		when '01110000' => ret_var := p;
		when '01110001' => ret_var := q;
		when '01110010' => ret_var := r;
		when '01110011' => ret_var := s;
		when '01110100' => ret_var := t;
		when '01110101' => ret_var := u;
		when '01110110' => ret_var := v;
		when '01110111' => ret_var := w;
		when '01111000' => ret_var := x;
		when '01111001' => ret_var := y;
		when '01111010' => ret_var := z;
		when '00100000' => ret_var := SP;
		when others => ret_var := nota;
	  else ret_var := RST;
	  end if;
     return ret_var;
  end function InputSymbolDecode;

  type OutputSymbol is (NO,YES);
  signal output_symbol: OutputSymbol;
  function OutputSymbolEncode (x: OutputSymbol)
	return std_logic is
    variable ret_var: std_logic;
  begin
    ret_var := nota;
    if (x = YES)  then
      ret_var := '1';
    end if;
    return(ret_var);
  end function OutputSymbolEncode;

  type StateSymbol  is (O,A,B);
  signal fsm_state_symbol: StateSymbol;


begin
  -- decode input..
  input_symbol <= InputSymbolDecode(r,u);

  -- encode output...
  y <= OutputSymbolEncode(output_symbol);

  process(input_symbol, fsm_state_symbol, clk)
     variable nq_var : StateSymbol;
     variable y_var  : OutputSymbol;
  begin
     nq_var := fsm_state_symbol; 
     y_var  := NO;

     -- compute next-state, output
     case fsm_state_symbol is
       when O =>
          if (input_symbol = g) then
             nq_var := A;
          else
             nq_var := O;
          end if;
       when A =>
          if (input_symbol = u) then
             nq_var := B;
          else
             nq_var := A;
          end if;
       when B =>
          if (input_symbol = n) then
             nq_var := O;
             y_var  := YES;
          else
             nq_var := B;
          end if;
       when others => null;
     end case;
  
     -- y(k)
     output_symbol <= y_var;
  
     -- q(k+1) = nq(k)
     if(clk'event and clk = '1') then
          if (input_symbol = RST) then
             fsm_state_symbol <= A;
          else
             fsm_state_symbol <= nq_var;
          end if;
     end if;

  end process;

end Behave;