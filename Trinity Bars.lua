-- ABOUT SCRIPT
script_name("Trinity Bars")
script_version("1.3")
script_author("eweest")
script_url("https://vk.com/gtatrinitymods")

---- ASSETS [START]

-- LIB
local se = require("lib.samp.events")

-- CHAT
local TAG = "[Trinity Mods]: "
local CMD_HELP = "/bars"
local COLOR_CHAT = {
	["DONE"] = "0xFFCC00",
	["ERROR"] = "0xFF3232",
}
local TABLE_ID = {
	["FOOD"] = -1,
	["WATER"] = -1,
	["duch"] = -1,
	["INV"] = -1,
	["OTHER"] = {}
}

local loadTexture = {}

-- PATHS
local DIRECT = getWorkingDirectory()
local CONFIG_PATH = "/config/"
local FOLDER_MAIN_PATH = "Trinity GTA Mods/"
local FOLDER_PATH = thisScript().name .. "/"
local TEXTURES_PATH = "textures/"
local FONTS_PATH = "fonts/"
local DB_PATH = "settings.json"

local UPDATE_JSON_PATH = "https://raw.githubusercontent.com/eweest/trinity-bars/main/update.json"
local UPDATE_FILE_PATH = "https://raw.githubusercontent.com/eweest/trinity-bars/main/Trinity-Bars.lua"

-- TEXTURES
local TEXTURES = {	-- NAME, URL
	["FOOD"] = {"food.png", "https://i.ibb.co/G22YZh8/food.png"},
	["WATER"] = {"water.png", "https://i.ibb.co/47FtPrL/water.png"},
	["HYGIENE"] = {"hygiene.png", "https://i.ibb.co/kxWGwk4/hygiene.png"},
	-- STYLE 2
	["FOOD_1"] = {"food-1.png", "https://i.ibb.co/G22YZh8/food.png"},
	["WATER_1"] = {"water-1.png", "https://i.ibb.co/47FtPrL/water.png"},
	["HYGIENE_1"] = {"hygiene-1.png", "https://i.ibb.co/kxWGwk4/hygiene.png"}

}
-- FONTS
local FONTS = {
	["BARS"] = renderCreateFont("Arial", 8, 5),
	["NUMBER"] = renderCreateFont("Pricedown Rus", 32, 4),
	["NUMBER-1"] = renderCreateFont("Arial", 14, 5),
}
-- SOUNDS
local SOUNDS = {
	["ERROR"] = 1055,
	["DONE"] = 1083,
	["CANCEL"] = 1085
}
-- CONFIG "settings.json"
local CONFIG = {
	["VIEW"] = true,
	["ROT"] = "VERTICAL", -- or HORIZONTAL
	["posX"] = 500, 
	["posY"] = 500,
	["TYPE"] = 1,
	["NUMBER"] = false,
	["ICON_STYLE"] = 1,
}

-- SCRIPT FOLDER
if not doesDirectoryExist(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH) then
	createDirectory(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH)
end
-- TEXTURE FOLDER
if not doesDirectoryExist(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH .. TEXTURES_PATH) then
	createDirectory(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH .. TEXTURES_PATH)
end

-- TEXTURES DOWNLOAD
for TEXTURE, NAME_URL in pairs(TEXTURES) do
	if not doesFileExist(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH .. TEXTURES_PATH .. NAME_URL[1]) then
		downloadUrlToFile(NAME_URL[2], DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH .. TEXTURES_PATH .. NAME_URL[1])
	end
end

-- JSON PATH
if not doesFileExist(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH ..  FOLDER_PATH .. DB_PATH) then 
	local file = io.open(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH ..  FOLDER_PATH .. DB_PATH, "w") 
	file:write(encodeJson(CONFIG))  
	io.close(file)
end

if doesFileExist(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH ..  FOLDER_PATH .. DB_PATH) then
	local file = io.open(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH ..  FOLDER_PATH .. DB_PATH, 'r') 
	if file then 
		DB = decodeJson(file:read("*a")) 
		io.close(file)
	end 
end
---- ASSETS [END]

