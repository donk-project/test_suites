/datum/foo_obj
	var/foo = 3

/datum/foo_obj/proc/Increment()
	foo += 1

/datum/foo_obj/bar_obj
	var/bar = 4

/datum/foo_obj/bar_obj/Increment()
	..()
	bar += 1

baz_obj
	parent_type = /datum/foo_obj/bar_obj
	var/baz = 5

baz_obj/Increment()
	..()
	baz += 1

mob/Login()
	..()
	world << "Hello world!"

// mob/Login()
/proc/main()
	// ..()
	var/baz_obj/my_baz = new
	world << "Pre-increment: [my_baz.foo] [my_baz.bar] [my_baz.baz]"
	my_baz.Increment()
	world << "Post-increment: [my_baz.foo] [my_baz.bar] [my_baz.baz]"
