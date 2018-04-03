library verilog;
use verilog.vl_types.all;
entity parte_1 is
    port(
        SW              : in     vl_logic_vector(17 downto 0);
        LEDR            : in     vl_logic_vector(17 downto 0);
        HEX0            : out    vl_logic_vector(0 to 6);
        HEX1            : out    vl_logic_vector(0 to 6);
        KEY             : in     vl_logic_vector(1 downto 0)
    );
end parte_1;
