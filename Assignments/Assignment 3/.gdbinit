define wregs
  watch $eax
  watch $ebx
  watch $ecx
  watch $edx
  watch (int)return
end

define dfloat
  tui reg float
end

define wc
  watch (int)loader
  watch (int)return
  watch (int)LSFR_register
end

define active_drone
  p /x (int)(active_Drone)
  x /x ($active_Drone)
end

define start
  run 5 8 10 30 15019
  layout regs
end

define scale
  b Scale.after_random
end
define speed
  b updateSpeed.compare
end

define board
  b printBoard
  b printBoard.loop_print
  b printBoard.init
end

define after
  b main.after_initialize
end

define target
  b createTarget
end

define free
  b free_co_routines
  b free_co_routines.init
  b free_co_routines.loop
  b free_co_routines.end
  end

define sche
  b schedule
  b schedule.loop
  b schedule.drone_active
  b schedule.skip
  b schedule.printer
  b schedule.check_Rounds
  b schedule.Round_end
  b schedule.increment_i
  b schedule.finish_game
  b schedule.end
end
  
define drone
  b Play
  b initDrone
  b updateSpeed
  b updateSpeed.end
  b updateAngle
  b getRandomSpeed
  b getRandomAngle
  b getRandomPosition
  
end

define setb
b arguments.after_print
b intializeDrones 
b intializeDrones.afer_alloc_1 
b intializeDrones.afer_alloc_2 
b intializeDrones.afer_alloc_3
b intializeDrones.loop 
b intializeDrones.end 
b random 
b random.set_1 
b random.set_0 
b random.end 
b Scale
b getRandomSpeed
b getRandomAngle
b getRandomPosition
end

define bdrone
  b intializeDrones 
  b intializeDrones.afer_alloc_1 
  b intializeDrones.afer_alloc_2 
  b intializeDrones.afer_alloc_3
  b intializeDrones.loop 
  b intializeDrones.end 
end

define stt
  echo eax:
  p /x $eax
  echo ebx:
  p /x $ebx
  echo ecx:
  p /x $ecx
  echo edx:
  p /x $edx
  echo return:
  p /x (int)(return)
  echo co_routineArray:
  p /x (int)(co_routineArray)
  echo drone_details_Array:
  p /x (int)(drone_details_Array)
end
