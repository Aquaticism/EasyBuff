extends Object
## For handling buffs in a character scene
class_name BuffHandler

var buffs : Dictionary
var inflicted = []
var target


func _init(tg):
	target = tg


# Adds a buff to handle
func load_buff(path : String):
	var buff = load(path)
	buffs[buff.NAME] = buff


# Adds multiple buffs to handle
func load_buffs(paths : PackedStringArray):
	for path in paths:
		load_buff(path)


# Adds all buffs in a directory to handle, excluding ones in subdirectories
func load_buffs_from_dir(path : String):
	var dir = DirAccess.open(path)
	var files = dir.get_files()
	for file in files:
		load_buff(path + "/" + file)


# Adds all buffs in a directory to handle, including ones in subdirectories
func load_buffs_from_dir_recursive(path : String):
	var dir = DirAccess.open(path)
	var files = dir.get_files()
	for file in files:
		load_buff(path + "/" + file)
	var dirs = dir.get_directories()
	for cdir in dirs:
		load_buffs_from_dir_recursive(path + "/" + cdir)


# Inflicts a buff
func inflict(buff : StringName):
	var buffd = buffs[buff].duplicate(true)
	inflicted.append(buffd)
	return buffd


# Removes a specific buff
func expire_at(pos : int):
	var buff = inflicted[pos]
	inflicted.remove_at(pos)
	buff.destroy()


# Removes buffs of a type
func expire(buff : StringName, count : int = 1):
	while count > 0:
		var pos = -1
		for i in range(len(inflicted)):
			if inflicted[i].NAME == buff:
				pos = i
				break
		if pos == -1:
			break
		expire_at(pos)
		count -= 1


# Removes all buffs of a type
func expire_all(buff : StringName):
	while true:
		var pos = -1
		for i in range(len(inflicted)):
			if inflicted[i].NAME == buff:
				pos = i
				break
		if pos == -1:
			break
		expire_at(pos)


# Clear all buffs
func clear(buff : StringName):
	while not inflicted.is_empty():
		expire_at(0)


# Inflicts a buff that triggers based on a timer
func inflict_timerbased(buff : StringName, wait_time : float):
	var buffd = buffs[buff].duplicate(true)
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	buffd.vars["timer_intv"] = timer
	timer.timeout.connect(buffd.trigger.bind(target))
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that expires after a duration
func inflict_duration(buff : StringName, duration : float):
	var buffd = buffs[buff].duplicate(true)
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	buffd.vars["timer_destroy"] = timer
	timer.timeout.connect(expire_at.bind(len(inflicted) - 1))
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that expires after being triggered some times
func inflict_counterbased(buff : StringName, counter : int = 1):
	var buffd = buffs[buff].duplicate(true)
	buffd.vars["counter"] = counter
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that triggers based on a timer and expires after a duration
func inflict_timerbased_duration(buff : StringName, wait_time : float, duration : float):
	var buffd = buffs[buff].duplicate(true)
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	buffd.vars["timer_intv"] = timer
	timer.timeout.connect(buffd.trigger.bind(target))
	var timer2 = Timer.new()
	timer2.wait_time = duration
	timer2.one_shot = true
	buffd.vars["timer_destroy"] = timer2
	timer2.timeout.connect(expire_at.bind(len(inflicted) - 1))
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that expires after being triggers some times and triggers based on a timer
func inflict_counterbased_timerbased(buff : StringName, counter : int, wait_time : float):
	var buffd = buffs[buff].duplicate(true)
	buffd.vars["counter"] = counter
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	buffd.vars["timer_intv"] = timer
	timer.timeout.connect(buffd.trigger.bind(target))
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that expires after being triggered some times or after a duration
func inflict_counterbased_duration(buff : StringName, counter : int, duration : float):
	var buffd = buffs[buff].duplicate(true)
	buffd.vars["counter"] = counter
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	buffd.vars["timer_destroy"] = timer
	timer.timeout.connect(expire_at.bind(len(inflicted) - 1))
	inflicted.append(buffd)
	return buffd


# Inflicts a buff that expires after being triggered some times or after a duration, and triggers based on a timer
func inflict_counterbased_timerbased_duration(buff : StringName, counter : int, wait_time : float, duration : float):
	var buffd = buffs[buff].duplicate(true)
	buffd.vars["counter"] = counter
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	buffd.vars["timer_intv"] = timer
	timer.timeout.connect(buffd.trigger.bind(target))
	var timer2 = Timer.new()
	timer2.wait_time = duration
	timer2.one_shot = true
	buffd.vars["timer_destroy"] = timer2
	timer2.timeout.connect(expire_at.bind(len(inflicted) - 1))
	inflicted.append(buffd)
	return buffd


# Returns the buffs and their counts as a dictionary
func get_inflicted_as_dict():
	var res = {}
	for buff in inflicted:
		if not res.has(buff.name):
			res[buff.name] = 1
		else:
			res[buff.name] += 1
	return res


# Trigger a buff at a position in the inflicted array
func trigger_at(pos : int):
	inflicted[pos].trigger(target)
	if inflicted[pos].vars.has("counter"):
		if inflicted[pos].vars["counter"] == 0:
			inflicted.pop_at(pos).destroy()


# Trigger multiple buffs of a type, will trigger buffs added early first
func trigger_multiple(buff : StringName, count : int = 1):
	while count > 0:
		var pos = -1
		for i in range(len(inflicted)):
			if inflicted[i].NAME == buff:
				pos = i
				break
		if pos == -1:
			break
		trigger_at(pos)
		count -= 1


# Trigger all buffs of a type
func trigger_all(buff : StringName):
	for buffc in inflicted:
		if buffc.NAME == buff:
			buffc.trigger(target)


# Trigger all buffs
func trigger_everything():
	for buff in inflicted:
		buff.trigger(target)
