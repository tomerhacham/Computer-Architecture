define wregs
  watch $eax
  watch $ebx
  watch $ecx
  watch $edx
  watch (int)return
end

def wspp
  watch (int)SPP
end

define setb
b pop_operand
b push_operand

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
  echo SPP:
  p /x (int)(SPP)
end
