# POWER REPORT

```
****************************************
Report : power
Design : vsdcaravel
Version: T-2022.03-SP5
Date   : Wed Dec 17 12:01:15 2025
****************************************


Library(s) Used:

    tsl18fs120_scl_ff (File: /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db)
    tsl18cio250_min (File: /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_min.db)


Operating Conditions: tsl18cio250_min   Library: tsl18cio250_min
Wire Load Model Mode: enclosed

Design        Wire Load Model            Library
------------------------------------------------
vsdcaravel             1000000           tsl18cio250_min
chip_io                4000              tsl18cio250_min
caravel_core           1000000           tsl18cio250_min
constant_block_6       ForQA             tsl18cio250_min
mprj_io                ForQA             tsl18cio250_min
mgmt_core_wrapper      540000            tsl18cio250_min
mgmt_protect           8000              tsl18cio250_min
user_project_wrapper   16000             tsl18cio250_min
caravel_clocking       8000              tsl18cio250_min
digital_pll            8000              tsl18cio250_min
housekeeping           140000            tsl18cio250_min
mprj_io_buffer         ForQA             tsl18cio250_min
gpio_defaults_block_1803_0
                       ForQA             tsl18cio250_min


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


  Cell Internal Power  =  39.1889 mW   (51%)
  Net Switching Power  =  37.6882 mW   (49%)
                         ---------
Total Dynamic Power    =  76.8771 mW  (100%)

Cell Leakage Power     =   1.1350 uW

Information: report_power power group summary does not include estimated clock tree power. (PWR-789)

                 Internal         Switching           Leakage            Total
Power Group      Power            Power               Power              Power   (   %    )  Attrs
--------------------------------------------------------------------------------------------------
io_pad             1.7329        3.5437e-03        5.7237e+03            1.7364  (   2.26%)
memory             0.0000            0.0000            0.0000            0.0000  (   0.00%)
black_box          0.0000            0.1470           62.7200            0.1470  (   0.19%)
clock_network      0.0000            0.0000            0.0000            0.0000  (   0.00%)  i
register           0.0000            0.0000            0.0000            0.0000  (   0.00%)
sequential        33.9241            0.2660        7.1946e+05           34.1909  (  44.49%)
combinational      3.5311           37.2365        4.0971e+05           40.7695  (  53.06%)
--------------------------------------------------------------------------------------------------
Total             39.1881 mW        37.6530 mW     1.1350e+06 pW        76.8437 mW

```