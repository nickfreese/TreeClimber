extends Node2D

var data

# load a json schema file
func load(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	var data = JSON.parse_string(content)
	self.data = data;
	return data
	

func setState(id, value):
	self.data.state[id] = value
	return self.data.state[id]

func getState(id):
	return self.data.state[id]

	
func getText():
	return "test text"
	
	
func processText(text):
	var regex: RegEx = RegEx.new()
	regex.compile("{{\\s*([^}]*)}}")
	var results = regex.search_all(text)

	for result in results:
		if self.data.state.has(result.get_string(1)):
			var newText = self.data.state[result.get_string(1)]
			if newText is int or newText is float:
				newText = str(newText)
			text = text.replace(result.get_string(0), newText)
	return text

func getActiveContent():
	for c in self.data.map:
		if c.id == self.data.active:
			return c
	return null
	
	
func moveToNextContent():
	# set state from previous content before continuing
	for c in self.data.map:
		if c.id == self.data.active:
			self.data.content_seen.append(self.data.active)
			if "state_id" in c and "state_value" in c:
				for i in c.state_id.size():
					var meets_conditions = true
					if c.has('state_conditions'):
						if self.meetsStateConditions(c.state_conditions[i]):
							meets_conditions = true
						else:
							meets_conditions = false
					if meets_conditions:
						if c.has('state_add'):
							if  c.state_add[i]:
								self.data.state[c.state_id[i]] = self.data.state[c.state_id[i]]+c.state_value[i]
							else:
								self.data.state[c.state_id[i]] = c.state_value[i]
						else:
							self.data.state[c.state_id[i]] = c.state_value[i]
				
	
	# get next and set active
	var content = getNextContent()
	if content == null:
		self.data.active = null
		return null
	self.data.active = content.id
	self.data.active_interaction = null
	return content
	
func getNextContent():
	for content in self.data.map:
		if areDepsSatisfied(content.deps):
			if hasSeenContent(content.id) and content.once == false:
				return content
			elif not hasSeenContent(content.id):
				return content
	return null


func getAllAvailableContent():
	var contentList = []
	for content in self.data.map:
		if areDepsSatisfied(content.deps):
			if hasSeenContent(content.id) and content.once == false:
				contentList.append(content)
			elif not hasSeenContent(content.id):
				contentList.append(content)
	
	return contentList
	
		
	
func areDepsSatisfied(deps):
	for dep in deps:
		if dep.type == "content_id":
			if hasSeenContent(dep.id) != true:
				return false
		if  dep.type == "state_id":
			if dep.id not in self.data.state:
				return false
			else:
				if not dep.value == self.data.state[dep.id]:
					return false
					
	return true
	
func meetsStateConditions(condition):
	
	var orGroups = {}
	var andGroups = {}
	var orGroupsResults = {}
	var andGroupsResults = {}
	for index in condition.group.size():
		if condition.group[index].type == "and":
			if not andGroups.has(condition.group[index].id):
				andGroups[condition.group[index].id] = []
			andGroups[condition.group[index].id].append({
				"state_id":condition.state_id[index],
				"state_value":condition.state_value[index],
				"operator":condition.operator[index]
			})
		else:
			if not orGroups.has(condition.group[index].id):
				orGroups[condition.group[index].id] = []
			orGroups[condition.group[index].id].append({
				"state_id":condition.state_id[index],
				"state_value":condition.state_value[index],
				"operator":condition.operator[index]
			})
		
	for key in orGroups:
		orGroupsResults[key] = false
		for i in orGroups[key].size():
			if self.processCondition(self.data.state[orGroups[key][i].state_id], orGroups[key][i].state_value, orGroups[key][i].operator):
				orGroupsResults[key] = true
				
	for key in andGroups:
		andGroupsResults[key] = false
		for i in andGroups[key].size():
			andGroupsResults[key] = self.processCondition(self.data.state[andGroups[key][i].state_id], andGroups[key][i].state_value, andGroups[key][i].operator)

	## finally we check if everything came up true
	var alltrue = false
	for key in orGroupsResults:
		alltrue = orGroupsResults[key]
	for key in andGroupsResults:
		alltrue = andGroupsResults[key]
		
	if alltrue:
		return true
	return false
	
	
			
func processCondition(arg1, arg2, operator):
	if operator == "==":
		if arg1 == arg2:
			return true
	if operator == ">":
		if arg1 > arg2:
			return true
	if operator == "<":
		if arg1 < arg2:
			return true
	if operator == "<=":
		if arg1 <= arg2:
			return true
	if operator == ">=":
		if arg1 >= arg2:
			return true
	if operator == "!=":
		if arg1 != arg2:
			return true
	if operator == "like":
		if arg1.contains(arg2):
			return true
	if operator == "not like":
		if not arg1.contains(arg2):
			return true
	return false
			

func hasSeenContent(id):
	for n in self.data.content_seen:
		if n == id:
			return true
	return false
	
	
	
#
# Interactions
#
#

func goToNextInteraction():
	var content = self.getActiveContent()
	if self.data.active_interaction == null:
		self.data.active_interaction = 0
	else:
		if content.interactions.size()-1 >= self.data.active_interaction:
			if "state_id" in content.interactions[self.data.active_interaction]:
				for e in content.interactions[self.data.active_interaction].state_id.size():
					
					var meets_conditions = true
					if content.interactions[self.data.active_interaction].has('state_conditions'):
						if self.meetsStateConditions(content.interactions[self.data.active_interaction].state_conditions[e]):
							meets_conditions = true
						else:
							meets_conditions = false
					if meets_conditions:
						if content.interactions[self.data.active_interaction].has('state_add'):
							if  content.interactions[self.data.active_interaction].state_add[e]:
								self.data.state[content.interactions[self.data.active_interaction].state_id[e]] = self.data.state[content.interactions[self.data.active_interaction].state_id[e]]+content.interactions[self.data.active_interaction].state_value[e]
							else:
								self.data.state[content.interactions[self.data.active_interaction].state_id[e]] = content.interactions[self.data.active_interaction].state_value[e]
						else:
							self.data.state[content.interactions[self.data.active_interaction].state_id[e]] = content.interactions[self.data.active_interaction].state_value[e]
					
		self.data.active_interaction = self.data.active_interaction+1
		
		
	for i in range(self.data.active_interaction, content.interactions.size()):
		if self.areDepsSatisfied(content.interactions[i].deps):
			self.data.active_interaction = i
			
			return content.interactions[self.data.active_interaction]
	return null
		
	if areDepsSatisfied(content.interactions[self.active_interaction].deps):
		return content.interactions[self.active_interaction]
		
	return null

func getActiveInteraction():
	return self.getActiveContent().interactions[self.data.active_interaction]

func selectOption(index):
	var interaction = self.getActiveInteraction()
	if "options" in interaction:
		if not index > interaction.options.size()-1:
			var option = interaction.options[index]
			for i in option.state_id.size():
				var meets_conditions = true
				if option.has('state_conditions'):
					if self.meetsStateConditions(option.state_conditions[i]):
						meets_conditions = true
					else:
						meets_conditions = false
				if meets_conditions:
					if option.has('state_add'):
						if  option.state_add[i]:
							self.data.state[option.state_id[i]] = self.data.state[option.state_id[i]]+option.state_value[i]
						else:
							self.data.state[option.state_id[i]] = option.state_value[i]
					else:
						self.data.state[option.state_id[i]] = option.state_value[i]

#default returns string of source name.  passing true returns the full source object.
func getInteractionSource(full_source = false):
	var interaction = self.getActiveInteraction()
	if interaction.has("source_id"):
		if self.data.has("sources"):
			for source in self.data.sources:
				if source.id == interaction.source_id:
					if not full_source:
						return source.name
					else:
						return source
	if not full_source:
		return ""
	else:
		return{"name":""}
