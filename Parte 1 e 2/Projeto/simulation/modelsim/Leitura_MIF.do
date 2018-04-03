onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MemoryBlock/clock
add wave -noupdate /MemoryBlock/address
add wave -noupdate /MemoryBlock/address
add wave -noupdate /MemoryBlock/wren
add wave -noupdate /MemoryBlock/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {262 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 120
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {942 ps}
view wave 
wave clipboard store
wave create -driver freeze -pattern clock -initialvalue HiZ -period 200ps -dutycycle 50 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/clock 
wave create -driver freeze -pattern counter -startvalue 00000 -endvalue 00011 -type Range -direction Up -period 50ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/address 
WaveExpandAll -1
wave modify -driver freeze -pattern counter -startvalue 00000 -endvalue 00011 -type Range -direction Up -period 300ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/address 
wave modify -driver freeze -pattern counter -startvalue 00000 -endvalue 00011 -type Range -direction Up -period 250ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/address 
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/wren 
WaveCollapseAll -1
wave clipboard restore
