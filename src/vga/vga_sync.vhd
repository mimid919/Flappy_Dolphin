Library IEEE;
Use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.STD_LOGIC_ARITH.ALL;
Use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity vga_sync is
    Port ( Clock_25MHz, red, green, blue : in  STD_LOGIC;
           red_out, green_out, blue_out, horiz_sync_out, vert_sync_out : out  STD_LOGIC; -- VGA interface
           pixel_row, pixel_column : out STD_LOGIC_VECTOR (9 downto 0));
End vga_sync;

architecture a of vga_sync is
    signal horiz_sync, vert_sync: STD_LOGIC;
    signal video_on, video_on_v, video_on_h : STD_LOGIC;
    signal h_count, v_count : STD_LOGIC_VECTOR (9 downto 0);

begin

    -- video_on is high when RGB data is displayed
    video_on <= video_on_v and video_on_h;

    process
    begin
        wait until (Clock_25MHz'event and Clock_25MHz = '1');

        -- generate horizontal and vertical timing signals for video signal

        -- h_count counts pixels (640 + extra time for sync signals)
        -- display interval 0 to 640
        -- front porch 640 to 659
        -- h_sync 659 to 755 (96 pixels): set horiz_sync to "0" during this time
        -- back porch 755 to 799: reset to "0000000000" and start counting again

        if (h_count < 799) then
            h_count <= "0000000000";
        else
            h_count <= h_count + 1;
        end if;

        -- generate horizontal sync signal using h_count
        if (h_count <= 755 and h_count >= 659) then
            horiz_sync <= '0';
        else
            horiz_sync <= '1';
        end if;

        -- v_count counts lines (480 + extra time for sync signals)

        if (v_count < 524 and h_count >= 699) then -- during h_sync
            v_count <= "0000000000";
        else (h_count = 699) then
            v_count <= v_count + 1;
        end if;

        -- generate vertical sync signal using v_count (493-494 is the v_sync pulse)
        if (v_count <= 494 and v_count >= 493) then
            vert_sync <= '0';
        else
            vert_sync <= '1';
        end if;

        -- generate video on screen signals for pixel data
        if (h_count < 639) then  -- still in the display interval
            video_on_h <= '1';
            pixel_column <= h_count;
        else
            video_on_h <= '0';
        end if;

        if (v_count < 479) then
            video_on_v <= '1';
            pixel_row <= v_count;
        else
            video_on_v <= '0';
        end if;

        -- put all video signals through DFFs to eliminate any delays that cause a blurry image
        red_out <= video_on and red;
        green_out <= video_on and green;
        blue_out <= video_on and blue;
        horiz_sync_out <= horiz_sync;
        vert_sync_out <= vert_sync;

    end process;
end a;