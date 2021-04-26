#define BENCHT(NAME, ITERS, CODE) \
do{ \
  var/s = world.tick_usage ;\
  for(var/i = 1 to (ITERS)) {\
    CODE ;\
  } ;\
  var/e = world.tick_usage ;\
  world.log << "[NAME]: [(e-s) * world.tick_lag] ms" ;\
} while(0)

var/list/L = list(1,2,3,4,5,6,7,8,9,10)

/proc/test1()
    var/max = 0
    for(var/i in L)
        if(max < i)
            max = i
    return max

/proc/test2()
    return max(L)

/proc/main()
    BENCHT("test1", 100000, test1())
    BENCHT("test2", 100000, test2())
