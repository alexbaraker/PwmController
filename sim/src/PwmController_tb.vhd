LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

LIBRARY work;

ENTITY PwmController_tb IS
END PwmController_tb;



ARCHITECTURE logic OF PwmController_tb IS

    SIGNAL clk              : std_logic := '0';
    SIGNAL enable           : std_logic := '0';
    SIGNAL duty_cycle       : integer   := 50;
    SIGNAL period           : integer   := 2;
    SIGNAL sig_out          : std_logic;

    constant clk_period     : time := 10ns;  -- 100 Mhz clk
    

    COMPONENT PwmController IS
        PORT
        (    
            clk:         IN STD_LOGIC;
            enable:      IN STD_LOGIC;
            duty_cycle:  IN INTEGER;
            period:      IN INTEGER;
            sig_out:     OUT STD_LOGIC
        );
    END COMPONENT;  


    PROCEDURE test_case(
        SIGNAL enable: OUT std_logic;
        SIGNAL out_period: OUT integer;
        SIGNAL out_duty_cycle: OUT integer;
        constant in_period: integer;
        constant in_duty_cycle: integer) 
    IS 
        VARIABLE elapsed_time : time := 0ns;
    BEGIN
    
        enable <= '1';
        out_period <= in_period;
        out_duty_cycle <= in_duty_cycle;

        IF (period*clk_period*(100 - duty_cycle))/100 = 0ns THEN
            ASSERT sig_out = '1' report "Waveform not high; Period =" & integer'image(period) & "   Duty Cycle = " & integer'image(duty_cycle) severity error;
    
        ELSIf (period*clk_period*duty_cycle)/100 = 0ns THEN
            ASSERT sig_out = '0' report "Waveform not low; Period =" & integer'image(period) & "   Duty Cycle = " & integer'image(duty_cycle) severity error;
    
        ELSE
            -- Discard the first cycle due change in period or duty cycle
            WAIT UNTIL sig_out = '0';
            WAIT UNTIL sig_out = '1';

            REPORT "High part required to elapse " & time'image(time((period*clk_period*(100 - duty_cycle))/50));
            elapsed_time := now;
            WAIT UNTIL sig_out = '0';
            elapsed_time := now - elapsed_time;
            ASSERT elapsed_time = (period*clk_period*(100 - duty_cycle))/50
                REPORT "High part of waveform elapsed " & time'image(elapsed_time) severity error;

            REPORT "Low part required to elapse " & time'image(time((period*clk_period*duty_cycle)/50));
            elapsed_time := now;
            WAIT UNTIL sig_out = '1';
            elapsed_time := now - elapsed_time;
            ASSERT elapsed_time = (period*clk_period*duty_cycle)/50
                REPORT "Low part of waveform elapsed " & time'image(elapsed_time) severity error;
    
        END IF;

    END PROCEDURE test_case;
    
BEGIN

    simulation: PROCESS 
    IS
    BEGIN

        report LF & LF & "Testing enable low . . .";
        enable <= '0';

        WAIT UNTIL clk = '0';
        WAIT FOR clk_period;
        assert sig_out = '0' report "enable is low; sig_out is not low" severity error;

        ----

-- Basic stuff to make sure period gets correctly applied

        report LF & LF & "Testing 20ns period @ 50% duty cycle . . .";
        test_case(enable, period, duty_cycle, 1, 50);

        report LF & LF & "Testing 40ns period @ 50% duty cycle . . .";
        test_case(enable, period, duty_cycle, 2, 50);

        report LF & LF & "Testing 60ns period @ 50% duty cycle . . .";
        test_case(enable, period, duty_cycle, 3, 50);

        report LF & LF & "Testing 80ns period @ 50% duty cycle . . .";
        test_case(enable, period, duty_cycle, 4, 50);
        
        report LF & LF & "Testing 100ns period @ 50% duty cycle . . .";
        test_case(enable, period, duty_cycle, 5, 50);

-- Start testing duty cycle limits

        -- Will fail due to inadaquate clock resolution for period and duty cycle given
        report LF & LF & "Testing 100ns period @ 25% duty cycle   [ WILL FAIL ] . . .";
        test_case(enable, period, duty_cycle, 5, 45);

        report LF & LF & "Testing 200ns period @ 25% duty cycle . . .";
        test_case(enable, period, duty_cycle, 10, 5);

        report LF & LF & "Testing 200ns period @ 15% duty cycle . . .";
        test_case(enable, period, duty_cycle, 10, 15);

        report LF & LF & "Testing 200ns period @ 10% duty cycle . . .";
        test_case(enable, period, duty_cycle, 10, 10);

        report LF & LF & "Testing 200ns period @ 5% duty cycle . . .";
        test_case(enable, period, duty_cycle, 10, 5);

        -- Will fail due to inadaquate clock resolution for period and duty cycle given
        report LF & LF & "Testing 200ns period @ 4% duty cycle   [ WILL FAIL ] . . .";
        test_case(enable, period, duty_cycle, 10, 4);

        -- Will fail due to inadaquate clock resolution for period and duty cycle given
        report LF & LF & "Testing 400ns period @ 4% duty cycle   [ WILL FAIL ] . . .";
        test_case(enable, period, duty_cycle, 20, 4);

        -- Will fail due to inadaquate clock resolution for period and duty cycle given
        report LF & LF & "Testing 500ns period @ 1% duty cycle   [ WILL FAIL ] . . .";
        test_case(enable, period, duty_cycle, 25, 1);

        -- Smallest case 1% duty cycle succeeds. Every supported period must be a multiple of this
        report LF & LF & "Testing 1us period @ 1% duty cycle . . .";
        test_case(enable, period, duty_cycle, 50, 1);

        -- Will fail due to inadaquate clock resolution for period and duty cycle given (not multiple of 1us)
        report LF & LF & "Testing 1.6us period @ 4% duty cycle . . .   [ WILL FAIL ] ";
        test_case(enable, period, duty_cycle, 80, 4);

        report LF & LF & "Testing 2us period @ 1% duty cycle . . .";
        test_case(enable, period, duty_cycle, 100, 1);

        report LF & LF & "Testing 3us period @ 1% duty cycle . . .";
        test_case(enable, period, duty_cycle, 150, 1);


-- Test random 1us multiples for random >50% duty cycles

        report LF & LF & "Testing 242us period @ 86% duty cycle . . .";
        test_case(enable, period, duty_cycle, 14100, 86);

        report LF & LF & "Testing 123us period @ 65% duty cycle . . .";
        test_case(enable, period, duty_cycle, 6150, 86);

        report LF & LF & "Testing 312us period @ 99% duty cycle . . .";
        test_case(enable, period, duty_cycle, 15600, 99);

        -- Halt
        WAIT;
    END PROCESS; 

    -- clock process
    clock: PROCESS BEGIN
        clk <= not clk;
        WAIT FOR clk_period/2;
    END PROCESS; 


    uut: PwmController  
    PORT MAP
    (
        clk        => clk,
        enable     => enable,
        duty_cycle => duty_cycle,
        period     => period,
        sig_out    => sig_out
    );
  
end logic;