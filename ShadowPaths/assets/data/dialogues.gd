extends Resource
class_name DialogueDatabase

# Dialogue database for Shadow Paths
static var dialogues: Dictionary = {}

func _init():
	create_dialogues()

func create_dialogues():
	# Village NPCs
	dialogues["village_elder"] = create_village_elder_dialogue()
	dialogues["village_merchant"] = create_village_merchant_dialogue()
	dialogues["village_guard"] = create_village_guard_dialogue()

	# Choice-based dialogues
	dialogues["forbidden_ruins_choice"] = create_forbidden_ruins_choice()
	dialogues["corruption_knowledge_choice"] = create_corruption_knowledge_choice()
	dialogues["power_sacrifice_choice"] = create_power_sacrifice_choice()

	# Corruption-based dialogues
	dialogues["corruption_warnings"] = create_corruption_warnings()
	dialogues["corruption_reactions"] = create_corruption_reactions()

# Village NPC Dialogues
func create_village_elder_dialogue() -> Dictionary:
	return {
		"normal": {
			"greeting": "Welcome, young scholar. I sense a thirst for knowledge in you.",
			"topics": [
				{
					"id": "village_history",
					"text": "Tell me about the village history",
					"response": "Our village has stood here for centuries, guarding ancient secrets. Some things are best left undiscovered."
				},
				{
					"id": "nearby_ruins",
					"text": "What about the ruins to the east?",
					"response": "Ah, the ruins... Many have ventured there seeking knowledge. Few return unchanged. I warn you: some knowledge comes at a terrible price."
				}
			]
		},
		"corruption_low": {
			"greeting": "I sense a darkness beginning to shadow your spirit. Be careful what knowledge you seek.",
			"response": "The path you walk grows darker. Remember who you are."
		},
		"corruption_medium": {
			"greeting": "The corruption... I can see it in your eyes. You must stop before it's too late.",
			"response": "There is still time to turn back, but you must choose quickly."
		},
		"corruption_high": {
			"greeting": "Stay back! The darkness has taken hold. I cannot help you now.",
			"response": "You are no longer the person who first came to this village. The knowledge has corrupted you completely."
		}
	}

func create_village_merchant_dialogue() -> Dictionary:
	return {
		"normal": {
			"greeting": "Welcome to my shop! I have many useful items for a scholar like yourself.",
			"topics": [
				{
					"id": "special_items",
					"text": "Do you have anything special?",
					"response": "I have some... unusual items. They say some of them come from the forbidden ruins. Powerful, but dangerous."
				},
				{
					"id": "trade",
					"text": "Let's trade",
					"response": "[OPEN SHOP]"
				}
			]
		},
		"corruption_low": {
			"greeting": "Ah, customer! Though... you look a bit different than last time. Still, business is business!",
			"topics": [
				{
					"id": "corruption_goods",
					"text": "Do you sell items for... people like me?",
					"response": "I have some specialty items, yes. They're expensive, but they understand those who seek power."
				}
			]
		},
		"corruption_high": {
			"greeting": "I... I don't want any trouble. Please take what you want and leave.",
			"response": "Your money is no good here. Just... don't hurt me."
		}
	}

func create_village_guard_dialogue() -> Dictionary:
	return {
		"normal": {
			"greeting": "Halt! State your business in this village.",
			"response": "As long as you cause no trouble, you're welcome here."
		},
		"corruption_low": {
			"greeting": "You again... I'm watching you. Something's not right about you.",
			"response": "One wrong move and you'll regret it."
		},
		"corruption_medium": {
			"greeting": "I knew it! You're tainted! You should leave this village at once!",
			"response": "The corruption is spreading through you like a disease."
		},
		"corruption_high": {
			"greeting": "MONSTER! DEFEND THE VILLAGE!",
			"response": "[COMBAT INITIATED]"
		}
	}

# Major Choice Dialogues
func create_forbidden_ruins_choice() -> Dictionary:
	return {
		"id": "forbidden_ruins_choice",
		"description": "You discover ancient ruins deep in the forest. Dark energy emanates from within. The entrance is partially collapsed, but you see a way inside.",
		"choices": [
			{
				"text": "Enter the ruins immediately",
				"consequences": {
					"corruption_impact": 15.0,
					"moral_impact": 0,
					"world_changes": {
						"ruins_entrance": {"collapsed": true, "player_inside": true}
					},
					"discovers_secret": "forbidden_knowledge_1",
					"relationship_changes": {
						"village_elder": {"trust": -20, "fear": 10}
					}
				},
				"result": "You squeeze through the collapsed entrance. Inside, you find ancient tablets covered in symbols that seem to crawl before your eyes. Knowledge floods your mind, but something feels... wrong."
			},
			{
				"text": "Study the entrance from outside first",
				"consequences": {
					"corruption_impact": 5.0,
					"moral_impact": 5,
					"world_changes": {
						"ruins_entrance": {"studied": true}
					},
					"discovers_secret": "ruins_entrance_safe"
				},
				"result": "You carefully examine the runes around the entrance. They speak of warnings and protective wards. You gain some understanding without exposing yourself fully to the corruption within."
			},
			{
				"text": "Report back to the village elder",
				"consequences": {
					"corruption_impact": 0.0,
					"moral_impact": 10,
					"relationship_changes": {
						"village_elder": {"trust": 15, "friendship": 10}
					}
				},
				"result": "The elder listens gravely to your discovery. 'Your wisdom serves you well,' they say. 'Some doors should remain closed.'"
			}
		]
	}

