// Donk Project
// Copyright (c) 2021 Warriorstar Orion <orion@snowfrost.garden>
// SPDX-License-Identifier: MIT

/obj/chair
  name = "red office chair"

/proc/main()
  var/message = "This is a string."
  var/c = new/obj/chair()
  world << "Hello, world! [message] There is a [c.name]."