-- MAIN [START]
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	-- CHECK UPDATE
	autoupdate(UPDATE_JSON_PATH, TAG, UPDATE_FILE_PATH)

	-- TRINITY SERVERS
	local IP = sampGetCurrentServerAddress()
	local TRINITYGTA_IP = {
		["RPG"] = "185.169.134.83",
		["RP1"] = "185.169.134.84",
		["RP2"] = "185.169.134.85"
	}
	-- CHECK TRINITY SERVERS
	if IP:find(TRINITYGTA_IP["RPG"]) or IP:find(TRINITYGTA_IP["RP1"]) or IP:find(TRINITYGTA_IP["RP2"]) then
		
		-- LOAD TEXTURES
		for TEXTURE, PATH in pairs(TEXTURES) do
			local TEXTURE_PATH = ( DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH .. FOLDER_PATH .. TEXTURES_PATH )

			loadTexture[TEXTURE] = renderLoadTextureFromFile(TEXTURE_PATH .. PATH[1])
		end
		--
		TRINITYGTA = true
		sampAddChatMessage(TAG .. "{FFFFFF}Скрипт запущен. Автор: {FFCC00}eweest{FFFFFF}. Версия: {FFCC00}" .. thisScript().version .. "{FFFFFF}. Помощь {FFCC00}" .. CMD_HELP, COLOR_CHAT["DONE"])
	else
		sampAddChatMessage(TAG .. "{FFFFFF}Скрипт " .. thisScript().name .. " (v" .. thisScript().version .. ") не запущен, так как вы игрыете не на Trinity GTA.", COLOR_CHAT["DONE"])
		TRINITYGTA = false 
	end
	----

	--| COMMANDS
	sampRegisterChatCommand("bars", function(cmd) -- HELP
		if (cmd == "position" or cmd == "pos") then -- POSITION
			sampAddChatMessage(TAG .. "{FFFFFF}Для сохранения позиции, нажмите {FFCC00}левую кнопку мыши {FFFFFF}или{FFCC00} ENTER.", COLOR_CHAT["DONE"])
			setPosition = true
		-- SETTINGS CMD
		elseif (cmd == "number" or cmd == "num") then -- NUMBERS
			if (DB["TYPE"] == 1) then
				DB["NUMBER"] = not DB["NUMBER"]
				if DB["NUMBER"] then
					addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
					sampAddChatMessage(TAG .."{FFFFFF}Показатель потребностей персонажа в цифрах {32FF32}включен.", COLOR_CHAT["DONE"])
					DB["NUMBER"] = true
				else
					addOneOffSound(0.0, 0.0, 0.0, SOUNDS["CANCEL"])	
					sampAddChatMessage(TAG .."{FFFFFF}Показатель потребностей персонажа в цифрах {FF3232}отключен.", COLOR_CHAT["DONE"])
					DB["NUMBER"] = false
				end
			else
				sampAddChatMessage(TAG .."{FFFFFF}Показатель потребностей персонажа в цифрах доступен только в стиле {FFCC00}#1 'Стамина'{FFFFFF}.", COLOR_CHAT["DONE"])
			end
			saveDB()
		elseif (cmd == "view" or cmd == "vw") then -- VIEW MODE
			DB["VIEW"] = not DB["VIEW"]
			if DB["VIEW"] then
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
				sampAddChatMessage(TAG .."{FFFFFF}Потребности персонажа {32FF32}включены.", COLOR_CHAT["DONE"])
				DB["VIEW"] = true
			else
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["CANCEL"])	
				sampAddChatMessage(TAG .."{FFFFFF}Потребности персонажа {FF3232}отключены.", COLOR_CHAT["DONE"])
				DB["VIEW"] = false
			end
			saveDB()
		elseif (cmd == "rotation" or cmd == "rt") then -- VIEW MODE
			if DB["ROT"] ~= "HORIZONTAL" and (cmd == "rot" or cmd == "rt") then
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
				sampAddChatMessage(TAG .."{FFFFFF}Вы активировали {FFCC00}Горизонтальный{FFFFFF} режим.", COLOR_CHAT["DONE"])
				DB["ROT"] = "HORIZONTAL"
			else
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["CANCEL"])	
				sampAddChatMessage(TAG .."{FFFFFF}Вы активировали {FFCC00}Вертикальный{FFFFFF} режим.", COLOR_CHAT["DONE"])
				DB["ROT"] = "VERTICAL"
			end
			saveDB()
		-- BARS STYLE
		elseif (cmd == "type 1") then -- TYPE 1
			if (DB["TYPE"] ~= 1) then
				DB["TYPE"] = 1
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа изменен. Вариант: {FFCC00} #1 'Стамина'.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
			else
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа {FFCC00}#1 'Стамина'{FFFFFF} уже используется!", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			end
			saveDB()
		elseif (cmd == "type 2") then -- TYPE 2
			if (DB["TYPE"] ~= 2) then
				DB["TYPE"] = 2
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа изменен. Вариант: {FFCC00} #2 'Цифры'.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
			else
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа {FFCC00}#2 'Цифры'{FFFFFF} уже используется!", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			end
			saveDB()
		elseif (cmd == "type 3") then -- TYPE 3
			if (DB["TYPE"] ~= 3) then
				DB["TYPE"] = 3
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа изменен. Вариант: {FFCC00} #3.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
			else
				sampAddChatMessage(TAG .."{FFFFFF}Стиль потребностей персонажа {FFCC00}#3{FFFFFF} уже используется!", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			end
			saveDB()

		-- ICONS STYLE
		elseif (cmd == "icons 1") then -- ICONS 1
			if (DB["ICON_STYLE"] ~= 1) then
				DB["ICON_STYLE"] = 1
				sampAddChatMessage(TAG .."{FFFFFF}Стиль иконок изменен. Вариант: {FFCC00} #1.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
			else
				sampAddChatMessage(TAG .."{FFFFFF}Стиль иконок {FFCC00}#1{FFFFFF} уже используется!", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			end
			saveDB()
		elseif (cmd == "icons 2") then -- ICONS 2
			if (DB["ICON_STYLE"] ~= 2) then
				DB["ICON_STYLE"] = 2
				sampAddChatMessage(TAG .."{FFFFFF}Стиль иконок изменен. Вариант: {FFCC00} #2.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
			else
				sampAddChatMessage(TAG .."{FFFFFF}Стиль иконок {FFCC00}#2{FFFFFF} уже используется!", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			end
			saveDB()
		-- ERROR MSG
		elseif #cmd == 0 then
			cmdHelpCMD()
			addOneOffSound(0.0, 0.0, 0.0, 1139)
		else
			addOneOffSound(0.0, 0.0, 0.0, SOUNDS["ERROR"])
			sampAddChatMessage(TAG .."{FFFFFF}Неизвестная команда. Введите: {FFCC00}/bars.", COLOR_CHAT["ERROR"])
		end
	end)
	----
	
	while true do wait(0)
		if setPosition then
		local posX, posY = getCursorPos()
			showCursor(true, true)
			DB["posX"], DB["posY"] = posX, posY

			if isKeyDown(0x01) or isKeyDown(0x0D) then -- LMB or ENTER
				showCursor(false, false)
				sampAddChatMessage(TAG .. "{FFFFFF}Положение потребностей персонажа сохранено.", COLOR_CHAT["DONE"])
				addOneOffSound(0.0, 0.0, 0.0, SOUNDS["DONE"])
				setPosition = false
				saveDB()
			end
		end

		if TRINITYGTA then
			if not sampTextdrawIsExists(TABLE_ID["INV"]) then
				for key, val in pairs(TABLE_ID["OTHER"]) do
					if sampTextdrawIsExists(val) then
						sampTextdrawDelete(val)
					end
				end
				
				if TABLE_ID["FOOD"] ~= -1 then
					if sampTextdrawIsExists(TABLE_ID["FOOD"]) then
						local posX, posY = sampTextdrawGetPos(TABLE_ID["FOOD"])
						if posX ~= -20 and posY ~= -20 then
							sampTextdrawSetPos(TABLE_ID["FOOD"], -20, -20)
						end
					end
				end
				if TABLE_ID["WATER"] ~= -1 then
					if sampTextdrawIsExists(TABLE_ID["WATER"]) then
						local posX, posY = sampTextdrawGetPos(TABLE_ID["WATER"])
						if posX ~= -20 and posY ~= -20 then
							sampTextdrawSetPos(TABLE_ID["WATER"], -20, -20)
						end
					end
				end
				if TABLE_ID["HYGIENE"] ~= -1 then
					if sampTextdrawIsExists(TABLE_ID["HYGIENE"]) then
						local posX, posY = sampTextdrawGetPos(TABLE_ID["HYGIENE"])
						if posX ~= -20 and posY ~= -20 then
							sampTextdrawSetPos(TABLE_ID["HYGIENE"], -20, -20)
						end
					end
				end
				if sampTextdrawIsExists(2060) then
					DB["MOVIE"] = false
				else
					DB["MOVIE"] = true
				end
			end
			--| CREATE BARS
			local spawned = sampIsLocalPlayerSpawned()
			if spawned then								
				if not sampTextdrawIsExists(TABLE_ID["INV"]) then
					createBarIcon()
				end
			end
			----
		end
	end

	wait(-1)
end

-- CREATE CUSTOM BARS [START]
function createBarIcon()
	local plFood = getPlayerFood(TABLE_ID["FOOD"]) -- DATA PLAYER FOOD
	local plWater = getPlayerWater(TABLE_ID["WATER"]) -- DATA PLAYER WATER
	local plHygiene = getPlayerHygiene(TABLE_ID["HYGIENE"]) -- DATA PLAYER HYGIENE

	local sizeX, sizeY = 32, 32
	local posX, posY = DB["posX"], DB["posY"]
	-- COLORS
	local COLORS = {
		["WHITE"] = {
			["F"] = '0xFFFFFFFF', -- FOOD
			["W"] = '0xFFFFFFFF', -- WATER
			["H"] = '0xFFFFFFFF', -- HYGIENE
			["TEXT"] = '0xFFFFFFFF', -- TEXT
		},
		["BLACK"] = '0xAA000000', 
		["RED"] = '0xFFFF0000', 
		["GREEN"] = '0xFF56AA0E', 
		["BLUE"] = '0xFF3B79B3', 
		["YELLOW"] = '0xFFE3A51E', 
	}
	-- COLOR SET
	if plFood <= 22 then
		COLORS["GREEN"] = COLORS["RED"]
		COLORS["WHITE"]["F"] = COLORS["RED"]
	end
	if plWater <= 22 then
		COLORS["YELLOW"] = COLORS["RED"]
		COLORS["WHITE"]["W"] = COLORS["RED"]
	end
	if plHygiene <= 22 then
		COLORS["BLUE"] = COLORS["RED"]
		COLORS["WHITE"]["H"] = COLORS["RED"]
	end

	-- ICONS STYLE
	local ICON_STYLE = { -- ICON, COLOR_ICON, COLOR_BAR, dataPlayer
		["STYLE_1"] = {
			{"FOOD", "F", "GREEN", plFood},
			{"WATER", "W", "YELLOW", plWater}, 
			{"HYGIENE", "H", "BLUE", plHygiene}
		},
		["STYLE_2"] = {
			{"FOOD_1", "F", "GREEN", plFood},
			{"WATER_1", "W", "YELLOW", plWater}, 
			{"HYGIENE_1", "H", "BLUE", plHygiene}
		},

	}
	--
	local iconStyle = "STYLE_1"
	if DB["ICON_STYLE"] == 1 then
		iconStyle = "STYLE_1"
	elseif DB["ICON_STYLE"] == 2 then
		iconStyle = "STYLE_2"
	end
	--
	if DB["VIEW"] then
		if not DB["MOVIE"] then -- MOVIE MODE
			if (DB["ROT"] == "HORIZONTAL") then -- HORIZONTAL MODE
				if DB["TYPE"] == 1 then --CREATE TYPE 1
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawBox(posX - (130*ID) + 130, posY + 8, 88, 16, COLORS["BLACK"]) -- BG BAR
						renderDrawBox(posX - (130*ID) + 134, posY + 12, INFO[4]*0.76, 8, COLORS[INFO[3]]) -- BARS
						renderDrawTexture(loadTexture[INFO[1]], posX - (130*ID) + 96, posY, sizeX, sizeY, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
					if DB["NUMBER"] == true then -- NUMBERS
						renderFontDrawText(FONTS["BARS"], string.format("%01d", INFO[4]*0.95), posX - (130*ID)+166, posY + 8, COLORS["WHITE"]["TEXT"]) -- TEXT
					end
					end
				elseif DB["TYPE"] == 2 then -- CREATE TYPE 2
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawTexture(loadTexture[INFO[1]], posX-(90*ID)+90, posY, sizeX, sizeY, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
						renderFontDrawText(FONTS["NUMBER"], string.format("%01d", INFO[4]*0.95), posX - (90*ID)+124, posY - 4, COLORS["WHITE"][INFO[2]]) -- TEXT
					end
				elseif DB["TYPE"] == 3 then -- CREATE TYPE 3
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawBox(posX - (76*ID) + 76, posY, 72, 28, COLORS["BLACK"]) -- BG
						renderDrawTexture(loadTexture[INFO[1]], posX - (76*ID) + 80, posY + 2, sizeX - 8, sizeY - 8, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
						renderFontDrawText(FONTS["NUMBER-1"], string.format("%01d", INFO[4]*0.95), posX - (76*ID)+108, posY + 3, COLORS["WHITE"][INFO[2]]) -- TEXT
					end
				end
			end
			if (DB["ROT"] == "VERTICAL") then -- VERTICAL MODE
				if DB["TYPE"] == 1 then --CREATE TYPE 1
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawBox(posX, posY + (34*ID) - 26, 88, 16, COLORS["BLACK"]) -- BG BAR
						renderDrawBox(posX + 4, posY + (34*ID) - 22, INFO[4]*0.76, 8, COLORS[INFO[3]]) -- BARS
						renderDrawTexture(loadTexture[INFO[1]], posX-34, posY + (36*ID) - 36, sizeX, sizeY, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
					if DB["NUMBER"] == true then -- NUMBERS
						renderFontDrawText(FONTS["BARS"], string.format("%01d", INFO[4]*0.95), posX + 36, posY + (34*ID) - 26, COLORS["WHITE"]["TEXT"]) -- TEXT
					end
					end
				elseif DB["TYPE"] == 2 then -- CREATE TYPE 2
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawTexture(loadTexture[INFO[1]], posX-34, posY + (36*ID) - 36, sizeX, sizeY, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
						renderFontDrawText(FONTS["NUMBER"], string.format("%01d", INFO[4]*0.95), posX, posY + (36*ID) - 41, COLORS["WHITE"][INFO[2]]) -- TEXT
					end
				elseif DB["TYPE"] == 3 then -- CREATE TYPE 3
					for ID, INFO in pairs(ICON_STYLE[iconStyle]) do
						renderDrawBox(posX, posY + (32*ID) - 32, 72, 28, COLORS["BLACK"]) -- BG
						renderDrawTexture(loadTexture[INFO[1]], posX + 4, posY + (32*ID) - 30, sizeX - 8, sizeY - 8, 0, COLORS["WHITE"][INFO[2]]) -- ICONS
						renderFontDrawText(FONTS["NUMBER-1"], string.format("%01d", INFO[4]*0.95), posX + 32, posY + (32*ID) - 30, COLORS["WHITE"][INFO[2]]) -- TEXT
					end
				end
			end
		end
	end
end
-- CREATE CUSTOM BARS [END]

-- HELP WINDOW [START]
local TITLE = "Помощь по: {FFFFFF}"
local TITLE_COLOR = "{AFE7FF}"
local TEXT_CMD = [[
{ffcc00}Основные команды:{ffffff}
{AFE7FF}/bars{ffffff} - Окно помощи
{AFE7FF}/bars (pos)ition{ffffff} - Изменение позиции
{AFE7FF}/bars type [1-3]{ffffff} - Изменение стиля показателей
{AFE7FF}/bars icons [1-2]{ffffff} - Изменение стиля иконок
{AFE7FF}/bars rotation(rt){ffffff} - Изменение режима (Вертикально или Горизонтально)
{AFE7FF}/bars (num)ber{ffffff} - Показать/Скрыть цифры в режиме #1 "Стамина"
{AFE7FF}/bars view(vw){ffffff} - Показать/Скрыть

{ffcc00}Полезные советы:{ffffff}
{AFE7FF}[1]{ffffff} Если показатели показывают "0" и {FF3232}горят красным{ffffff}, откройте и закройте инвентарь.
{AFE7FF}[2]{ffffff} При замене иконок на свои, используйте размер {ffcc00}32x32{ffffff} пикселя.

{ffcc00}О скрипте:{ffffff}
{AFE7FF}Название (Версия){ffffff}			TRINITY Bars (v1.3)
{AFE7FF}Дата последнего обновления{ffffff}		02.06.2022
{AFE7FF}Автор скрипта{ffffff}				eweest
{AFE7FF}Наше сообщество{ffffff}				vk.com/gtatrinitymods
]]


function cmdHelpCMD()
	sampShowDialog(10000, TITLE_COLOR .. TITLE .. thisScript().name, TEXT_CMD, "X")
end
-- HELP WINDOW [END]


function se.onShowTextDraw(id, data)
	if TRINITYGTA then
		if data.text:find("‹AЋ …H‹EHЏAP’") then
			TABLE_ID["INV"] = id
		end
		-- // FOOD
		if data.letterColor == -14500865 or data.letterColor == -14518409 then
			TABLE_ID["WATER"] = id
		end
		-- // WATER
		if data.letterColor == -15744669 or data.letterColor == -13399996 then
			TABLE_ID["FOOD"] = id
		end
		-- // HYGIENE
		if data.letterColor == -3372988 then
			TABLE_ID["HYGIENE"] = id
		end
		-- // BLACK BACKGROUND
		if data.letterColor == -16777216 then
			if not search(id, TABLE_ID["OTHER"]) then
				table.insert(TABLE_ID["OTHER"], id)
			end
		end
	end
end
--

function getPlayerFood(id)
	if TRINITYGTA then
		if id ~= -1 then
			if sampTextdrawIsExists(id) then
				local box, color, sizeX, sizeY = sampTextdrawGetBoxEnabledColorAndSize(id)
				return sizeX
			end
		end
	end
	return 0
end

function getPlayerWater(id)
	if TRINITYGTA then
		if id ~= -1 then
			if sampTextdrawIsExists(id) then
				local box, color, sizeX, sizeY = sampTextdrawGetBoxEnabledColorAndSize(id)
				return sizeX
			end
		end
	end
	return 0
end

function getPlayerHygiene(id)
	if TRINITYGTA then
		if id ~= -1 then
			if sampTextdrawIsExists(id) then
				local box, color, sizeX, sizeY = sampTextdrawGetBoxEnabledColorAndSize(id)
				return sizeX
			end
		end
	end
	return 0
end

function search(str, tab)
	if str ~= nil then
		for key, val in pairs(tab) do
			if str == val then
				return true
			end
		end
	end
	return false
end


-- SAVE DATABASE
function saveDB()
	local file = io.open(DIRECT .. CONFIG_PATH .. FOLDER_MAIN_PATH ..  FOLDER_PATH .. DB_PATH, "w")
	file:write(encodeJson(DB))
	file:close()
end
----

-- AUTO-UPDATE (cred: qrlk)
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status

				sampAddChatMessage((prefix .. "{FFFFFF}Найдено обновление для скрипта {FFCC00}" .. thisScript().name .. "."), COLOR_CHAT["DONE"])
				sampAddChatMessage((prefix .. "{FFFFFF}Идет обновление c версии {FFCC00}" .. thisScript().version .. "{FFFFFF} на версию {FFCC00}" .. updateversion), COLOR_CHAT["DONE"])
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format("Загружено %d из %d.", p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print("Загрузка обновления завершена.")
                      sampAddChatMessage((prefix .. "{FFFFFF}Обновление {FFCC00}" .. thisScript().name .. "{FFFFFF} завершено!"), COLOR_CHAT["DONE"])
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix .. "Обновление прошло неудачно. {FFFFFF}Запускаю устаревшую версию."), COLOR_CHAT["ERROR"])
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v' .. thisScript().version .. ": Обновление не требуется.")
            end
          end
        else
          print('v' .. thisScript().version .. ": Не могу проверить обновление. Смиритесь или проверьте самостоятельно на "..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
----