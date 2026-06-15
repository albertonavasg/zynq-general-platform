#*****************************************************************************************
# Vivado (TM) v2024.1 (64-bit)
#
# zgp.tcl: Tcl script for re-creating project 'zgp'
#
#*****************************************************************************************

################################################################################
# Names
################################################################################

set project_name "zgp"

set bd_name "zynq_ps"

################################################################################
# Paths
################################################################################

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

set src_dir $origin_dir/../src

set path_design    $src_dir/hdl/design
set path_testbench $src_dir/hdl/testbench

set path_bd      $src_dir/bd
set path_constrs $src_dir/constrs
set path_ip      $src_dir/ip


# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/$project_name"]"

################################################################################
# Project
################################################################################

# Create project
create_project $project_name $origin_dir/$project_name -part xc7z020clg400-1 -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
# None

# Set project properties
set obj [current_project]
set_property "part" "xc7z020clg400-1" $obj
set_property "target_language" "VHDL" $obj
set_property "simulator_language" "Mixed" $obj
set_property "enable_vhdl_2008" "1" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "xpm_libraries" "XPM_CDC XPM_MEMORY" $obj

################################################################################
# Constraints
################################################################################

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

add_files -fileset constrs_1 $path_constrs/pynq_z2_zgp.xdc

################################################################################
# Sources
################################################################################

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Create block design
source $path_bd/${bd_name}.tcl

# Validate block design
set bd_file [get_files *${bd_name}.bd]
open_bd_design $bd_file
regenerate_bd_layout
validate_bd_design -force
save_bd_design

# Generate and add the wrapper file
set wrapper [make_wrapper -files $bd_file -top]
add_files -norecurse $wrapper

## RTL

# Top
add_files -fileset sources_1 $path_design/zgp_top.vhd

# AXI Bridge
add_files -fileset sources_1 $path_design/axi_bridge.vhd

################################################################################
# Simulation
################################################################################

if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

add_files -fileset sim_1 $path_testbench/axi_bridge_tb.vhd

################################################################################
# Last details
################################################################################

# Update the compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1