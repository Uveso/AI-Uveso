
--- Converts the (lobby) key defined in `aitypes.lua` or for custom AIs in the `CustomAIs_v2` folder
--- to a brain instance specific for that AI

keyToBrain = keyToBrain or {}

keyToBrain["uvesoeasy"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesorush"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesoadaptive"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesoexp"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain

keyToBrain["uvesoeasycheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesorushcheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesoadaptivecheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesoexpcheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesooverwhelmcheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
keyToBrain["uvesonullcheat"] = import("/mods/AI-Uveso/hook/lua/aibrains/UvesoAI.lua").UvesoAIBrain
