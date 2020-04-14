template debug*(data: untyped) = 
  when not defined(release):
    echo data