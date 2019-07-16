LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;



ENTITY PwmController IS
    PORT
    (    
        clk:         IN STD_LOGIC;
        enable:      IN STD_LOGIC;
        duty_cycle:  IN INTEGER;        -- 0% -> 100%; 0 = high, 100 = low; unsupported for periods < 1 us
        period:      IN INTEGER;        -- actual period = period*clk_period; supported range: 1 us to 2.1474836 ms
        sig_out:     OUT STD_LOGIC
    );
END PwmController;



ARCHITECTURE logic OF PwmController IS

SIGNAL pwm_out  : STD_LOGIC := '0';

BEGIN

    sig_out <= pwm_out;

    core: PROCESS(clk, enable) IS
        VARIABLE count : INTEGER := 0;
    BEGIN
        If(enable = '0') THEN
            pwm_out <= '0';
            count := 0;
        ELSIF(rising_edge(clk)) THEN
            count := count + 1;

            -- multiply by 100 and compare ratio that way to avoid division
            -- multiply count by 50 since we need to divide by 2; there are 2 clock events per period
            IF(count*50 >= period*100) THEN
                pwm_out <= '0';
                count := 0;
            ELSIF(count*50 >= period*duty_cycle) THEN
                pwm_out <= '1';
            END IF;

        END IF;
    END PROCESS;
    
END logic;