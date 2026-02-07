extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = 999
# Name of the mod, used for writing to the logs
const MOD_NAME = "Discord RPC"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""

# Path of the mod folder, automatically generated on runtime
var modPath:String = get_script().resource_path.get_base_dir() + "/"
# Required var for the replaceScene() func to work
var _savedObjects := []

# Initialize the mod
# This function is executed before the majority of the game is loaded
# Only the Tool and Debug AutoLoads are available
# Script and scene replacements should be done here, before the originals are loaded
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	
	installScriptExtension("music/Music.gd")
	replaceScene("music/Music.tscn")
	installScriptExtension("TitleMenu.gd")
	replaceScene("TitleScreen.tscn")
	
	installScriptExtension("enceladus/Crew.gd")
	installScriptExtension("enceladus/Dealer.gd")
	installScriptExtension("enceladus/DiveTarget.gd")
	installScriptExtension("enceladus/Logs.gd")
	installScriptExtension("enceladus/MineralMarket.gd")
	installScriptExtension("enceladus/PreFlightInspection.gd")
	installScriptExtension("enceladus/Repairs.gd")
	installScriptExtension("enceladus/Services.gd")
	installScriptExtension("enceladus/SimulationLayer.gd")
	installScriptExtension("enceladus/Summary.gd")
	installScriptExtension("enceladus/Tuning.gd")
	installScriptExtension("enceladus/Upgrades.gd")
	
	# Code to handle a mod checker script (available through HevLib's examples folder)
	# Disabled by default, but if added must be placed in the same folder as the ModMain.gd script.
	# This is used to check for a dependant mod existing, as well as for a version derived from the manifest or modmain script.
#	var mp = self.get_script().get_path()
#	var md = mp.split(mp.split("/")[mp.split("/").size() - 1])[0]
#	var mc = load(md + "mod_checker_script.tscn").instance()
#	add_child(mc)
	
	# Loads translation file. For this example, the english translation file is used. 
	updateTL("i18n/en.txt", "|")
	
# Do stuff on ready
# At this point all AutoLoads are available and the game is loaded
func _ready():
	
	installScriptExtension("enceladus/Enceladus.gd")
	replaceScene("enceladus/Enceladus.tscn")
	installScriptExtension("Game.gd")
	replaceScene("Game.tscn")
	l("Readying")
	var network = Node.new()
	network.set_script(load("res://Delta-V-Discord-RPC/networking/RPCNetworking.gd"))
	network.name = "DiscordRPC_Network"
	get_tree().get_root().call_deferred("add_child",network)
	
	
	
	
	l("Ready")

# Helper script to load translations using csv format
# `path` is the path to the transalation file
# `delim` is the symbol used to seperate the values
# `useRelativePath` setting it to false uses a `res://` relative path instead of relative to the file
# `fullLogging` setting it to false reduces the number of logs written to only display the number of translations made
# example usage: updateTL("i18n/translation.txt", "|")
func updateTL(path:String, delim:String = ",", useRelativePath:bool = true, fullLogging:bool = true):
	if useRelativePath:
		path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	var err = tlFile.open(path, File.READ)
	
	if err != OK:
		return
	
	var translations := []
	
	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)
	
	if fullLogging:
		l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)
	
	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)
		var size = csvLine.size()
		if size > 1:
			if size > 2:
				var i = 0
				while i < size:
					if csvLine[i].ends_with("\\") and i < size:
						csvLine[i] = csvLine[i].rstrip("\\") + delim + csvLine[i + 1]
						csvLine.remove(i + 1)
						size -= 1
					i += 1
			var translationID := csvLine[0]
			for i in range(1, size):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				l("Added translation: %s" % csvLine)
			translationCount += 1
	
	tlFile.close()
	
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	l("%s Translations Updated" % translationCount)


# Helper function to extend scripts
# Loads the script you pass, checks what script is extended, and overrides it
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)


# Helper function to replace scenes
# Can either be passed a single path, or two paths
# With a single path, it will replace the vanilla scene in the same relative position
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
