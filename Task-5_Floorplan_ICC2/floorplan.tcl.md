# FLOORPLAN TCL SCRIPT

```bash
############################################################
# Task 5 – SoC Floorplanning Using ICC2 (Floorplan Only)
# Author  : Divya Darshan VR (VSD)
# Design  : Raven_Wrapper
# Tool    : Synopsys ICC2 2022.12
############################################################


puts "RM-info : Running script [info script]\n"

# ---------------------------------------------------------
# 1. Common setup
# ---------------------------------------------------------
source -echo ./icc2_common_setup.tcl
source -echo ./icc2_dp_setup.tcl

# ---------------------------------------------------------
# 2. Clean old design library (MANDATORY)
# ---------------------------------------------------------
if {[file exists ${WORK_DIR}/${DESIGN_LIBRARY}]} {
    puts "RM-info : Removing old design library"
    file delete -force ${WORK_DIR}/${DESIGN_LIBRARY}
}

# ---------------------------------------------------------
# 3. Create NDM Library (TECH + LEF)
# ---------------------------------------------------------
set create_lib_cmd "create_lib ${WORK_DIR}/${DESIGN_LIBRARY}"

if {[file exists [which $TECH_FILE]]} {
    lappend create_lib_cmd -tech $TECH_FILE
} elseif {$TECH_LIB != ""} {
    lappend create_lib_cmd -use_technology_lib $TECH_LIB
}

lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY

puts "RM-info : $create_lib_cmd"
eval $create_lib_cmd

# ---------------------------------------------------------
# 4. Read synthesized netlist
# ---------------------------------------------------------
puts "RM-info : Reading synthesized Verilog"
read_verilog \
    -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} \
    -top ${DESIGN_NAME} \
    ${VERILOG_NETLIST_FILES}

# ---------------------------------------------------------
# 5. Technology setup (routing directions, sites)
# ---------------------------------------------------------
if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)} {
    if {[file exists [which $TCL_TECH_SETUP_FILE]]} {
        puts "RM-info : Sourcing $TCL_TECH_SETUP_FILE"
        source -echo $TCL_TECH_SETUP_FILE
    }
}

# ---------------------------------------------------------
# 6. Parasitic tech (TLU+)
# ---------------------------------------------------------
if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
    puts "RM-info : Sourcing parasitic tech file"
    source -echo $TCL_PARASITIC_SETUP_FILE
}

# ---------------------------------------------------------
# 7. Routing layer limits
# ---------------------------------------------------------
if {$MAX_ROUTING_LAYER != ""} {
    set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
}
if {$MIN_ROUTING_LAYER != ""} {
    set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER
}

# ---------------------------------------------------------
# 8. Pre-floorplan sanity check
# ---------------------------------------------------------
if {$CHECK_DESIGN} {
    redirect -file ${REPORTS_DIR_INIT_DP}/check_design.pre_floorplan {
        check_design -checks dp_pre_floorplan
    }
}

# ---------------------------------------------------------
# 9. FLOORPLAN (PAD-RING SAFE)
# ---------------------------------------------------------
puts "RM-info : Initializing floorplan with pad ring margin"

initialize_floorplan \
    -control_type die \
    -boundary {{0 0} {3588 5188}} \
    -core_offset {300 300 300 300}

# ---------------------------------------------------------
# 10. CREATING A BLOCKAGE
# ---------------------------------------------------------
create_placement_blockage -name CORNER_BL -type hard \
  -boundary {{0 0} {300 300}}

create_placement_blockage -name CORNER_BR -type hard \
  -boundary {{3288 0} {3588 300}}

create_placement_blockage -name CORNER_TL -type hard \
  -boundary {{0 4888} {300 5188}}

create_placement_blockage -name CORNER_TR -type hard \
  -boundary {{3288 4888} {3588 5188}}
# ---------------------------------------------------------
# 11. Save floorplan
# ---------------------------------------------------------

puts "\nRM-info : =============================================="
puts "RM-info : Floorplan stage completed successfully"
puts "RM-info : Design      : Raven Wrapper"
puts "RM-info : Owner       : Divya Darshan"
puts "RM-info : Tool        : Synopsys IC Compiler II"
puts "RM-info : Status      : PASS"
puts "RM-info : ==============================================\n"



save_block -force -label floorplan
save_lib -all
```