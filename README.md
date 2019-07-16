## About the component

The PWM Controller outputs a waveform of specified period and duty cycle. Supported output frequency range is from clk_freq/10 to clk_freq/42955326 (1 Mhz to 2.328 Hz if using 100 Mhz clock).

<p align="center">
<img width="600" height="300" src="https://i.imgur.com/qAJjl5F.png">
</p>

**clk** – std_logic input resembling a square wave signal

**enable** – std_logic input which controls whether the component is putting out a processed signal or not. When low, the PWM Controller outputs a low signal. When high, the PWM Controller outputs a pulse width modulate signal.

**Period** – integer input which controls the period of the pwm signal the controller outputs, in number of rising edge clock ticks. Supported range of values is [50, 2147450] that are multiples of 50. The conversion process from input value, in_period, to desired output period, out_period, is the following in nanoseconds:

<p align="center">
out_period = 2*clk_period*in_period
</p>

**Duty Cycle** – integer input which controls the duty cycle of the pwm signal the controller outputs. Supported values are [0, 100]. The duty cycle controls the rising edge of the waveform within the period:

<p align="center">
<img width="300" height="300" src="https://i.imgur.com/OGjqYPb.png">
</p>

## How it works

The controller has an internal counter which keeps track of number of ticks for the period. This internal counter, named “count”, counts a tick upon every clk’s rising edge and resets when a new period is reached. This means that the period of the resultant waveform depends on the frequency of the clock. In order to avoid division by 100 and fractional values in general when factoring in duty cycle, everything is first multiplied by 100.

<img align="left" width="200" height="50" src="https://i.imgur.com/2eDYRCY.png"> To calculate when count needs to be reset, the count is compared to the number of ticks the period is specified to be. Since it will take two rising edges to complete one period—one half for the low part of the signal, and one half for the high part of the signal. To accomplish this, count is multiplied by 50 instead of 100, effectively dividing count by two.

**Note:** count was multiplied by 50 instead of period by 200 because if period was multiplied by 200, the
highest period range would need to be twice lower due to value overflow. It’s best to support the longest
period possible.

<img align="left" width="250" height="30" src="https://i.imgur.com/PP9PaMm.png"> The point at which the rising edge occurs is determined by the period*duty cycle. Once count becomes larger than period*duty cycle, the signal is set high until count reaches period*100, at which point it resets.

## Limitations

Due to integer comparison, there are resolution issues to take account, mainly that count may overshoot a specific period*duty_cycle value. Since count is effectively being compared in multiples of 50, with 50 being the lowest non 0 value count can be, the lowest period can be without count overshooting period*duty_cycle for any possible duty cycle ranging [0, 100] is 50. In fact, only multiples of 50 would guarantee count will not overshoot period*duty_cycle. This corresponds to a period of 1us.

Due to overflow, there is an upper limit to the supported values for period. According VHDL’s specifications, the upper integer limit is 2147483647. Since period is being multiplied by 100, it would be 1/100 of that, 2147483. Finally, since only period values that are multiples of 50 are supported, the highest supported value is 2147450. This corresponds to a period of 429.49 ms @ 100 Mhz clock input.
