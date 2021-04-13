
/proc/Hazards()
	sleep(100)
	var/i = rand(1, 4)
	var/msg = "There have been no environmental hazards recently."
	if (i == 1)
		msg = "A psy-storm has recently occurred in the Zone."
	else if (i == 2)
		msg = "An emission has recently occurred in the Zone."

	return msg

/proc/Weather()
	while(1)
		world << "The sun rises in the east."
		sleep(60)
		world << "The noon day sun rises high in the sky."
		sleep(60)
		world << "The sun sinks low in the west."
		sleep(120)


/proc/FormatReport(var/report)
	set name = "Format Report"
	return "Hazard Report: [report]"

/proc/main()
	spawn Weather()
	world << "Fetching latest hazard report, please wait..."
	var/report = Hazards()
	world << "[FormatReport(report)]"
	shutdown()
