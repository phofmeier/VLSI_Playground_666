
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name VGA_processor_test -dir "C:/Users/feixn/Desktop/VLSI/Project_Group3/VGA-Controller/VGA_processor_test/ise_project/planAhead_run_3" -part xc3s500efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/feixn/Desktop/VLSI/Project_Group3/VGA-Controller/VGA_processor_test/ise_project/processor_toplevel.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/feixn/Desktop/VLSI/Project_Group3/VGA-Controller/VGA_processor_test/ise_project} }
set_property target_constrs_file "C:/Users/feixn/Desktop/VLSI/Project_Group3/VGA-Controller/VGA_processor_test/processor_toplevel.ucf" [current_fileset -constrset]
add_files [list {C:/Users/feixn/Desktop/VLSI/Project_Group3/VGA-Controller/VGA_processor_test/processor_toplevel.ucf}] -fileset [get_property constrset [current_run]]
link_design
