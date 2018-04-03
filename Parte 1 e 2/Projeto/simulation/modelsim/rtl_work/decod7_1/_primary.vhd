library verilog;
use verilog.vl_types.all;
entity decod7_1 is
    port(
        cin             : in     vl_logic_vector(3 downto 0);
        cout            : out    vl_logic_vector(0 to 6)
    );
end decod7_1;