func create_corruption_knowledge_choice() -> Dictionary:
	return {
		"id": "corruption_knowledge_choice",
		"description": "You find a forbidden text that promises incredible power. The pages seem to whisper directly into your mind, offering knowledge beyond mortal comprehension.",
		"choices": [
			{
				"text": "Read the text completely",
				"consequences": {
					"corruption_impact": 25.0,
					"discovers_secret": "dark_rituals",
					"quest_progress": {
						"quest_id": "corruption_path",
						"action": "update",
						"progress": 75
					}
				},
				"result": "The knowledge flows into you like dark fire. You understand secrets of reality that no human should know. Your vision briefly turns red, and for a moment, you see the world as something else entirely."
			},
			{
				"text": "Read only the safe sections",
				"consequences": {
					"corruption_impact": 10.0,
					"discovers_secret": "partial_forbidden_knowledge"
				},
				"result": "You carefully select only the least dangerous passages. Even this limited exposure leaves you feeling changed, your thoughts tinged with shadows."
			},
			{
				"text": "Destroy the text",
				"consequences": {
					"corruption_impact": -5.0,
					"moral_impact": 15,
					"relationship_changes": {
						"village_elder": {"trust": 20}
					}
				},
				"result": "With great effort, you burn the forbidden text. As the pages turn to ash, you feel a weight lift from your soul, though part of you mourns the lost knowledge."
			}
		]
	}

func create_power_sacrifice_choice() -> Dictionary:
	return {
		"id": "power_sacrifice_choice",
		"description": "A shadowy figure offers you immense power in exchange for a sacrifice. The offer is vague about what exactly must be given up.",
		"choices": [
			{
				"text": "Accept the deal immediately",
				"consequences": {
					"corruption_impact": 30.0,
					"discovers_secret": "shadow_pact",
					"stat_changes": {"attack": 10, "special": 15}
				},
				"result": "Power surges through you, but as it does, you feel something being torn away - your connection to others, your ability to feel empathy, perhaps even your humanity itself."
			},
			{
				"text": "Demand to know the sacrifice first",
				"consequences": {
					"corruption_impact": 15.0,
					"discovers_secret": "nature_of_power"
				},
				"result": "The figure smiles. 'Very wise. The sacrifice is your innocence. Each time you use this power, you become less human. Is that a price you're willing to pay?'"
			},
			{
				"text": "Refuse and attack",
				"consequences": {
					"corruption_impact": 5.0,
					"moral_impact": 10,
					"world_changes": {
						"shadow_figure": {"hostile": true}
					}
				},
				"result": "You strike out at the shadowy figure. It dissolves into laughter that echoes in your mind. 'Brave, but foolish. The power you refuse will find other vessels.'"
			}
		]
	}

# Corruption-based reactions
func create_corruption_warnings() -> Dictionary:
	return {
		"stage_1": [
			"You notice your reflection shows eyes with an unusual tint.",
			"People in the village seem to watch you more carefully now.",
			"Sometimes you hear whispers that no one else can hear."
		],
		"stage_2": [
			"Strange symbols sometimes appear on your skin, fading after a few hours.",
			"Animals avoid you, sensing something wrong.",
			"Your shadow sometimes seems to move independently."
		],
		"stage_3": [
			"The corruption is visible now. People cross the street to avoid you.",
			"You find yourself thinking thoughts that feel alien to you.",
			"Sometimes you forget what it felt like to be normal."
		],
		"stage_4": [
			"Humanity feels like a distant memory. You are something else now.",
			"The power is incredible, but the cost... the cost was everything.",
			"You look at normal humans and feel nothing but pity or contempt."
		]
	}

func create_corruption_reactions() -> Dictionary:
	return {
		"family": {
			"stage_1": "You seem different lately. Is everything okay?",
			"stage_2": "I'm worried about you. Please tell me what's happening.",
			"stage_3": "You're not the person I remember. What have you become?",
			"stage_4": "Stay away from me. Whatever you are now, you're not my family."
		},
		"children": {
			"stage_1": "Mister/Miss, your eyes look funny!",
			"stage_2": "*Children run away when you approach*",
			"stage_3": "*Children hide when you come near*",
			"stage_4": "*Children cry at the sight of you*"
		},
		"authorities": {
			"stage_1": "We've had some reports about unusual activity. Anything you want to tell us?",
			"stage_2": "You're becoming a person of interest. We're watching you.",
			"stage_3": "You're under arrest. Don't resist.",
			"stage_4": "Open fire! That's not human anymore!"
		}
	}

# Utility functions
static func get_dialogue(npc_id: String, corruption_stage: String = "normal") -> Dictionary:
	var npc_dialogues = dialogues.get(npc_id, {})
	return npc_dialogues.get(corruption_stage, npc_dialogues.get("normal", {}))

static func get_choice_dialogue(choice_id: String) -> Dictionary:
	return dialogues.get(choice_id, {})

static func get_corruption_warning(stage: String) -> Array:
	var warnings = dialogues.get("corruption_warnings", {}).get(stage, [])
	if warnings.size() > 0:
		return [warnings[randi() % warnings.size()]]
	return []

static func get_npc_reaction(npc_type: String, corruption_stage: String) -> String:
	var reactions = dialogues.get("corruption_reactions", {}).get(npc_type, {})
	return reactions.get(corruption_stage, "I have nothing to say to you.")