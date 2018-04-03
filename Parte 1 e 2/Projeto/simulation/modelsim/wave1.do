view wave 
wave clipboard store
wave create -driver freeze -pattern clock -initialvalue HiZ -period 100ps -dutycycle 50 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/clock 
wave create -driver freeze -pattern counter -startvalue 0 -endvalue 1 -type Range -direction Up -period 125ps -step 1 -repeat forever -starttime 0ps -endtime 1000ps sim:/MemoryBlock/wren 
wave create -driver freeze -pattern counter -startvalue 00000 -endvalue 00010 -type Range -direction Up -period 225ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/address 
WaveExpandAll -1
wave create -driver freeze -pattern random -initialvalue zzzzzzzz -period 250ps -random_type Uniform -seed 5 -range 7 0 -starttime 0ps -endtime 1000ps sim:/MemoryBlock/data 
WaveExpandAll -1
wave modify -driver freeze -pattern random -initialvalue zzzzzzzz -period 200ps -random_type Uniform -seed 5 -range 7 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/data 
wave modify -driver freeze -pattern counter -startvalue 00000 -endvalue 00010 -type Range -direction Up -period 200ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/address 
wave modify -driver freeze -pattern counter -startvalue 00000 -endvalue 00010 -type Range -direction Up -period 175ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/address 
wave modify -driver freeze -pattern counter -startvalue 00000 -endvalue 00010 -type Range -direction Up -period 250ps -step 1 -repeat forever -range 4 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/address 
wave modify -driver freeze -pattern random -initialvalue zzzzzzzz -period 150ps -random_type Uniform -seed 5 -range 7 0 -starttime 0ps -endtime 1000ps Edit:/MemoryBlock/data 
WaveCollapseAll -1
wave clipboard restore
