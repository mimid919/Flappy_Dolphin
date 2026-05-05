library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level is
    port ( Clock_50MHz : in std_logic;      -- 50MHz clock input
           Red, Green, Blue : in std_logic; -- RGB input signals
           Red_out, Green_out, Blue_out : out std_logic; -- RGB output signals for VGA
           H_Sync_out, V_Sync_out : out std_logic); -- Sync output signals for VGA
end top_level;

architecture behaviour of top_level is

    signal Clock_25MHz : std_logic := '0'; -- 25MHz clock signal for VGA timing
    signal red_temp, green_temp, blue_temp : std_logic;
    signal Pixel_Row_temp, Pixel_Column_temp : std_logic_vector(9 downto 0); -- Pixel position signals

    component vga_sync is
        port ( Clock_25MHz, red, green, blue : in  std_logic;
               red_out, green_out, blue_out, horiz_sync_out, vert_sync_out : out  std_logic;
               pixel_row, pixel_column : out std_logic_vector (9 downto 0));
    end component;

begin

    V: vga_sync port map (
        Clock_25MHz => Clock_25MHz,
        red => SW,
        green => Green,
        blue => Blue,
        red_out => Red_out,
        green_out => Green_out,
        blue_out => Blue_out,
        horiz_sync_out => H_Sync_out,
        vert_sync_out => V_Sync_out,
        pixel_row => Pixel_Row_temp,
        pixel_column => Pixel_Column_temp
    );

    process (Clock_50MHz)
    begin
         -- every rising edge of the input clock, increment the count
         if rising_edge(Clock_50MHz) then
             Clock_25MHz <= not Clock_25MHz; -- toggle the output clock to create 25MHz
         end if;       
      end process;
      
    --- Write code for VGA sync mapping etc.

end behaviour;