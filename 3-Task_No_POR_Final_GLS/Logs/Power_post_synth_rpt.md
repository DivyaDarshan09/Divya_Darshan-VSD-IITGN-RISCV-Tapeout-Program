# POWER REPORT

**NOTE**:

As this design uses the SCL-180 standard-cell and I/O pad libraries, some technology-specific implementation details are intentionally abstracted and omitted from the RTL description.

```
Information: Propagating switching activity (low effort zero delay simulation). (PWR-6)

****************************************
            AREA REPORT
****************************************
****************************************
        DIVYA DARSHAN - NO POR
****************************************
****************************************
Report : power
        -analysis_effort low
Design : vsdcaravel
Version: T-2022.03-SP5
Date   : Tue Dec 16 15:23:43 2025
****************************************


Library(s) Used: SCL


Operating Conditions: tsl18cio250_min   Library: tsl18cio250_min
Wire Load Model Mode: enclosed
----------------------------------------------
Global Operating Voltage = 1.98 
Power-specific unit information :
    Voltage Units = 1V
    Capacitance Units = 1.000000pf
    Time Units = 1ns
    Dynamic Power Units = 1mW    (derived from V,C,T units)
    Leakage Power Units = 1pW


Attributes
----------
i - Including register clock pin internal power


  Cell Internal Power  =  38.6165 mW   (50%)
  Net Switching Power  =  37.9689 mW   (50%)
                         ---------
Total Dynamic Power    =  76.5854 mW  (100%)

Cell Leakage Power     =   1.1292 uW

Information: report_power power group summary does not include estimated clock tree power. (PWR-789)

                 Internal         Switching           Leakage            Total
Power Group      Power            Power               Power              Power   (   %    )  Attrs
--------------------------------------------------------------------------------------------------
io_pad             0.0000            0.0000            0.0000            0.0000  (   0.00%)
memory             0.0000            0.0000            0.0000            0.0000  (   0.00%)
black_box          0.0000            0.1470           62.7200            0.1470  (   0.19%)
clock_network      0.0000            0.0000            0.0000            0.0000  (   0.00%)  i
register           0.0000            0.0000            0.0000            0.0000  (   0.00%)
sequential        35.0847            0.4024        7.1946e+05           35.4883  (  46.36%)
combinational      3.5311           37.3879        4.0971e+05           40.9209  (  53.45%)
--------------------------------------------------------------------------------------------------
Total             38.6157 mW        37.9372 mW     1.1292e+06 pW        76.5561 mW

```
