define wregs
  watch $eax
  watch $ebx
  watch $ecx
  watch $edx
end

define setb
  b infector
end

define stt
  echo eax:
  p $eax
  echo ebx:
  p $ebx
  echo ecx:
  p $ecx
  echo edx:
  p $edx
end
