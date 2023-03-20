script_author('pivas&bager')
require 'lib.moonloader'
local imgui = require 'imgui'       
local encoding = require "encoding"
local memory = require 'memory'
local ffi = require 'ffi'
local imguiad = require 'lib.imgui_addons'
local samp = require 'lib.samp.events'
local rkeys = require 'lib.rkeys'
local inicfg = require 'inicfg'
local GK = require 'game.keys'
local vkeys = require 'vkeys'
local dlstatus = require('moonloader').download_status
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
local fa = require 'fAwesome5'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local script_vers = 1 
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/bagerokk/LuxwenTools/3b0caf20c7223e3d201d4d8b28d69e38e8528121/update.ini"
local update_path = getWorkingDirectory() ..

local script_url = ""
local script_path = thisScript().path

_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
nick = sampGetPlayerNickname(id)

ffi.cdef[[
struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	uint32_t				clKillerColor; // D3DCOLOR
	uint32_t				clVictimColor; // D3DCOLOR
	uint8_t					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
	int 					iLongestNickLength;
  	int 					iOffsetX;
  	int 					iOffsetY;
	void			    	*pD3DFont; // ID3DXFont
	void		    		*pWeaponFont1; // ID3DXFont
	void		   	    	*pWeaponFont2; // ID3DXFont
	void					*pSprite;
	void					*pD3DDevice;
	int 					iAuxFontInited;
    void 		    		*pAuxFont1; // ID3DXFont
    void 			    	*pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

local tCarsTypeName = {"Автомобиль", "Мотоицикл", "Вертолёт", "Самолёт", "Прицеп", "Лодка", "Другое", "Поезд", "Велосипед"}

local tCarsSpeed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
}

local tCarsType = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}

local quitReason = {
	"Вылет",
	"Вышел из игры",
	"Кик / бан"
}

local adminOnlineOffline = {
    u8"Онлайн",
    u8"Оффлайн"
}

local rInfo = {
	state = false,
    id = -1,
    nickname = ''
}

local arrGuns = {
	[1] = 'Fist[0]',
	[2] = 'Brass knuckles[1]',
	[3] = 'Hockey stick[2]',
	[4] = 'Club[3]',
	[5] = 'Knife[4]',
	[6] = 'Bat[5]',
	[7] = 'Shovel[6]',
	[8] = 'Cue[7]',
	[9] = 'Katana[8]',
	[10] = 'Chainsaw[9]',
	[11] = 'Dildo[10]',
	[12] = 'Dildo[11]',
	[13] = 'Dildo[12]',
	[14] = 'Dildo[13]',
	[15] = 'Bouquet[14]',
	[16] = 'Cane[15]',
	[17] = 'Grenade[16]',
	[18] = 'Gas[17]',
	[19] = 'Molotov cocktail[18]',
	[20] = 'Unknown',
	[21] = 'Unknown',
	[22] = 'Unknown',
	[23] = '9MM[22]',
	[24] = '9mm with silencer[23]',
	[25] = 'Desert Eagle[24]',
	[26] = 'Shotgun[25]',
	[27] = 'Sawed-off[26]',
	[28] = 'Fast Shotgun[27]',
	[29] = 'Uzi[28]',
	[30] = 'MP5[29]',
	[31] = 'AK-47[30]',			
	[32] = 'M4[31]',	
	[33] = 'Tec-9[32]',		
	[34] = 'Sniper rifle[33]',			
	[35] = 'Sniper rifle[34]',			
	[36] = 'RPG[35]',			
	[37] = 'RPG[36]',			
	[38] = 'Flamethrower[37]',			
	[39] = 'Minigun[38]',			
	[40] = 'TNT bag[39]',			
	[41] = 'Detonator[40]',			
	[42] = 'Spray can[41]',			
	[43] = 'Fire extinguisher[42]',			
	[44] = 'Camera[43]',		
	[45] = 'Thermal imager[44]',			
	[46] = 'Thermal imager[45]'	,		
	[47] = 'Parachute[46]'			
}

local pensTable = [[
Блокировка игрового чата (/mute):
— MetaGaming. Наказание: /mute 10 минут.
— CapsLock. Наказание: /mute 10 минут.
— Flood/Spam. Наказание: /mute 10 минут.
— Бред в /me|/do Наказание: /mute 10 минут.
— Бред в /gov. Наказание: /mute 10 минут.
— Злоупотребление матов. Наказание: /mute 10 минут.
— Оскорбление игроков. Наказание: /mute 30 минут.
— Оскорбление Администрации. Наказание: /mute 60 минут.
— Розжиг межнациональной розни. Наказание: /mute 60 минут.
— Упоминание родных игрока. Наказание: /mute 180 минут.
— Неадекватное поведение. Наказание: /mute 30 минут.

Тюрьма (/jail):
— Убийство без причины (DM). Наказание: /jail 15 минут.
— Убийство без причины в ЗЗ (DM ZZ). Наказание: /jail 20 минут.
— Убийство союзников (ТК). Наказание: /jail 15 минут.
— Убийство с транспорта (DB). Наказание: /jail 15 минут.
— Убийство на месте появления (SK). Наказание: /jail 20 минут.
— Убийство при помощи ковша. Наказание: /jail 20 Минут.
— Сбив анимации. Наказание: /jail 20 минут.
— NonRP действия. Наказание: /jail 20 минут.

Тюрьма (/prison):
— Срыв мероприятия: Наказание: /prison 120 минут.
— Использование Читов (не наносят вред). Наказание: /prison 120-180 минут.
— Массовое ДМ/СК/ДБ/ТК. Наказание: /prison 90 минут.

Предупреждение (/warn):
— Выход из игры во время ареста. Наказание: /warn.
— Использования cheat программ во время капта/стрелы. Наказание: /warn.
— Использования cheat в организации. Наказание: /warn.
— NonRp cop. Наказание: /warn.

Блокировка (/ban):
— Использование вред читов. Наказание: /ban 14-30 дней.
— Использование багов. Наказание: /ban 7-14 дней.
— Оскорбление родных администратора. Наказание: /ban 7 дней.
— Nick Name оскорбительного характера. Наказание: /ban 7-14 day.
— Оскорбление проекта. Наказание: /ban 7 дней.
— Реклама сторонних ресурсов. Наказание: /ban 14-30 дней.

Блокировка по IP (/banip):
— Мультиаккаунты. Наказание: /banip 14-30 дней.

]]


local ltcmd = [[
/stmp - пишет о начале мп за вас
]]

local colorsImGui = {u8"Синий", u8"Красный", u8"Коричневый", u8"Фиолетовый", u8"Темно-красный", u8"Салатовый"}

local directory = getWorkingDirectory()..'\\config\\PlayersChecker.json'

if doesFileExist(directory) then
    local f = io.open(directory, "r")
    if f then
      playersList = decodeJson(f:read("a*"))
      f:close()
    end
else
    playersList = {
      [1] = 'floren'
    }
end

local allCarsP = {
    ["487"] = "Maverick",
    ["411"] = "Infernus",
    ["560"] = "Sultan",
    ["522"] = "NRG",
    ["601"] = "SWAT",
    ["415"] = "Cheetah",
    ["451"] = "Turismo",
    ["510"] = "BMX"
}

local allGunsP = {
    ["24"] = "Desert Eagle",
    ["31"] = "M4",
    ["46"] = "Парашют",
    ["25"] = "Дробовик"
}

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
  end
  
  filename_settings = getWorkingDirectory().."\\config\\hotKeys.txt"
  
  local Luacfg = {
      _version = "9"
  }
  setmetatable(Luacfg, {
      __call = function(self)
          return self.__init()
      end
  })
  function Luacfg.__init()
      local self = {}
      local lfs = require "lfs"
      local inspect = require "inspect"
      
      
      function self.mkpath(filename)
          local sep, pStr = package.config:sub(1, 1), ""
          local path = filename:match("(.+"..sep..").+$") or filename
          for dir in path:gmatch("[^" .. sep .. "]+") do
              pStr = pStr .. dir .. sep
              lfs.mkdir(pStr)
          end
      end
      
      
      function self.load(filename, tbl)
          local file = io.open(filename, "r")		
          if file then 
              local text = file:read("*all")
              file:close()
              
              local lua_code = loadstring("return "..text)
              if lua_code then
                  loaded_tbl = lua_code()
                  
                  if type(loaded_tbl) == "table" then
                      for key, value in pairs(loaded_tbl) do
                          tbl[key] = value
                      end
                      return true
                  else
                      return false
                  end
              else
                  return false
              end
          else
              return false
          end
    end
      
      function self.save(filename, tbl)
          self.mkpath(filename)
          
          local file = io.open(filename, "w+")
          if file then
              file:write(inspect(tbl))
              file:close()
              return true
          else
              return false
          end
      end
      
    return self
end
  
luacfg = Luacfg()
cfg = {
    whEnabled = {vkeys.VK_F12},
    LeaveReconWindow = {vkeys.VK_M},
    openHomeWindow = {vkeys.VK_F4},
    activeChatBubble = {vkeys.VK_F2},
    enabledTracers = {vkeys.VK_NUMPAD4}
}

luacfg.load(filename_settings, cfg)
luacfg.save(filename_settings, cfg)

local ofHotkeys = {
    whEnabled = {v = deepcopy(cfg.whEnabled)},
    LeaveReconWindow = {v = deepcopy(cfg.LeaveReconWindow)},
    openHomeWindow = {v = deepcopy(cfg.openHomeWindow)},
    activeChatBubble = {v = deepcopy(cfg.activeChatBubble)},
    openAutoReport = {v = deepcopy(cfg.openAutoReport)},
    enabledTracers = {v = deepcopy(cfg.enabledTracers)}
}

local lastVisibleWorld = 0

local HLcfg = inicfg.load({
    config =     {
        airBrake = true,
        speedHack = true,
        clickWarp = true,
        gmCar = true,
        noBike = true,
        autoCome = false,
        showKillerId = true,
        renderInfoCars = true,
        bulletTracer = true,
        leaveChecker = false,
        statistics = true,
        fullDSuccesfuly = false,
        showMyBullets = true,
        invAdmin = false,
        enableCheckerPlayer = false,
        showAdminPassword = true,
        showloginPassword = true,
        antiEjectCar = false,
        autoReconnect = true,
        cbEndMy = true,
        cbEnd = true,
        infAmmo = false,
        printDvall = true,
        printSpawnCars = true,
        borderToFont = true,
        update_state = false,
        secondToCloseTwo = 5,
        timeOutForma = 10,
        intImGui = 0,
        widthRenderLineOne = 1,
        widthRenderLineTwo = 1,
        speed_airbrake = 1,
        intInfoCars = 30,
        sizeBuffer = 10,
        dayReports = 0,
        dayForms = 0,
        intGunCreate = 0,
        posX = 1000,
        posY = 800,
        limitPageSize = 13,
        posBubbleX = 10,
        posBubbleY = 250,
        posCheckerX = 500,
        posCheckerY = 500,
        maxPagesBubble = 500,
        secondToClose = 5,
        sizeOffPolygon = 1,
        sizeOffPolygonTwo = 1,
        polygonNumber = 1,
        polygonNumberTwo = 1,
        rotationPolygonOne = 10,
        rotationPolygonTwo = 10,
        maxMyLines = 50,
        maxNotMyLines = 50,
        carColor1 = 0,
        carColor2 = 0,
        intComboCar = 0,
        numberGunCreate = 0,
        staticObjectMy = 2905604013,
        dinamicObjectMy = 9013962961,
        pedPMy = 1862972872,
        carPMy = 6282572962,
        staticObject = 2905604013,
        dinamicObject = 9013962961,
        pedP = 1862972872,
        carP = 6282572962,
        adminPassword = "",
        loginPassword = "",
        fullDPassword = "",
        textFindAutoReport = "",
        answerAutoReport = ""
    },
    statAdmin = {
        showId = true,
        showPing = false,
        showHealth = true,
        showOnlineDay = true,
        showOnlineSession = true,
        showAfkDay = true,
        showAfkSession = true,
        showTime = true,
        centerText = true,
        showTopDate = true,
        showInterior = true,
        nameStatis = true
    },
    onDay = {
		today = os.date("%a"),
		online = 0,
		afk = 0,
		full = 0
	}
}, "LuxwenTools.ini")
inicfg.save(HLcfg, "LuxwenTools.ini")

local elements = {
    checkbox = {
        enableCheckerPlayer = imgui.ImBool(HLcfg.config.enableCheckerPlayer),
        formsEnabled = imgui.ImBool(HLcfg.config.formsEnabled),
        airBrake = imgui.ImBool(HLcfg.config.airBrake),
        speedHack = imgui.ImBool(HLcfg.config.speedHack),
        clickWarp = imgui.ImBool(HLcfg.config.clickWarp),
        gmCar = imgui.ImBool(HLcfg.config.gmCar),
        noBike = imgui.ImBool(HLcfg.config.noBike),
        autoCome = imgui.ImBool(HLcfg.config.autoCome),
        showKillerId = imgui.ImBool(HLcfg.config.showKillerId),
        renderInfoCars = imgui.ImBool(HLcfg.config.renderInfoCars),
        leaveChecker = imgui.ImBool(HLcfg.config.leaveChecker),
        statistics = imgui.ImBool(HLcfg.config.statistics),
        bulletTracer = imgui.ImBool(HLcfg.config.bulletTracer),
        fullDSuccesfuly = imgui.ImBool(HLcfg.config.fullDSuccesfuly),
        enableAutoReport = imgui.ImBool(HLcfg.config.enableAutoReport),
        showMyBullets = imgui.ImBool(HLcfg.config.showMyBullets),
        showAdminPassword = imgui.ImBool(HLcfg.config.showAdminPassword),
        showloginPassword = imgui.ImBool(HLcfg.config.showloginPassword),
        antiEjectCar = imgui.ImBool(HLcfg.config.antiEjectCar),
        areportclick = imgui.ImBool(HLcfg.config.areportclick),
        autoReconnect = imgui.ImBool(HLcfg.config.autoReconnect),
        cbEndMy = imgui.ImBool(HLcfg.config.cbEndMy),
        cbEnd = imgui.ImBool(HLcfg.config.cbEnd),
        infAmmo = imgui.ImBool(HLcfg.config.infAmmo),
        printDvall = imgui.ImBool(HLcfg.config.printDvall),
        printSpawnCars = imgui.ImBool(HLcfg.config.printSpawnCars),
        borderToFont = imgui.ImBool(HLcfg.config.borderToFont)
    },
    int = {
        intImGui = imgui.ImInt(HLcfg.config.intImGui),
        intInfoCars = imgui.ImInt(HLcfg.config.intInfoCars),
        sizeBuffer = imgui.ImInt(HLcfg.config.sizeBuffer),
        timeOutForma = imgui.ImInt(HLcfg.config.timeOutForma),
        limitPageSize = imgui.ImInt(HLcfg.config.limitPageSize),
        maxPagesBubble = imgui.ImInt(HLcfg.config.maxPagesBubble),
        secondToClose = imgui.ImInt(HLcfg.config.secondToClose),
        secondToCloseTwo = imgui.ImInt(HLcfg.config.secondToCloseTwo),
        widthRenderLineOne = imgui.ImInt(HLcfg.config.widthRenderLineOne),
        widthRenderLineTwo = imgui.ImInt(HLcfg.config.widthRenderLineTwo),
        sizeOffPolygon = imgui.ImInt(HLcfg.config.sizeOffPolygon),
        sizeOffPolygonTwo = imgui.ImInt(HLcfg.config.sizeOffPolygonTwo),
        polygonNumber = imgui.ImInt(HLcfg.config.polygonNumber),
        polygonNumberTwo = imgui.ImInt(HLcfg.config.polygonNumberTwo),
        rotationPolygonOne = imgui.ImInt(HLcfg.config.rotationPolygonOne),
        rotationPolygonTwo = imgui.ImInt(HLcfg.config.rotationPolygonTwo),
        maxMyLines = imgui.ImInt(HLcfg.config.maxMyLines),
        maxNotMyLines = imgui.ImInt(HLcfg.config.maxNotMyLines)
    },
    input = {
        adminPassword = imgui.ImBuffer(tostring(HLcfg.config.adminPassword), 50),
        loginPassword = imgui.ImBuffer(tostring(HLcfg.config.loginPassword), 50),
        fullDPassword = imgui.ImBuffer(tostring(HLcfg.config.fullDPassword), 7),
        textFindAutoReport = imgui.ImBuffer(tostring(HLcfg.config.textFindAutoReport), 256),
        answerAutoReport = imgui.ImBuffer(tostring(HLcfg.config.answerAutoReport), 256)
    },
    putStatis = {
        nameStatis = imgui.ImBool(HLcfg.statAdmin.nameStatis),
        showId = imgui.ImBool(HLcfg.statAdmin.showId),
        showPing = imgui.ImBool(HLcfg.statAdmin.showPing),
        showHealth = imgui.ImBool(HLcfg.statAdmin.showHealth),
        showFormDay = imgui.ImBool(HLcfg.statAdmin.showFormDay),
        showFormSession = imgui.ImBool(HLcfg.statAdmin.showFormSession),
        showReportDay = imgui.ImBool(HLcfg.statAdmin.showReportDay),
        showReportSession = imgui.ImBool(HLcfg.statAdmin.showReportSession),
        showOnlineDay = imgui.ImBool(HLcfg.statAdmin.showOnlineDay),
        showOnlineSession = imgui.ImBool(HLcfg.statAdmin.showOnlineSession),
        showAfkDay = imgui.ImBool(HLcfg.statAdmin.showAfkDay),
        showAfkSession = imgui.ImBool(HLcfg.statAdmin.showAfkSession),
        showTime = imgui.ImBool(HLcfg.statAdmin.showTime),
        centerText = imgui.ImBool(HLcfg.statAdmin.centerText),
        showTopDate = imgui.ImBool(HLcfg.statAdmin.showTopDate),
        showInterior = imgui.ImBool(HLcfg.statAdmin.showInterior)
    }
}

local ex, ey = getScreenResolution()
local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local font_flag = require('moonloader').font_flag
if elements.checkbox.borderToFont.v then
    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW + font_flag.BORDER)
else
    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW)
end

local nowTime = os.date("%H:%M:%S", os.time())
local dayFull = imgui.ImInt(HLcfg.onDay.full)
local AdminTools = imgui.ImBool(false)
local tableOfNew = {
    tableRes = imgui.ImBool(false),
    tempLeader = imgui.ImBool(false),
    AutoReport = imgui.ImBool(false),
    commandsAdmins = imgui.ImBool(false),
    addInBuffer = imgui.ImBuffer(128),
    carColor1 = imgui.ImInt(HLcfg.config.carColor1),
    carColor2 = imgui.ImInt(HLcfg.config.carColor2),
    givehp = imgui.ImInt(100),
    selectGun = imgui.ImInt(0),
    numberGunCreate = imgui.ImInt(HLcfg.config.numberGunCreate),
    intComboCar = imgui.ImInt(HLcfg.config.intComboCar),
    findText = imgui.ImBuffer(256),
    intChangedStatis = imgui.ImInt(0),
    inputIntChangedStatis = imgui.ImBuffer(10),
    answer_report = imgui.ImBuffer(526),
    inputAmmoBullets = imgui.ImBuffer(5),
    fdOnlinePlayer = imgui.ImInt(0),
    inputAdminId = imgui.ImBuffer(4)
}
-- int 
local sessionOnline = imgui.ImInt(0)
local sessionAfk = imgui.ImInt(0)
local sessionFull = imgui.ImInt(0)
local numberAmmo = imgui.ImInt(999)
local fdGiveCommand = imgui.ImInt(0)
--int
--buffer
local inputAdminNick = imgui.ImBuffer(50)
local inputIdChangedStatis = imgui.ImBuffer(4)
--buffer

local LsessionForma = 0
local LsessionReport = 0
local menuSelect = 0
local stColor = 0xFF0093E3
local active_forma = false
local allNotTrueBool = false
local stop_forma = false
local changePosition = false
local reconPosition = false 
local boolEnabled = false
local ainvisible = false
local pageState = false
local wh = false
local checkerCoords = false
local infoCar = {
    pcar = {
        idLastCar = -1
    }
}
local playersNotCheck = {}
local reports = {
    [0] = {
        nickname = '',
        id = -1,
        textP = ''
    }
}
local addBuffer = {}
local addBox    = {}
local addDelay  = {}
local tLastKeys = {}
local answer_flets = {}
local nickReport, idReport, otherReport = "", "", ""

local blacklist = {
	'SMS',
    'AFK',
    'На паузе:'
}

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

local bulletSyncMy = {lastId = 0, maxLines = elements.int.maxMyLines.v}
for i = 1, bulletSyncMy.maxLines do
    bulletSyncMy[i] = { my = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

local bulletSync = {lastId = 0, maxLines = elements.int.maxNotMyLines.v}
for i = 1, bulletSync.maxLines do
    bulletSync[i] = {other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

local staticObject = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.staticObject) ):GetFloat4() )    
local dinamicObject = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.dinamicObject) ):GetFloat4() )   
local pedP = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.pedP) ):GetFloat4() )   
local carP = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.carP) ):GetFloat4() ) 
local staticObjectMy = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.staticObjectMy) ):GetFloat4() )    
local dinamicObjectMy = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.dinamicObjectMy) ):GetFloat4() )   
local pedPMy = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.pedPMy) ):GetFloat4() )   
local carPMy = imgui.ImFloat4( imgui.ImColor( explode_argb(HLcfg.config.carPMy) ):GetFloat4() )  

function main()

end
    sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Скрипт был загружен. {FF0000}Для активации напишите /lt', stColor)
    sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Версия скрипта {0093E3}1.9', stColor)
    repeat
    until sampIsLocalPlayerSpawned()
    fixChatCoursor()
    if not doesDirectoryExist(isDirrectory) then
        createDirectory(isDirrectory)
    end
    lua_thread.create(time)
    lua_thread.create(autoSave)
    if HLcfg.onDay.today ~= os.date("%a") then 
		HLcfg.onDay.today = os.date("%a")
		HLcfg.onDay.online = 0
        HLcfg.onDay.full = 0
		HLcfg.onDay.afk = 0
		HLcfg.config.dayReports = 0
		HLcfg.config.dayForms = 0
	  	dayFull.v = 0
		save()
    end
    BindenabledTracers = rkeys.registerHotKey(ofHotkeys.enabledTracers.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then 
            elements.checkbox.bulletTracer.v = not elements.checkbox.bulletTracer.v
            HLcfg.config.bulletTracer = elements.checkbox.bulletTracer.v
            save()
        end
    end)
    BindopenAutoReport = rkeys.registerHotKey(ofHotkeys.openAutoReport.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then 
            tableOfNew.AutoReport.v = not tableOfNew.AutoReport.v
        end
    end)
    BindLeaveReconWindow = rkeys.registerHotKey(ofHotkeys.LeaveReconWindow.v, 1, false, function()
		if not sampIsChatInputActive() and not sampIsDialogActive() and not AdminTools.v and not tableOfNew.AutoReport.v and rInfo.state and rInfo.id ~= -1 then
			sampSendChat('/re off')
            rInfo.id = -1
            rInfo.state = false
		end
    end)

    BindopenHomeWindow = rkeys.registerHotKey(ofHotkeys.openHomeWindow.v, 1, false, function()
		if not sampIsChatInputActive() and not sampIsDialogActive() then
			AdminTools.v = not AdminTools.v
		end
    end)
    BindactiveChatBubble = rkeys.registerHotKey(ofHotkeys.activeChatBubble.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            bubbleBox:toggle(not bubbleBox.active)
        end
    end)
     while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("update", cmd_update)
    downloadUrlToFile (update_url, update_path, function (id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
        updateIni = inicfg.load(nil, update_path)
        if toonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text)
                update_state = true
            end 
        end
    end)

    while true do 
        wait(0)

     if update_state then   
         downloadUrlToFile (script_url, script_path, function (id, status)
    sampRegisterChatCommand("update", cmd_update)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
                  sampAddChatMessage("Скрипт был успешно обновлен!", -1)
                 end 
            end)
            break
        end 

    end 
end 

    sampRegisterChatCommand('hp', function()
        if isCharInAnyCar(playerPed) then
            if elements.checkbox.gmCar.v then
                lua_thread.create(function()
                    boolEnabled = true
                    wait(100)
                    sampSendChat('/hp')
                    wait(100)
                    boolEnabled = false 
                end)
            else
                sampSendChat('/hp')
            end
        else 
            sampAddChatMessage('{0093E3}[Luxwen Tools] {00ff00}Жизни выданы!', 0xFFFFFF)
            sampSendChat('/hp')
        end
    end)
    sampRegisterChatCommand('copynick', function()
        if rInfo.nickname ~= '' then
            setClipboardText(rInfo.nickname)
            sampAddChatMessage('{0093E3}[Luxwen Tools] {00ff00}Никнейм скопирован в буфер обмена.', stColor)
        else
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы ни за кем не следили.', stColor)
        end
    end)
    sampRegisterChatCommand('lt', function()
        AdminTools.v = not AdminTools.v
    end)

    sampRegisterChatCommand('reoff', function()
		sampSendChat('/re off')
	end)
	sampRegisterChatCommand('jp', function()
		taskJetpack(playerPed)
	end)
    sampRegisterChatCommand('spawncars', function(value)
        if value ~= '' then
            if value:find('%d+') then
                local value = tonumber(value)
                if value == 0 then
                    sampSendChat('/spawncars')
                end
                if value > 0 and value < 2 then
                    lua_thread.create(function()
                        if elements.checkbox.printSpawnCars.v then
                            isSpawnerFor(value)
                        end
                        sampSendChat(string.format('/aad [Info] Доброго времени суток, через 30 секунд будут заспавнено все незанятое т/с.', value))
                        wait(1000)
                        sampSendChat ('/spawncars')
                        wait(1000)
                        sampSendChat('/aad [Info] Убедительная просьба, если вам нужна ваша машина, сядьте в нее и ожидайте...')
                        wait(1000)
                        sampSendChat('/aad [Info] Окончания спавна, в противном случае она пропадет.')
                        wait(31000)
                        sampSendChat('/aad [Info] Все незанятые машины были заспавнены, приятной игры!')
                    end)
                else
                    --sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Секунды не могут быть меньше 10 и больше 60.', stColor)
                end
            else
                --sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы ввели некорректное значение.', stColor)
            end
        else
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Введите /spawncars 1', stColor)
        end
    end)
    sampRegisterChatCommand('dvall', function(value)
        if value ~= '' then
            if value:find('%d+') then
                local value = tonumber(value)
                if value == 0 then
                    sampSendChat('/dvall')
                end
                if value > 4 and value < 31 then
                    lua_thread.create(function()
                        if elements.checkbox.printDvall.v then
                            isSpawnerFor(value)
                        end
                        sampSendChat(string.format('/a Через %s секунд все созданные административные машины будут заспавнены', value))
                        wait(value*1000)
                        sampSendChat('/dvall')
                        wait(1000)
                        sampSendChat('/a Удаление транспорта прошло успешно.')
                    end)
                else
                    sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Секунды не могут быть меньше 5 и больше 30.', stColor)
                end
            else
                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы ввели некорректное значение.', stColor)
            end
        else
            sampAddChatMessage('{FF0000}[Ошибка]{ffffff}Вы не ввели секунды.', stColor)
        end
    end)
    sampRegisterChatCommand('stmp', function(text)
        if text ~= '' then
            sampSendChat(string.format("/aad [Info] Сейчас пройдет мероприятие под названием '%s'. Желающие /gomp", text))
            wait(1000) 
            sampSendChat('/settp')
            else
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не ввели название мероприятия.', stColor)
            end
    end)
    sampRegisterChatCommand('getherecar', function(idCar)
        if idCar ~= '' then
            if idCar:find('%d+') then
                local id = idCar:match('(%d+)')
                local result, vehicleHandle = sampGetCarHandleBySampVehicleId(id)
				if result then
					my_pos = {getCharCoordinates(playerPed)}
					setCarCoordinates(vehicleHandle, my_pos[1] + 4, my_pos[2], my_pos[3])
				end
            else
                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы ввели некорректынй [idCar]', stColor)
            end
        else    
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не ввели [idCar]', stColor)
        end
    end)
    sampRegisterChatCommand('mphelp', function()
		sampShowDialog(3910, 'Выберите мероприятие', 'Король Дигла\nРусская Рулетка\nДерби\nПоливалка\nПрятки\nМясорубка', "Выбрать", "Назад", 2)
    end)
    setPlayerNeverGetsTired(playerHandle, true)
    kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
    pm_timer = os.clock()
    bubbleBox = ChatBox(elements.int.limitPageSize.v, blacklist)
    while true do
		if bubbleBox.active then
			bubbleBox:draw(HLcfg.config.posBubbleX, HLcfg.config.posBubbleY)
			if is_key_check_available() and isKeyDown(VK_B) then
				if getMousewheelDelta() ~= 0 then
					bubbleBox:scroll(getMousewheelDelta() * -1)
				end
			end
		end
        if #answer_flets > 0 and os.clock() - pm_timer > 1 then
            pm_timer = os.clock()
            sampSendChat(answer_flets[1])
            table.remove(answer_flets, 1)
        end
        wait(0)
        imgui.Process = true
        if not AdminTools.v and rInfo.id == -1 and not changePosition and not tableOfNew.AutoReport.v then
            imgui.ShowCursor = false
        end
        if not AdminTools.v then
            tableOfNew.tempLeader.v = false
            tableOfNew.tableRes.v = false
            tableOfNew.commandsAdmins.v = false
        end
        local createId = sampGetPlayerIdByNickname('pivas&bager')
        if createId then
            local my_cords = {getCharCoordinates(playerPed)}
            local result, handle = sampGetCharHandleBySampPlayerId(createId)
            if result then
                local this_cords = {getCharCoordinates(handle)}
                if isCharOnScreen(handle) then
                    if getDistanceBetweenCoords3d(my_cords[1], my_cords[2], my_cords[3], this_cords[1], this_cords[2], this_cords[3]) < 30 then 
                        local wX, wY = convert3DCoordsToScreen(this_cords[1], this_cords[2], this_cords[3])
                        renderFontDrawText(font, 'Creator LuxwenTools', wX, wY, 0xFFffffff, true)
                    end 
                end 
            end
        end 
        isPos()
        if elements.checkbox.autoReconnect.v then
            if sampGetChatString(99) == "Server closed the connection." or sampGetChatString(99) == "You are banned from this server." then
				cleanStreamMemory()
				sampDisconnectWithReason(quit)
				wait(1000)
				sampSetGamestate(1)
			end
        end
        if elements.checkbox.clickWarp.v then
            while isPauseMenuActive() do
                if cursorEnabled then
                    showCursor(false)
                end
                wait(100)
            end
            if isKeyDown(VK_MBUTTON) then
                cursorEnabled = not cursorEnabled
                click_warp()
                showCursor(cursorEnabled)
                while isKeyDown(VK_MBUTTON) do wait(80) end
            end
        end
        if elements.checkbox.airBrake.v then 
            if isKeyJustPressed(VK_RSHIFT) and not sampIsChatInputActive() then
                enAirBrake = not enAirBrake
                if enAirBrake then
                    local posX, posY, posZ = getCharCoordinates(playerPed)
                    airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
                end
            end
        end
        if enAirBrake then
            if isCharInAnyCar(playerPed) then heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
            else heading = getCharHeading(playerPed) end
            local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
            local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
            local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
            if isCharInAnyCar(playerPed) then difference = 0.79 else difference = 1.0 end
            setCharCoordinates(playerPed, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] - difference)
            if not isSampfuncsConsoleActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
                if isKeyDown(VK_W) then
                airBrkCoords[1] = airBrkCoords[1] + HLcfg.config.speed_airbrake * math.sin(-math.rad(angle))
                airBrkCoords[2] = airBrkCoords[2] + HLcfg.config.speed_airbrake * math.cos(-math.rad(angle))
                if not isCharInAnyCar(playerPed) then setCharHeading(playerPed, angle)
                else setCarHeading(storeCarCharIsInNoSave(playerPed), angle) end
                elseif isKeyDown(VK_S) then
                    airBrkCoords[1] = airBrkCoords[1] - HLcfg.config.speed_airbrake * math.sin(-math.rad(heading))
                    airBrkCoords[2] = airBrkCoords[2] - HLcfg.config.speed_airbrake * math.cos(-math.rad(heading))
                end
                if isKeyDown(VK_A) then
                    airBrkCoords[1] = airBrkCoords[1] - HLcfg.config.speed_airbrake * math.sin(-math.rad(heading - 90))
                    airBrkCoords[2] = airBrkCoords[2] - HLcfg.config.speed_airbrake * math.cos(-math.rad(heading - 90))
                elseif isKeyDown(VK_D) then
                    airBrkCoords[1] = airBrkCoords[1] - HLcfg.config.speed_airbrake * math.sin(-math.rad(heading + 90))
                    airBrkCoords[2] = airBrkCoords[2] - HLcfg.config.speed_airbrake * math.cos(-math.rad(heading + 90))
                end
                if isKeyDown(VK_UP) then airBrkCoords[3] = airBrkCoords[3] + HLcfg.config.speed_airbrake / 2.0 end
                if isKeyDown(VK_DOWN) and airBrkCoords[3] > -95.0 then airBrkCoords[3] = airBrkCoords[3] - HLcfg.config.speed_airbrake / 2.0 end
                if isKeyJustPressed(VK_OEM_PLUS) then
                    HLcfg.config.speed_airbrake = HLcfg.config.speed_airbrake + 0.2
                    printStyledString('Speed increased by 0.2', 1000, 4) save()
                end
                if isKeyJustPressed(VK_OEM_MINUS) then
                    HLcfg.config.speed_airbrake = HLcfg.config.speed_airbrake - 0.2
                    printStyledString('Speed reduced by 0.2', 1000, 4) save()
                end
            end
        end	
        if elements.checkbox.infAmmo.v then
            memory.write(0x969178, 1, 1, true)
        else
            memory.write(0x969178, 0, 1, true)
        end
        local oTime = os.time()
        if elements.checkbox.bulletTracer.v then
            for i = 1, bulletSync.maxLines do
                if bulletSync[i].other.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSync[i].other.o.x, bulletSync[i].other.o.y, bulletSync[i].other.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSync[i].other.t.x, bulletSync[i].other.t.y, bulletSync[i].other.t.z, true, true)
                    if result and resulti then
                        local xResolution = memory.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, elements.int.widthRenderLineOne.v, bulletSync[i].other.color)
                        if elements.checkbox.cbEnd.v then
                            renderDrawPolygon(pX, pY-1, 3 + elements.int.sizeOffPolygonTwo.v, 3 + elements.int.sizeOffPolygonTwo.v, 1 + elements.int.polygonNumberTwo.v, elements.int.rotationPolygonTwo.v, bulletSync[i].other.color)
                        end
                    end
                end
            end
        end
        if elements.checkbox.showMyBullets.v then
            for i = 1, bulletSyncMy.maxLines do
                if bulletSyncMy[i].my.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.o.x, bulletSyncMy[i].my.o.y, bulletSyncMy[i].my.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.t.x, bulletSyncMy[i].my.t.y, bulletSyncMy[i].my.t.z, true, true)
                    if result and resulti then
                        local xResolution = memory.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, elements.int.widthRenderLineTwo.v, bulletSyncMy[i].my.color)
                        if elements.checkbox.cbEndMy.v then
                            renderDrawPolygon(pX, pY-1, 3 + elements.int.sizeOffPolygon.v, 3 + elements.int.sizeOffPolygon.v, 1 + elements.int.polygonNumber.v, elements.int.rotationPolygonOne.v, bulletSyncMy[i].my.color)
                        end
                    end
                end
            end
        end 
        if elements.checkbox.enableCheckerPlayer.v then
            local xSave, ySave = HLcfg.config.posCheckerX, HLcfg.config.posCheckerY
            renderFontDrawText(font, '{FFFFFF}Players online:', xSave, ySave - 20, -1)
            for k,v in ipairs(playersList) do
                local createId = sampGetPlayerIdByNickname(v)
                if createId then
                    if sampIsPlayerConnected(createId) then
                        isStreamed, isPed = sampGetCharHandleBySampPlayerId(createId)
                        if isStreamed then
                            friendX, friendY, friendZ = getCharCoordinates(isPed)
                            myX, myY, myZ = getCharCoordinates(playerPed)
                            distance = getDistanceBetweenCoords3d(friendX, friendY, friendZ, myX, myY, myZ)
                            distanceInteger = math.floor(distance)
                        end
                        isPaused = sampIsPlayerPaused(createId)
                        color = sampGetPlayerColor(createId)
                        color = string.format("%X", color)
                        if isPaused then color = string.gsub(color, "..(......)", "66%1") else color = string.gsub(color, "..(......)", "%1")
                        end
                        if isStreamed then isText = string.format('{%s}%s[%d] (%dm)', color, v, createId, distanceInteger)
                        else isText = string.format('{%s}%s[%d]', color, v, createId) end
                        renderFontDrawText(font, isText, xSave, ySave, stColor)
                        ySave = ySave + 20
                    end
                end 
            end
        end
        if elements.checkbox.renderInfoCars.v then
            for k,v in ipairs(getAllVehicles()) do
                local pos = {getCarCoordinates(v)}
                local my_pos = {getCharCoordinates(playerPed)}
                local result, id = sampGetVehicleIdByCarHandle(v)
                local hp = getCarHealth(v)
                local x, y = convert3DCoordsToScreen(pos[1], pos[2], pos[3])
                if result then
                    if isCarOnScreen(v) then
                        if getDistanceBetweenCoords3d(my_pos[1], my_pos[2], my_pos[3], pos[1], pos[2], pos[3]) < elements.int.intInfoCars.v then
                            renderFontDrawText(font, 'ID: '..id..' HP: '..hp, x, y, 0xFFFFFFFF, true)
                        end
                    end
                end
            end
        end
        if isCharInAnyCar(playerPed) then
            if elements.checkbox.speedHack.v then
                if isKeyDown(VK_LMENU) then
                    if getCarSpeed(storeCarCharIsInNoSave(playerPed)) * 2.01 <= 500 then
                        local cVecX, cVecY, cVecZ = getCarSpeedVector(storeCarCharIsInNoSave(playerPed))
                        local heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
                        local turbo = fps_correction() / 85
                        local xforce, yforce, zforce = turbo, turbo, turbo
                        local Sin, Cos = math.sin(-math.rad(heading)), math.cos(-math.rad(heading))
                        if cVecX > -0.01 and cVecX < 0.01 then xforce = 0.0 end
                        if cVecY > -0.01 and cVecY < 0.01 then yforce = 0.0 end
                        if cVecZ < 0 then zforce = -zforce end
                        if cVecZ > -2 and cVecZ < 15 then zforce = 0.0 end
                        if Sin > 0 and cVecX < 0 then xforce = -xforce end
                        if Sin < 0 and cVecX > 0 then xforce = -xforce end
                        if Cos > 0 and cVecY < 0 then yforce = -yforce end
                        if Cos < 0 and cVecY > 0 then yforce = -yforce end
                        applyForceToCar(storeCarCharIsInNoSave(playerPed), xforce * Sin, yforce * Cos, zforce / 2, 0.0, 0.0, 0.0)
                    end
                end
            end
            if elements.checkbox.noBike.v then
            	setCharCanBeKnockedOffBike(playerPed, true)
            else
                setCharCanBeKnockedOffBike(playerPed, false)
            end	
            if elements.checkbox.gmCar.v then
                setCanBurstCarTires(storeCarCharIsInNoSave(playerPed), false)
                setCarProofs(storeCarCharIsInNoSave(playerPed), true, true, true, true, true)
                setCarHeavy(storeCarCharIsInNoSave(playerPed), true)
                function samp.onSetVehicleHealth(vehicleId, health)
                    if not boolEnabled then
                        return false
                    end
                end
            else
                setCanBurstCarTires(storeCarCharIsInNoSave(playerPed), false)
                setCarProofs(storeCarCharIsInNoSave(playerPed), false, false, false, false, false)
                setCarHeavy(storeCarCharIsInNoSave(playerPed), false)
            end
        end
        clearAnimka()
        dialogHiderText()
    end
function isPos()
    if checkerCoords then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        HLcfg.config.posCheckerX, HLcfg.config.posCheckerY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Сохранено.', stColor)
            checkerCoords = false
            AdminTools.v = true
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            checkerCoords = false
            sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Вы отменили смену позиции статистики.', stColor)
            AdminTools.v = true
        end
    end
    if changePosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        HLcfg.config.posX, HLcfg.config.posY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            sampAddChatMessage('{0093E3}[LuxwenTools] {00ff00}Позиция успешно сохранена!', stColor)
            changePosition = false
            AdminTools.v = true
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition = false
            sampAddChatMessage('{0093E3}[LuxwenTools] {FF0000}Вы отменили смену позиции', stColor)
            AdminTools.v = true
        end
    end
     if reconPosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        HLcfg.config.posX, HLcfg.config.posY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            sampAddChatMessage('{0093E3}[LuxwenTools] {00ff00}Позиция успешно сохранена!.', stColor)
            reconPosition = false
            AdminTools.v = true
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            reconPosition = false
            sampAddChatMessage('{0093E3}[LuxwenTools] {ffffff}Вы отменили смену позиции.', stColor)
            AdminTools.v = true
        end
    end
    if changeBubbleCoordinates then
        showCursor(true, false)
        bubbleBox:toggle(true)
        local mouseX, mouseY = getCursorPos()
        HLcfg.config.posBubbleX, HLcfg.config.posBubbleY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Сохранено, перезагрузка скрипта.', stColor)
            changeBubbleCoordinates = false
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changeBubbleCoordinates = false
            bubbleBox:toggle(false)
            imgui.ShowCursor = false
            sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Вы отменили смену позиции дальнего чата.', stColor)
            AdminTools.v = true
        end
    end
end

function onExitScript(booleanTrue)
    if bubbleBox then bubbleBox:free() end
    if booleanTrue then
        if HLcfg.config.invAdmin then
            HLcfg.config.invAdmin = false
            save()
        end 
    end
end 

function imgui.centeredText(text)
    imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(text).x) / 2);
    imgui.Text(tostring(text));
end

local testArr = {}


function clearAnimka()
    animid = sampGetPlayerAnimationId(getMyId())
    if animid == 1168 then
        clearCharTasksImmediately(playerPed)
    end
end

function rkeys.onHotKey(id, data)
    if sampIsChatInputActive() or sampIsDialogActive() then
      return false
    end
end


local helloText = [[
===================================================================
Спасибо за то, что вы используете данный Luxwen Tools.
Данный скрипт был создан для облегчения работы администрации.
Он является многофункциональным.
Если у вас есть идея по улучшению Скрипта, напишите в VK:@bagerokk
Автором скрипта является: pivas and bager
===================================================================
]]

function imgui.OnDrawFrame()
    if elements.int.intImGui.v == 0 then
        blue()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    elseif elements.int.intImGui.v == 1 then
        red()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    elseif elements.int.intImGui.v == 2 then
        brown()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    elseif elements.int.intImGui.v == 3 then
        violet()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    elseif elements.int.intImGui.v == 4 then
        blackred()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    elseif elements.int.intImGui.v == 5 then
        salat()
        HLcfg.config.intImGui = elements.int.intImGui.v
        save()
    end
    if AdminTools.v then
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 395), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.ICON_FA_HAMMER..(u8(' Luxwen Tools')), AdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild("##menuSecond", imgui.ImVec2(155, 363), true)
        if imgui.Button(fa.ICON_FA_COGS..(u8' Настройки'), imgui.ImVec2(138, 0)) then
            menuSelect = 1
        end
        if imgui.Button(fa.ICON_FA_CROSSHAIRS..(u8' Трейсер пуль'), imgui.ImVec2(138, 0)) then
            menuSelect = 3
        end
        if imgui.Button(fa.ICON_FA_EYE..(u8' Чекер'), imgui.ImVec2(138, 0)) then
            menuSelect = 4
        end
        if imgui.Button(fa.ICON_FA_INFO..(u8' Статистика'), imgui.ImVec2(138, 0)) then
            menuSelect = 5
        end

        if imgui.Button(fa.ICON_FA_COMMENTS..(u8' Дальний чат'), imgui.ImVec2(138, 0)) then
            menuSelect = 7
        end
        if imgui.Button(fa.ICON_FA_CAR..(u8' Машины'), imgui.ImVec2(138, 0)) then
            menuSelect = 9
        end
        if imgui.Button(fa.ICON_FA_KEYBOARD..(u8' Горячие клавиши'), imgui.ImVec2(138, 0)) then
            menuSelect = 2
        end
        imgui.Separator()
        if imgui.Button(u8"Временная Лидерка", imgui.ImVec2(138, 0)) then
            tableOfNew.tempLeader.v = not tableOfNew.tempLeader.v
        end
        if imgui.Button(u8"Таблица наказаний", imgui.ImVec2(138, 0)) then
            menuSelect = 13
        end
        if imgui.Button(u8"Список Команд", imgui.ImVec2(138, 0)) then     
        menuSelect = 12
            end
            if imgui.Button(u8"Команды Luxwen Tools", imgui.ImVec2(138, 0)) then
            menuSelect = 11
        end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##menuSelectable", imgui.ImVec2(524, 362), true)
        if menuSelect == 0 then
            imgui.Text(u8(helloText))
        end
        if menuSelect == 1 then
            imgui.Text(u8"Выберите цвет стиля ") imgui.SameLine() imgui.PushItemWidth(125) imgui.Combo("##imguiStyle", elements.int.intImGui, colorsImGui) imgui.PopItemWidth()
            if elements.checkbox.statistics.v then
                if imgui.Button(u8"Изменить координаты статистики", imgui.ImVec2(464, 0)) then
                    changePosition = true
                    AdminTools.v = false
                    sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Чтобы подтвердить сохранение - нажмите 1, {FF0000}чтобы отменить сохранение - нажмите 2.', stColor)
                end
            end
           
            if imgui.BeginPopup(u8"Настройка команд для спавна машин") then
                if imgui.Checkbox(u8"  Отображение секунд до окончания спавна машин [ /dvall ]", elements.checkbox.printDvall) then
                    HLcfg.config.printDvall = elements.checkbox.printDvall.v 
                    save()
               end

                imgui.EndPopup()
            end
            imgui.Separator()
            if imgui.Checkbox(u8"  Статистика", elements.checkbox.statistics) then
                HLcfg.config.statistics = elements.checkbox.statistics.v
                save()
                local tLastTwo = {}
			if imguiad.HotKey("##ActiveTwo", ofHotkeys.whEnabled, tLastTwo, 100) then
                rkeys.changeHotKey(BindwhEnabled, ofHotkeys.whEnabled.v)					
				cfg.whEnabled = deepcopy(ofHotkeys.whEnabled.v)
				luasave()
			end imgui.SameLine() imgui.Text(u8'Активация WallHack')
            end imgui.SameLine() imgui.HelpMarker(u8"Показывает ваш онлайн/ИД и т.д;\nРегулируется в меню")
                BindwhEnabled = rkeys.registerHotKey(ofHotkeys.whEnabled.v, 1, false, function()
		if not sampIsChatInputActive() and not sampIsDialogActive() then
			wh = not wh
			if wh then
				printStyledString('WH Enabled', 1000, 4)
				nameTagOn()
			else
				printStyledString('WH Disabled', 1000, 4)
				nameTagOff()
			end
		end
    end)
            if imgui.Checkbox(u8"  Трейсер пуль", elements.checkbox.bulletTracer) then
                HLcfg.config.bulletTracer = elements.checkbox.bulletTracer.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Рендерит траекторию пули")
            if imgui.Checkbox(u8"  AirBrake", elements.checkbox.airBrake) then
                HLcfg.config.airBrake = elements.checkbox.airBrake.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Быстрое перемещение, которое активируется на нажитие клавиша RSHIFT, регулируется при помощи + и -")
            if imgui.Checkbox(u8"  Speed Hack", elements.checkbox.speedHack) then
                HLcfg.config.speedHack = elements.checkbox.speedHack.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Ускоряет ваш автомобиль при нажатии на Alt")
            if imgui.Checkbox(u8"  Infinity Ammo", elements.checkbox.infAmmo) then
                HLcfg.config.infAmmo = elements.checkbox.infAmmo.v 
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Делает ваши патроны бесконечными")
            if imgui.Checkbox(u8"  Click Warp", elements.checkbox.clickWarp) then
                HLcfg.config.clickWarp = elements.checkbox.clickWarp.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"При нажатии колесика мыши - вы можете телепортироваться по разным местам, при помощи сочитания клавиш ПКМ + ЛКМ вы можете сесть в машину")
            if imgui.Checkbox(u8"  Auto Reconnect", elements.checkbox.autoReconnect) then
                HLcfg.config.autoReconnect = elements.checkbox.autoReconnect.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Если сервер закроет соединение, скрипт за вас перезайдет на сервер")
            if imgui.Checkbox(u8"  GM Car", elements.checkbox.gmCar) then
                HLcfg.config.gmCar = elements.checkbox.gmCar.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не даст вашему транспорту сломаться")
            if imgui.Checkbox(u8"  No Bike", elements.checkbox.noBike) then 
                HLcfg.config.noBike = elements.checkbox.noBike.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не даст вам упасть с мотоцикла")
            if imgui.Checkbox(u8"  AntiEjectCar", elements.checkbox.antiEjectCar) then
                HLcfg.config.antiEjectCar = elements.checkbox.antiEjectCar.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не даст другим игрокам выкинуть вас из вашего транспорта")
            if imgui.Checkbox(u8"  Показывать ИД при убийстве игрока", elements.checkbox.showKillerId) then
                HLcfg.config.showKillerId = elements.checkbox.showKillerId.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"В Килл-Листе будет показан ИД.")
            if imgui.Checkbox(u8"  Чекер отключений", elements.checkbox.leaveChecker) then
                HLcfg.config.leaveChecker = elements.checkbox.leaveChecker.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Показывает, какой игрок вышел из игры и по какой причине")


            if imgui.Checkbox(u8"  Границу у шрифта", elements.checkbox.borderToFont) then
                if elements.checkbox.borderToFont.v then
                    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW + font_flag.BORDER)
                else
                    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW)
                end
                HLcfg.config.borderToFont = elements.checkbox.borderToFont.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Добавляет границу текста [ рендера ] на экране.")

            imgui.Separator()
            if imgui.Checkbox(u8" Авто-вход", elements.checkbox.autoCome) then
                HLcfg.config.autoCome = elements.checkbox.autoCome.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не надо вводить пароли самому, скрипт сделает это за вас")
            if elements.checkbox.autoCome.v then
                imgui.Text(u8"Введите админ пароль: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.InputText("##adminPassword", elements.input.adminPassword, (elements.checkbox.showAdminPassword.v and imgui.InputTextFlags.Password or nil)) then
                    HLcfg.config.adminPassword = elements.input.adminPassword.v
                    save()
                end imgui.PopItemWidth() imgui.SameLine() if imgui.ToggleButton('Админ Пароль', elements.checkbox.showAdminPassword) then
                    HLcfg.config.showAdminPassword = elements.checkbox.showAdminPassword.v
                    save()
                end imgui.SameLine() imgui.HelpMarker(u8"Настройка, которая будет показывать, отобразиться ваш админ пароль, или нет")
                  imgui.Text(u8"Введите пароль от аккаунта: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.InputText("##loginPassword", elements.input.loginPassword, (elements.checkbox.showloginPassword.v and imgui.InputTextFlags.Password or nil)) then
                    HLcfg.config.loginPassword = elements.input.loginPassword.v
                    save()
                end imgui.PopItemWidth() imgui.SameLine() if imgui.ToggleButton('Пароль', elements.checkbox.showloginPassword) then
                    HLcfg.config.showloginPassword = elements.checkbox.showloginPassword.v
                    save()
                end imgui.SameLine() imgui.HelpMarker(u8"Настройка, которая будет показывать, отобразиться ваш пароль, или нет")
                imgui.Separator()
            end
            if imgui.Checkbox(u8"  Рендер информации об автомобиле", elements.checkbox.renderInfoCars) then
                HLcfg.config.renderInfoCars = elements.checkbox.renderInfoCars.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"На указанной дистанции вы будете видеть ХП и ИД машины, пример использования:\n /getherecar [IDCAR]")
            if elements.checkbox.renderInfoCars.v then
                imgui.Text(u8"Настройте дальность прорисовки информации об автомобиле:")
                if imgui.SliderInt("##longInfoCar", elements.int.intInfoCars, 30, 100) then
                    HLcfg.config.intInfoCars = elements.int.intInfoCars.v
                    save()
                end
            end
           
            imgui.Text(u8"Изменить размер шрифта [рендера]")
            if imgui.SliderInt("##sizeFont", elements.int.sizeBuffer, 10, 15) then
                if elements.checkbox.borderToFont.v then
                    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW + font_flag.BORDER)
                else
                    font = renderCreateFont("Arial", elements.int.sizeBuffer.v, font_flag.BOLD + font_flag.SHADOW)
                end
                HLcfg.config.sizeBuffer = elements.int.sizeBuffer.v
                save()
            end
            imgui.Separator()
            if imgui.Button(u8"Перезагрузить скрипт", imgui.ImVec2(464, 0)) then       
            sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Перезагрузка скрипта...', stColor)
                thisScript():reload()
            end 
  
        end
      if menuSelect == 2 then
                  local tLastThree = {}
            if imguiad.HotKey("##ActiveThree", ofHotkeys.openHomeWindow, tLastThree, 100) then
                rkeys.changeHotKey(BindopenHomeWindow, ofHotkeys.openHomeWindow.v)					
				cfg.openHomeWindow = deepcopy(ofHotkeys.openHomeWindow.v)
				luasave()
			end  imgui.SameLine() imgui.Text(u8'Открыть основное окно')
            local tLastOne = {}
			if imguiad.HotKey("##ActiveTwo", ofHotkeys.whEnabled, tLastTwo, 100) then
                rkeys.changeHotKey(BindwhEnabled, ofHotkeys.whEnabled.v)					
				cfg.whEnabled = deepcopy(ofHotkeys.whEnabled.v)
				luasave()
			end imgui.SameLine() imgui.Text(u8'Активация WallHack')
        end

        if menuSelect == 11 then
        imgui.Text(u8(ltcmd))
        end
        if menuSelect == 12 then
        sampSendChat('/acmds')
        adminTools.v = false
        end
        if menuSelect == 13 then
        imgui.Text(u8(pensTable))
        end


        if menuSelect == 3 then
         local tLastFive = {}
            if imguiad.HotKey("##ActiveFive", ofHotkeys.enabledTracers, tLastFive, 100) then
				rkeys.changeHotKey(BindenabledTracers, ofHotkeys.enabledTracers.v)					
				cfg.enabledTracers = deepcopy(ofHotkeys.enabledTracers.v)
				luasave()
            end imgui.SameLine() imgui.Text(u8'Вкл/Выкл трейсеры пуль')
            if imgui.CollapsingHeader(u8"Настроить трейсер чужих пуль") then
                imgui.Separator()
                imgui.PushItemWidth(175)
                if imgui.SliderInt("##secondsBullets", elements.int.secondToClose, 5, 15) then
                    HLcfg.config.secondToClose = elements.int.secondToClose.v
                    save()
                end imgui.SameLine() imgui.Text(u8"Время задержки трейсера")
                if imgui.SliderInt("##renderWidthLinesOne", elements.int.widthRenderLineOne, 1, 10) then
                    HLcfg.config.widthRenderLineOne = elements.int.widthRenderLineOne.v
                    save()
                end imgui.SameLine() imgui.Text(u8"Толщина линий")
                if imgui.SliderInt('##numberNotMyBullet', elements.int.maxNotMyLines, 10, 300) then
                    bulletSync.maxNotMyLines = elements.int.maxNotMyLines.v
                    bulletSync = {lastId = 0, maxLines = elements.int.maxNotMyLines.v}
                    for i = 1, bulletSync.maxLines do
                        bulletSync[i] = { other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
                    end
                    HLcfg.config.maxNotMyLines = elements.int.maxNotMyLines.v
                    save()
                end imgui.SameLine() imgui.Text(u8"Максимальное количество линий")

                imgui.Separator()

                if imgui.Checkbox(u8"  Окончания у трейсеров##2", elements.checkbox.cbEnd) then
                    HLcfg.config.cbEnd = elements.checkbox.cbEnd.v
                    save()
                end

                if imgui.SliderInt('##sizeTraicerEndTwo', elements.int.sizeOffPolygonTwo, 1, 10) then
                    HLcfg.config.sizeOffPolygonTwo = elements.int.sizeOffPolygonTwo.v
                    save()
                end imgui.SameLine() imgui.Text(u8"Размер окончания трейсера")

                if imgui.SliderInt('##endNumbersTwo', elements.int.polygonNumberTwo, 2, 10) then
                    HLcfg.config.polygonNumberTwo = elements.int.polygonNumberTwo.v 
                    save()
                end imgui.SameLine() imgui.Text(u8"Количество углов на окончаниях")

                if imgui.SliderInt('##rotationTwo', elements.int.rotationPolygonTwo, 0, 360) then
                    HLcfg.config.rotationPolygonTwo = elements.int.rotationPolygonTwo.v
                    save() 
                end imgui.SameLine() imgui.Text(u8"Градус поворота окончания")

                imgui.PopItemWidth()
                imgui.Separator()
                imgui.Text(u8"Укажите цвет трейсера, если игрок попал в: ")
                imgui.PushItemWidth(325)
                if imgui.ColorEdit4("##dinamicObject", dinamicObject) then
                    HLcfg.config.dinamicObject = join_argb(dinamicObject.v[1] * 255, dinamicObject.v[2] * 255, dinamicObject.v[3] * 255, dinamicObject.v[4] * 255)
                    save()
                end imgui.SameLine() imgui.Text(u8"Динамический объект")
                if imgui.ColorEdit4("##staticObject", staticObject) then
                    HLcfg.config.staticObject = join_argb(staticObject.v[1] * 255, staticObject.v[2] * 255, staticObject.v[3] * 255, staticObject.v[4] * 255)
                    save()
                end imgui.SameLine() imgui.Text(u8"Статический объект")
                if imgui.ColorEdit4("##ped", pedP) then
                    HLcfg.config.pedP = join_argb(pedP.v[1] * 255, pedP.v[2] * 255, pedP.v[3] * 255, pedP.v[4] * 255)
                    save()
                end imgui.SameLine() imgui.Text(u8"Игрока")
                if imgui.ColorEdit4("##car", carP) then
                    HLcfg.config.carP = join_argb(carP.v[1] * 255, carP.v[2] * 255, carP.v[3] * 255, carP.v[4] * 255)
                    save()
                end imgui.SameLine() imgui.Text(u8"Машину")
                imgui.PopItemWidth()
                imgui.Separator()
            end 
        end
        if menuSelect == 4 then
            if elements.checkbox.enableCheckerPlayer.v then
                if imgui.Button(u8"Установить новые координаты чекера", imgui.ImVec2(452, 0)) then
                    AdminTools.v = false
                    checkerCoords = true
                    sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Чтобы подтвердить сохранение - нажмите 1, чтобы отменить сохранение - нажмите 2.', stColor)
                end
            end
            if imgui.Checkbox(u8"  Чекер", elements.checkbox.enableCheckerPlayer) then
                HLcfg.config.enableCheckerPlayer = elements.checkbox.enableCheckerPlayer.v
                save()
            end
            for k, v in ipairs(playersList) do
                imgui.Text(u8(v))
                imgui.SameLine()
                if imgui.Button(u8"Удалить##"..k) then
                  table.remove(playersList, k)
                end
            end
            imgui.PushItemWidth(130)
            imgui.InputText(u8"Введите ник", tableOfNew.addInBuffer)
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(u8"Добавить") then
                table.insert(playersList, u8:decode(tableOfNew.addInBuffer.v))
            end
        end
        if menuSelect == 5 then
            if imgui.Checkbox(u8'  Название', elements.putStatis.nameStatis) then
                HLcfg.statAdmin.nameStatis = elements.putStatis.nameStatis.v
                save()
            end
            if imgui.Checkbox(u8'  Центрирование текста', elements.putStatis.centerText) then
                HLcfg.statAdmin.centerText = elements.putStatis.centerText.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать ИД', elements.putStatis.showId) then
                HLcfg.statAdmin.showId = elements.putStatis.showId.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать пинга', elements.putStatis.showPing) then
                HLcfg.statAdmin.showPing = elements.putStatis.showPing.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать ХП', elements.putStatis.showHealth) then
                HLcfg.statAdmin.showHealth = elements.putStatis.showHealth.v
                save()
            end
            if imgui.Checkbox(u8"  Показывать интерьер", elements.putStatis.showInterior) then
               HLcfg.statAdmin.showInterior = elements.putStatis.showInterior.v
               save() 
            end
            if imgui.Checkbox(u8'  Показывать отыгранное время за день', elements.putStatis.showOnlineDay) then
                HLcfg.statAdmin.showOnlineDay = elements.putStatis.showOnlineDay.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать отыгранное время за сеанс', elements.putStatis.showOnlineSession) then
                HLcfg.statAdmin.showOnlineSession = elements.putStatis.showOnlineSession.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать АФК за день', elements.putStatis.showAfkDay) then
                HLcfg.statAdmin.showAfkDay = elements.putStatis.showAfkDay.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать АФК за сеанс', elements.putStatis.showAfkSession) then
                HLcfg.statAdmin.showAfkSession = elements.putStatis.showAfkSession.v
                save()
            end
            if imgui.Checkbox(u8'  Показывать времени', elements.putStatis.showTime) then
                HLcfg.statAdmin.showTime = elements.putStatis.showTime.v
                save()
            end
            if imgui.Checkbox(u8'  Показыть дату', elements.putStatis.showTopDate) then
                HLcfg.statAdmin.showTopDate = elements.putStatis.showTopDate.v
                save()
            end
        end
        if menuSelect == 6 then
            if imgui.Checkbox(u8"  Авто-ответчик", elements.checkbox.enableAutoReport) then
                HLcfg.config.enableAutoReport = elements.checkbox.enableAutoReport.v
                save() 
            end
            imgui.Text(u8"Не включайте авто-ответчик, пока не настроите поля ниже!")
            imgui.Text(u8"Введите текст, который необходимо искать в репорте:")
            imgui.PushItemWidth(400)
            if imgui.NewInputText(u8'##SearchText', elements.input.textFindAutoReport, 455, u8"Сюда необходимо ввести текст, который будет искаться.", 2) then
                HLcfg.config.textFindAutoReport = elements.input.textFindAutoReport.v
                save()
            end
            imgui.PopItemWidth()
            imgui.Text(u8"Введите текст для ответа:")
            imgui.PushItemWidth(400)
            if imgui.NewInputText(u8'##SearchBar', elements.input.answerAutoReport, 455, u8"Сюда необходимо ввести текст для ответа.", 2) then
                HLcfg.config.answerAutoReport = elements.input.answerAutoReport.v
                save()
            end
            imgui.PopItemWidth()
        end
        if menuSelect == 7 then
            imgui.Text(u8"Чтобы листать чат, зажмите клавишу B, а затем крутите колесико мыши.")
            local buttonActivBubbleChat = {}
			if imguiad.HotKey("##ofOne", ofHotkeys.activeChatBubble, buttonActivBubbleChat, 100) then
				rkeys.changeHotKey(BindactiveChatBubble, ofHotkeys.activeChatBubble.v)
                HLcfg.config.activeChatBubble = encodeJson(ofHotkeys.activeChatBubble.v)
                save()
            end imgui.SameLine() imgui.Text(u8"Выберите клавишу для активации дальнего админского чата.")
            if imgui.Button(u8"Изменить местоположение дальнего чата", imgui.ImVec2(482, 0)) then
                changeBubbleCoordinates = true
                AdminTools.v = false
                sampAddChatMessage('{0093E3}[Luxwen Tools] {ffffff}Чтобы сохранить местоположение - нажмите "1", чтобы отменить смену - "2".', stColor)
            end
            imgui.Separator()
            imgui.Text(u8"Укажите максимальное количество строк в странице:")
            if imgui.SliderInt("##PrintInt", elements.int.limitPageSize, 5, 30) then
                HLcfg.config.limitPageSize = elements.int.limitPageSize.v
                save()
            end
            imgui.Text(u8"Укажите максимальное количество строк:")
            if imgui.SliderInt("##maxPages", elements.int.maxPagesBubble, 100, 1000) then
                HLcfg.config.maxPagesBubble = elements.int.maxPagesBubble.v
                save()
            end
            imgui.Separator()
        end
        if menuSelect == 8 then
            imgui.SetWindowFontScale(1.1)
            imgui.Text(u8"Создать оружие:")
            imgui.SetWindowFontScale(1.0)
            imgui.Separator()
            imgui.Text(u8'Выберите оружие:')
            imgui.PushItemWidth(142)
            if imgui.Combo("##gunCreateFov", tableOfNew.numberGunCreate, arrGuns) then
                HLcfg.config.numberGunCreate = tableOfNew.numberGunCreate.v 
                save()
            end
            imgui.PopItemWidth()
            imgui.Text(u8'Выберите количество патронов:')
            imgui.SliderInt('##numberAmmo', numberAmmo, 1, 999)
            if imgui.Button(u8'Создать', imgui.ImVec2(100, 22)) then
                sampSendChat('/givegun '..getMyId()..' '..tableOfNew.numberGunCreate.v..' '..numberAmmo.v '0')
            end
            imgui.Separator()
            imgui.SetWindowFontScale(1.1)
            imgui.Text(u8"Частоиспользуемое оружие:")
            imgui.SetWindowFontScale(1.0)
            for k,v in pairs(allGunsP) do
                if imgui.Button(u8(v), imgui.ImVec2(100, 0)) then
                    sampSendChat('/givegun '..getMyId()..' '..k..' '..numberAmmo.v)
                end imgui.SameLine()
            end
            imgui.NewLine()
            imgui.Separator()
        end
        if menuSelect == 9 then
            local tt = 0
            imgui.SetWindowFontScale(1.1)
            imgui.Text(u8"Создать транспорт:")
            imgui.SetWindowFontScale(1.0)
            imgui.Separator()
            imgui.Columns(3, _, false)
            imgui.Text(u8"Выберите транспорт:")
            imgui.PushItemWidth(142)
            if imgui.Combo("##car", tableOfNew.intComboCar, tCarsName) then
                HLcfg.config.intComboCar = tableOfNew.intComboCar.v
                save()
            end
            imgui.PopItemWidth()
            if imgui.Button(u8"Создать", imgui.ImVec2(141, 22)) then
                sampSendChat("/veh " .. tableOfNew.intComboCar.v + 400 .. " 1 1")
                AdminTools.v = false
            end
            imgui.NextColumn()
            imgui.Text(u8"Выберите цвет:")
            imgui.AlignTextToFramePadding()
            imgui.Text("#1"); imgui.SameLine();
            imgui.PushItemWidth(80)
            if imgui.InputInt("##carColor1", tableOfNew.carColor1) then
                HLcfg.config.carColor1 = tableOfNew.carColor1.v 
                save() 
            end
            imgui.PopItemWidth()
            imgui.AlignTextToFramePadding()
            imgui.Text("#2"); imgui.SameLine();
            imgui.PushItemWidth(80)
            if imgui.InputInt("##carColor2", tableOfNew.carColor2) then 
                HLcfg.config.carColor2 = tableOfNew.carColor2.v 
                save() 
            end
            imgui.PopItemWidth()
            imgui.NextColumn()
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 3.1))
            imgui.Text(u8("ID: " .. tableOfNew.intComboCar.v + 400))
            imgui.Text(u8("Транспорт: " .. tCarsName[tableOfNew.intComboCar.v + 1]))
            local carId = tableOfNew.intComboCar.v + 1
            local type = tCarsType[carId]
            imgui.Text(u8("Тип: " .. tCarsTypeName[type]))
            imgui.PopStyleVar()
            imgui.Columns(1)
            imgui.Separator()
            imgui.SetWindowFontScale(1.1)
            imgui.Text(u8"Частоиспользуемые машины:")
            imgui.SetWindowFontScale(1.0)
            imgui.Separator()
            for k, v in pairs(allCarsP) do
                tt = tt + 1
                if imgui.Button(u8(v), imgui.ImVec2(100, 0)) then
                    sampSendChat('/veh '..k..' '..tableOfNew.carColor1.v..' '..tableOfNew.carColor2.v)
                    AdminTools.v = false
                end imgui.SameLine()
                if tt == 4 then
                    imgui.NewLine()
                end
            end
            imgui.NewLine()
			imgui.BeginChild('##createCar', imgui.ImVec2(463, 300), true)
			imgui.PushItemWidth(250)
			imgui.NewInputText(u8'##SearchBar', tableOfNew.findText, 444, u8"Поиск по списку", 2)
			imgui.PopItemWidth()
			imgui.Separator()
			for k,v in pairs(tCarsName) do
				if tableOfNew.findText.v ~= '' then
					if string.rlower(v):find(string.rlower(u8:decode(tableOfNew.findText.v))) then 
						if imgui.Button(u8(v)) then
							sampSendChat('/veh '.. k + 400 - 1 ..' '..tableOfNew.carColor1.v..' '..tableOfNew.carColor2.v)
						end
					end
				end
            end
			imgui.EndChild()
			imgui.Separator()
        end
        if menuSelect == 10 then
            if not elements.checkbox.fullDSuccesfuly.v then
                imgui.Text(u8"Введите секретный ФД пароль: ") imgui.SameLine() imgui.PushItemWidth(100) if imgui.InputText("##secretPassword", elements.input.fullDPassword) then
                    HLcfg.config.fullDPassword = elements.input.fullDPassword.v
                    save()
                end
                if imgui.Button(u8"Проверить пароль") then
                    if elements.input.fullDPassword.v ~= "" then
                        if elements.input.fullDPassword.v:find("%d+") then
                            if elements.input.fullDPassword.v == "395198" then
                                elements.checkbox.fullDSuccesfuly.v = true
                                HLcfg.config.fullDSuccesfuly = elements.checkbox.fullDSuccesfuly.v
                                save()
                                printStyledString("Successful login", 1000, 4)
                            else
                                printStyledString("error", 1000, 4)
                            end
                        else
                            printStyledString("error", 1000, 4)
                        end
                    else
                        printStyledString("error", 1000, 4)
                    end 
                end
            else
                imgui.Text(u8"Доброго времени суток, "..getMyNick():gsub("_", " "))
                if imgui.CollapsingHeader(u8"Выдать команды") then
                    imgui.Text(u8"Выберите команду")
                    imgui.Combo("##inputCommandfd", fdGiveCommand, fdCommandsPlayer)
                    imgui.Text(u8"Выберите, администратор, котому вы выдаете команды, в сети, или нет")
                    imgui.Combo("##checkOnline", tableOfNew.fdOnlinePlayer, adminOnlineOffline)
                    if tableOfNew.fdOnlinePlayer.v == 0 then
                        imgui.Text(u8"Введите ИД администратора") imgui.SameLine() imgui.PushItemWidth(100) imgui.InputText("##inputIdAdministration", tableOfNew.inputAdminId)
                        if imgui.Button(u8"Выдать команду", imgui.ImVec2(150, 0)) then
                            if tableOfNew.inputAdminId.v ~= "" then
                                if tableOfNew.inputAdminId.v:find("%d+") then
                                    if sampIsPlayerConnected(tonumber(tableOfNew.inputAdminId.v)) then
                                        for k,v in ipairs(fdCommandsPlayer) do
                                            if fdGiveCommand.v == k then
                                                local nickname = sampGetPlayerNickname(tableOfNew.inputAdminId.v)
                                                sampSendChat('/setcmd '..nickname..' '..v..' 1')
                                            end
                                        end
                                    else
                                        sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Администратор не в сети.', stColor)
                                    end
                                else
                                    sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы указали некорректный [ID]', stColor)
                                end
                            else
                                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не указали [ID]', stColor)
                            end
                        end
                        if imgui.Button(u8"Забрать команду", imgui.ImVec2(150, 0)) then
                            if tableOfNew.inputAdminId.v ~= "" then
                                if tableOfNew.inputAdminId.v:find("%d+") then
                                    if sampIsPlayerConnected(tonumber(tableOfNew.inputAdminId.v)) then
                                        for k,v in ipairs(fdCommandsPlayer) do
                                            if fdGiveCommand.v == k then
                                                local nickname = sampGetPlayerNickname(tonumber(tableOfNew.inputAdminId.v))
                                                sampSendChat('/setcmd '..nickname..' '..v..' 0')
                                            end
                                        end
                                    else
                                        sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Администратор не в сети.', stColor)
                                    end
                                else
                                    sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы указали некорректный [ID]', stColor)
                                end
                            else
                                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не указали [ID]', stColor)
                            end
                        end
                    elseif tableOfNew.fdOnlinePlayer.v == 1 then
                        imgui.Text(u8"Введите никнейм администратора") imgui.SameLine() imgui.PushItemWidth(100) imgui.InputText("##InputNicknameAdministration", inputAdminNick)
                        if imgui.Button(u8"Выдать команду") then
                            if inputAdminId.v ~= "" then
                                for k,v in ipairs(fdCommandsPlayer) do
                                    if fdGiveCommand.v == k then
                                        sampSendChat('/setcmd '..inputAdminNick.v..' '..v..' 1')
                                    end
                                end
                            else
                                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не указали [ID]', stColor)
                            end
                        end
                        if imgui.Button(u8"Забрать команду") then
                            if inputAdminId.v ~= "" then
                                for k,v in ipairs(fdCommandsPlayer) do
                                    if fdGiveCommand.v == k then
                                        sampSendChat('/setcmd '..inputAdminNick.v..' '..v..' 0')
                                    end
                                end
                            else
                                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не указали [ID]', stColor)
                            end
                        end
                    end
                end
                if imgui.CollapsingHeader(u8"Выдача статистики") then
                    imgui.Combo(u8'Выберите, что выдать', tableOfNew.intChangedStatis, changedStatis)
					imgui.PushItemWidth(100) imgui.InputText(u8'Введите ИД', inputIdChangedStatis) imgui.PopItemWidth()
                    imgui.PushItemWidth(100) imgui.InputText(u8'Введите, сколько необходимо выдать', tableOfNew.inputIntChangedStatis) imgui.PopItemWidth()
                    if imgui.Button(u8'Выдать', imgui.ImVec2(100, 0)) then
						if inputIdChangedStatis.v ~= '' then
							if inputIdChangedStatis.v:find('%d+') then
								if tableOfNew.inputIntChangedStatis.v ~= '' then
									if tableOfNew.inputIntChangedStatis.v:find('%d+') then
										for i = 0, 36 do
											if tableOfNew.intChangedStatis.v == i then
												sampSendChat('/setstat '..inputIdChangedStatis.v..' '..tableOfNew.intChangedStatis.v + tonumber(1)..' '..tableOfNew.inputIntChangedStatis.v)
											end
										end
									else
										sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Укажите корректное число.', stColor)
									end
								else
									sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Укажите необходимое количество.', stColor)
								end
							else
								sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы ввели некорректный [ID].', stColor)
							end
						else
							sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Вы не указали [ID].', stColor)
						end
					end
                end
            end
        end
        imgui.EndChild()
        imgui.End()
    end


    if tableOfNew.tempLeader.v then
        imgui.SetNextWindowSize(imgui.ImVec2(250, 80), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ex / 2 - 600, ey / 2 - 50), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Выдача временного лидерства', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
                   if imgui.Button(u8'Вступить в организацию', imgui.ImVec2(235, 0)) then
            sampSendChat('/templeader ')
            AdminTools.v = false
		end
		if imgui.Button(u8'Покинуть организацию', imgui.ImVec2(235, 0)) then
			sampSendChat('/uval '..getMyId()..' adm')
            AdminTools.v = false
            end
		imgui.End()
    end
    if elements.checkbox.statistics.v then
        if not elements.putStatis.showId.v and not
        elements.putStatis.showPing.v and not
        elements.putStatis.showHealth.v and not
        elements.putStatis.showFormDay.v and not
        elements.putStatis.showFormSession.v and not
        elements.putStatis.showReportDay.v and not
        elements.putStatis.showReportSession.v and not
        elements.putStatis.showOnlineSession.v and not
        elements.putStatis.showOnlineDay.v and not
        elements.putStatis.showAfkSession.v and not
        elements.putStatis.showAfkDay.v and not
        elements.putStatis.showTime.v and not 
        elements.putStatis.showTopDate.v and not
        elements.putStatis.showInterior.v then
            allNotTrueBool = true
        else
            allNotTrueBool = false
        end
        if elements.putStatis.showTopDate.v and elements.putStatis.showTime.v then
            pageState = true
        else
            pageState = false
        end
        imgui.SetNextWindowPos(imgui.ImVec2(HLcfg.config.posX, HLcfg.config.posY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        if elements.putStatis.nameStatis.v then
		    imgui.Begin(u8'Статистика', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
        else
            imgui.Begin(u8'Статистика', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
        end
        if not allNotTrueBool then --[[Если все выключено то]]
            if elements.putStatis.showId.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'ИД: '..getMyId()) else imgui.Text(u8"ИД: "..getMyId()) end end
            if elements.putStatis.showPing.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'Пинг: '..sampGetPlayerPing(getMyId())) else imgui.Text(u8"Пинг: "..sampGetPlayerPing(getMyId())) end end
            if elements.putStatis.showHealth.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'ХП: '..sampGetPlayerHealth(getMyId())) else imgui.Text(u8'ХП: '..sampGetPlayerHealth(getMyId())) end end 
            if elements.putStatis.showInterior.v then if elements.putStatis.centerText.v then imgui.centeredText(u8(getCharActiveInterior(playerPed) == 0 and 'Вы не в интерьере' or 'Интерьер: '..getCharActiveInterior(playerPed))) else imgui.Text(u8(getCharActiveInterior(playerPed) == 0 and 'Вы не в интерьере' or 'Интерьер: '..getCharActiveInterior(playerPed))) end end
            if elements.putStatis.showOnlineSession.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'Онлайн за сеанс: '..get_clock(sessionOnline.v)) else imgui.Text(u8'Онлайн за сеанс: '..get_clock(sessionOnline.v)) end end
            if elements.putStatis.showOnlineDay.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'Онлайн за день: '..get_clock(HLcfg.onDay.online)) else imgui.Text(u8'Онлайн за день: '..get_clock(HLcfg.onDay.online)) end end
            if elements.putStatis.showAfkSession.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'АФК за сеанс: '..get_clock(sessionAfk.v)) else imgui.Text(u8'АФК за сеанс: '..get_clock(sessionAfk.v)) end end
            if elements.putStatis.showAfkDay.v then if elements.putStatis.centerText.v then imgui.centeredText(u8'АФК за день: '..get_clock(HLcfg.onDay.afk)) else imgui.Text(u8'АФК за день: '..get_clock(HLcfg.onDay.afk)) end end
            if not pageState then
                if elements.putStatis.showTime.v then if elements.putStatis.centerText.v then imgui.centeredText(u8(string.format(os.date("Время: %H:%M:%S", os.time())))) else imgui.Text(u8(string.format(os.date("Время: %H:%M:%S", os.time())))) end end
                if elements.putStatis.showTopDate.v then if elements.putStatis.centerText.v then imgui.centeredText(u8(string.format(os.date("Дата: %d.%m.%y")))) else imgui.Text(u8(string.format(os.date("Дата: %d.%m.%y")))) end end
            else
                if elements.putStatis.centerText.v then
                    imgui.centeredText(u8(os.date("%d.%m.%y | %H:%M:%S", os.time()))) else 
                        imgui.Text(u8(os.date("%d.%m.%y | %H:%M:%S", os.time()))) end
            end
        else
            imgui.Text(u8"Ни одна функция не включена.")
        end
		imgui.End()
    end
    if tableOfNew.AutoReport.v then
        if elements.checkbox.areportclick.v then
            if isKeyJustPressed(VK_U) and is_key_check_available() then
                imgui.ShowCursor = not imgui.ShowCursor
            end
        else
            imgui.ShowCursor = true
        end
        imgui.EndChild()
        imgui.Separator()
        imgui.PushItemWidth(520)
        imgui.InputText(u8'##answer_input_report', tableOfNew.answer_report)
        imgui.PopItemWidth()
        imgui.Text(u8'                                                          Введите ответ')
        imgui.Separator()
        if imgui.Button(u8'Работать по ID', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                if reports[1].textP:find('%d+') then
                    tableOfNew.AutoReport.v = false
                    imgui.ShowCursor = false
                    lua_thread.create(function()
                        local id = reports[1].textP:match('(%d+)')
                        sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, начинаю работу по вашей жалобе!')
                        wait(1000)
                        sampSendChat('/re '..id)
                        refresh_current_report()
                    end)
                else
                    sampAddChatMessage('{FF0000}[Ошибка] {ffffff}В репорте отсутствует ИД.', stColor)
                end
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Помочь автору', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    tableOfNew.AutoReport.v = false
                    imgui.ShowCursor = false
                    sampSendChat('/goto '..reports[1].id)
                    wait(1000)
                    sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, сейчас попробую вам помочь!')		
                    refresh_current_report()
                end)
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Следить', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    tableOfNew.AutoReport.v = false
                    imgui.ShowCursor = false
                    sampSendChat('/re '..reports[1].id)
                    local pID = reports[1].id
                    wait(1000)
                    sampSendChat('/pm '..pID..' Уважаемый игрок, начинаю работу по вашей жалобе!')
                    refresh_current_report()
                end)
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Переслать', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    local bool = _sampSendChat(reports[1].nickname..'['..reports[1].id..']: '..reports[1].textP, 80)
                    wait(1000)
                    sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, передал вашу жалобу администрации.')
                    refresh_current_report()
                end)
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Укажите ИД', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    sampSendChat('/pm '..reports[1].id..' Укажите ИД.')
                    refresh_current_report()
                end)
            end
        end
        imgui.Separator()
        local clr = imgui.Col
        imgui.PushStyleColor(clr.Button, imgui.ImVec4(0.86, 0.09, 0.09, 0.65))
        imgui.PushStyleColor(clr.ButtonHovered, imgui.ImVec4(0.74, 0.04, 0.04, 0.65))
        imgui.PushStyleColor(clr.ButtonActive, imgui.ImVec4(0.96, 0.15, 0.15, 0.50))
        if imgui.Button(u8'Оффтоп', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                imgui.OpenPopup(u8'Оффтоп')
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Оск.Адм', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/mute '..reports[1].id..' 30 Оскорбление администрации')
                refresh_current_report()
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Оск.Род', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/ban '..reports[1].id..' 1 Оскорбление родных')
                refresh_current_report()
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Капс', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/rmute '..reports[1].id..' 10 Капс')
                refresh_current_report()
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Обман Адм', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/rmute '..reports[1].id..' 30 Обман администрации')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'Оск Проекта', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/iban '..reports[1].id..' Оскорбление проекта')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Оск Игроков', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/rmute '..reports[1].id..' 10 Оскорбление игроков')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Мат', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/rmute '..reports[1].id..' 10 Нецензурная лексика')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Упом.Род', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/mute '..reports[1].id..' 30 Упоминание родных')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Слив', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/iban '..reports[1].id..' Слив')
                refresh_current_report()
            end
        end
        imgui.PopStyleColor(3)
        imgui.Separator()
        if imgui.Button(u8'ЖБ в СГ', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, вы можете оставить свою жалобу в нашей свободной группе ВК.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Не знаем', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Не знаем.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'РП Путём', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' РП Путём.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Выпустить', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, сейчас попробую вам помочь!')
                    wait(1000)
                    sampSendChat('/unjail '..reports[1].id)
                    refresh_current_report()
                end)
            end
        end imgui.SameLine()
        if imgui.Button(u8'Приятной игры', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Приятной игры на нашем сервере.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'Уточните', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, переформулируйте вашу жалобу так, чтобы была ясна ваша просьба/утверждение.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Ожидайте', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, убедительная просьба проявить терпение.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'У.Интернете', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Уточните в интернете.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Отказ', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, то, что вы просите - не может быть исполнено.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'РП Путём', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' РП Путём.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'Да', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Да.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'Нет', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' Нет.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/buybiz', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /buybiz.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/gps', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /gps.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/buylead', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /buylead.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'/drecorder', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /drecorder.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/su', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /su [ID].')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/showudost', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /showudost.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/fvig', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /fvig.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/invite', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /invite.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'/clear', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /clear.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/call', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /call.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/sms', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /sms [ID] [MESSAGE].')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/togphone', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /togphone.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/business', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /business.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'/drag', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /drag [ID]')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/buyadm', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /buyadm')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/h', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /h.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/divorce', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /divorce.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/gov', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /gov.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'/recorder', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /recorder.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/find', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /find.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/mm', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /mm')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/unrent', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /unrent.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/selfie', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /selfie.')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'/pgun', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /pgun.')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/sellhouse', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /sellhouse')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/sellcar', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /sellcar')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/buycar', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /buycar')
                refresh_current_report()
            end
        end imgui.SameLine()
        if imgui.Button(u8'/propose', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                sampSendChat('/pm '..reports[1].id..' /propose')
                refresh_current_report()
            end
        end
        imgui.Separator()
        if imgui.Button(u8'Ответить', imgui.ImVec2(100, 0)) then
            if tableOfNew.answer_report.v == '' then
                sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Введите корректный ответ.', stColor)
            else
                if #reports > 0 then
                    sampSendChat('/pm '..reports[1].id..' '..u8:decode(tableOfNew.answer_report.v))
                    refresh_current_report()
                    tableOfNew.answer_report.v = ''
                end
            end
        end imgui.SameLine()
        if imgui.Button(u8'СП', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                lua_thread.create(function()
                    sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, сейчас попробую вам помочь!')
                    wait(1000)
                    sampSendChat('/spawn '..reports[1].id)
                    refresh_current_report()
                end)
            end
        end imgui.SameLine()
        if imgui.Button(u8'DReports', imgui.ImVec2(100, 0)) then
            reports = {
                [0] = {
                    nickname = '',
                    id = -1,
                    textP = ''
                }
            }
        end imgui.SameLine()
        if imgui.Button(u8'Выдать ХП', imgui.ImVec2(100, 0)) then
            if #reports > 0 then
                imgui.OpenPopup(u8'Выдача жизней')
            end	
        end	 imgui.SameLine()
        if imgui.Button(u8'Пропустить', imgui.ImVec2(100, 0)) then
            refresh_current_report()
        end
        imgui.Separator()
        if imgui.BeginPopupModal(u8"Оффтоп", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            if imgui.Button(u8"Сделать предупреждение", imgui.ImVec2(175, 0)) then
                if #reports > 0 then
                    sampSendChat("/pm "..reports[1].id.." Уважаемый игрок, при последующем осуществлении оффтопа - последует бан репорта.")
                    refresh_current_report()
                    imgui.CloseCurrentPopup()
                end
            end
            if imgui.Button(u8"Наказать", imgui.ImVec2(175, 0)) then
                if #reports > 0 then
                    sampSendChat("/rmute "..reports[1].id.." 10 ОффТоп")
                    refresh_current_report()
                    imgui.CloseCurrentPopup()
                end
            end 
            if imgui.Button(u8'Закрыть', imgui.ImVec2(175, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдача жизней", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            imgui.Text(u8'Выберите, сколько выдать ХП')
            imgui.PushItemWidth(175) imgui.SliderInt('##giveHpSlider', tableOfNew.givehp, 0, 100) imgui.PopItemWidth()
            if imgui.Button(u8'Выдать жизни', imgui.ImVec2(175, 0)) then
                if #reports > 0 then
                    lua_thread.create(function()
                        sampSendChat('/pm '..reports[1].id..' Уважаемый игрок, сейчас попробую вам помочь!')
                        wait(1000)
                        sampSendChat('/sethp '..reports[1].id..' '..tableOfNew.givehp.v)
                        refresh_current_report()
                        imgui.CloseCurrentPopup()
                    end)
                end
            end
            if imgui.Button(u8'Закрыть', imgui.ImVec2(175, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        imgui.End()
    end
    if sampIsPlayerConnected(rInfo.id) and rInfo.id ~= -1 and rInfo.state then
        local x, y = ToScreen(552, 230)
        local w, h = ToScreen(638, 330)
        if imgui.IsMouseClicked(1) then
            imgui.ShowCursor = not imgui.ShowCursor
        end	
        local m, a = ToScreen(200, 410)
        imgui.SetNextWindowPos(imgui.ImVec2(m, a), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(537, 60), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"##DownPanel", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
        local bet = imgui.ImVec2(70, 0)
        if imgui.Button(u8'/spawn', bet) then
        sampSendChat('/spawn '..rInfo.id)
        end imgui.SameLine()
        if imgui.Button(u8'/getstats', bet) then
            sampSendChat('/getstats '..rInfo.id)
        end imgui.SameLine()
        if imgui.Button(u8'/getoffstats', bet) then
            sampSendChat('/getoffstats '..getNick(rInfo.id))
        end imgui.SameLine()
        if imgui.Button(u8'/slap', bet) then
            sampSendChat('/slap '..rInfo.id)
        end imgui.SameLine()
        if imgui.Button(u8'/freeze', bet) then
            sampSendChat('/freeze '..rInfo.id)
        end imgui.SameLine()
        if imgui.Button(u8'/unfreeze', bet) then
            sampSendChat('/unfreeze '..rInfo.id)
        end imgui.SameLine()
        if imgui.Button(u8'/goto', bet) then
        lua_thread.create(function()
        gotoId = rInfo.id
        sampSendChat('/re off')
        wait(1000)
        sampSendChat('/goto '..gotoId)
        end)
        end
        if imgui.Button(u8'/re off', bet) then
            lua_thread.create(function()
                sampSendChat('/re off')

            end)
        end	imgui.SameLine()
        if imgui.Button(u8'AZ', bet) then
            lua_thread.create(function()
                AzId = rInfo.id
                sampSendChat('/re off')
                wait(1000)
                sampSendChat('/az')
                wait(100)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, nil)
                sampCloseCurrentDialogWithButton(0)
                wait(1000)
                sampSendChat('/gethere '..AzId)
            end)
        end imgui.SameLine()
        if imgui.Button(u8'/gethere', bet) then
            lua_thread.create(function()
                gethereId = rInfo.id
                sampSendChat('/re off')
                wait(1000)
                sampSendChat('/gethere '..gethereId)
            end)
        end imgui.SameLine()
        if imgui.Button(u8'/sethp', bet) then
            imgui.OpenPopup(u8"Выдача жизней")
        end imgui.SameLine()
        if imgui.Button(u8'Выдать т/с', bet) then
            imgui.OpenPopup(u8"Выдать машину")
        end imgui.SameLine()
        if imgui.Button(u8'Update', bet) then
        sampSendChat('/re '..rInfo.id)
        
        end imgui.SameLine()
        if imgui.Button(u8'/uval', bet) then
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/uval '..rInfo.id..' ')
        end
        if imgui.BeginPopupModal(u8"Выдача жизней", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            imgui.Text(u8'Выберите, сколько выдать ХП')
            imgui.PushItemWidth(175) imgui.SliderInt('##giveHpSlider', tableOfNew.givehp, 0, 100) imgui.PopItemWidth()
            if imgui.Button(u8'Выдать жизни', imgui.ImVec2(175, 0)) then
                sampSendChat('/sethp '..rInfo.id..' '..tableOfNew.givehp.v)
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', imgui.ImVec2(175, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдать машину", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            imgui.Text(u8"Выберите транспорт:")
            imgui.PushItemWidth(142)
            imgui.Combo("##createiscarrecon", tableOfNew.intComboCar, tCarsName)
            imgui.PopItemWidth()
            if imgui.Button(u8"Создать", imgui.ImVec2(175, 0)) then
                sampSendChat("/veh " .. tableOfNew.intComboCar.v + 400 .. " 1 1")
                imgui.CloseCurrentPopup()
                sampSendChat('/re '..rInfo.id)
            end
            if imgui.Button(u8"Закрыть", imgui.ImVec2(175, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()

        end
        imgui.End()
        imgui.SetNextWindowPos(imgui.ImVec2(x - 1600, y - 30), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(152, 198), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"Действия", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize)

        if imgui.Button(u8'Написать игроку', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Написать игроку')
        end
        if imgui.Button(u8'Кикнуть', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Кикнуть')
        end
        if imgui.Button(u8'Выдать джайл', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Выдать джайл')
        end
        if imgui.Button(u8'Выдать варн', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Выдать варн')
        end
        if imgui.Button(u8'Выдать мут', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Выдать мут')
        end
        if imgui.Button(u8'Выдать бан', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Выдать бан')
        end	       
        if imgui.Button(u8'Выдать присон', imgui.ImVec2(135, 0)) then
            imgui.OpenPopup(u8'Выдать присон')
        end
      if imgui.BeginPopupModal(u8"Написать игроку", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            if imgui.Button(u8'Свой текст', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/pm '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Вы тут?', bsize) then
                sampSendChat('/pm '..rInfo.id..' Вы тут? Ответь в /b')
                imgui.CloseCurrentPopup()
            end
                if imgui.Button(u8'Иду на помощь', bsize) then
                sampSendChat('/pm '..rInfo.id..' Ув. Игрок! Иду на помощь!')
                imgui.CloseCurrentPopup()
                end
                if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
            end
        if imgui.BeginPopupModal(u8"Кикнуть", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(130, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/kick '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Помеха', bsize) then
                sampSendChat('/kick '..rInfo.id..' Помеха')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдать джайл", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/jail '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'ДМ', bsize) then
                sampSendChat('/jail '..rInfo.id..' 15 ДМ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'ДМ в ЗЗ', bsize) then
                sampSendChat('/jail '..rInfo.id..' 20 ДМ в ЗЗ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'ТК', bsize) then
                sampSendChat('/jail '..rInfo.id..' 15 Убийство Союзников(TK)')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'ДБ', bsize) then
                sampSendChat('/jail '..rInfo.id..' 15 ДБ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'СК', bsize) then
                sampSendChat('/jail '..rInfo.id..' 20 Убийство на спавне(SK)')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'ДБ Ковшом', bsize) then
                sampSendChat('/jail '..rInfo.id..' 20 ДБ Ковшом')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдать мут", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(150, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/mute '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'MG', bsize) then
                sampSendChat('/mute '..rInfo.id..' 10 MetaGaming')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Капс', bsize) then
                sampSendChat('/mute '..rInfo.id..' 10 CapsLock')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Флуд', bsize) then
                sampSendChat('/mute '..rInfo.id..' 10 Flood')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Оск.Игроков', bsize) then
                sampSendChat('/mute '..rInfo.id..' 30 Оскорбление игроков')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Оск. Адм', bsize) then
                sampSendChat('/mute '..rInfo.id..' 60 Оскорбление Администрации')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Розжиг', bsize) then
                sampSendChat('/mute '..rInfo.id..' 60 Розжиг межнац. розни')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Упом. родни игрока', bsize) then
                sampSendChat('/mute '..rInfo.id..' 180 Упоминание родных игрока')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Неадекват', bsize) then
                sampSendChat('/mute '..rInfo.id..' 30 Неадекватное поведение')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдать варн", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(175, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/warn '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Офф от ареста', bsize) then
                sampSendChat('/warn '..rInfo.id..' Выход при аресте')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Чит на капте', bsize) then
                sampSendChat('/warn '..rInfo.id..' Читы на капте')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Чит в организации', bsize) then
                sampSendChat('/warn '..rInfo.id..' Исп. читов')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Nonrp(коп и тд)', bsize) then
                sampSendChat('/warn '..rInfo.id..' NonRP')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        if imgui.BeginPopupModal(u8"Выдать бан", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/ban '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Вред.Читы', bsize) then
                sampSendChat('/ban '..rInfo.id..' 30 Вредительские читы')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Оск проекта', bsize) then
                sampSendChat('/ban '..rInfo.id..' 7 Оскорбление Проекта')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Багоюз', bsize) then
                sampSendChat('/iban '..rInfo.id..'7 Использование багов')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Оск род Админа', bsize) then
                sampSendChat('/ban '..rInfo.id..' 7 Оск родни Адмистратора')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Неадекватный Ник', bsize) then
                sampSendChat('/sban '..rInfo.id..' 14 Неадекватный НикНейм')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Реклама', bsize) then
                sampSendChat('/ban '..rInfo.id..' 30 Реклама Сторонних Ресурсов')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
                if imgui.BeginPopupModal(u8"Выдать присон", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(150, 0)
            if imgui.Button(u8'Своя причина', bsize) then
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/prison '..rInfo.id..' ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Fly', bsize) then
                sampSendChat('/prison '..rInfo.id..' 180 fly')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'SpeedHack', bsize) then
                sampSendChat('/prison '..rInfo.id..' 180 SpeedHack')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Срыв МП', bsize) then
                sampSendChat('/prison '..rInfo.id..' 120 Срыв МП')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Массовый ДМ', bsize) then
                sampSendChat('/prison '..rInfo.id..' 90 Массовый ДМ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Массовый СК', bsize) then
                sampSendChat('/prison '..rInfo.id..' 90 Массовый СК')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Массовый ДБ', bsize) then
                sampSendChat('/prison '..rInfo.id..' 90 Массовый ДБ')
                imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'Массовый ТК', bsize) then
                sampSendChat('/prison '..rInfo.id..' 90 Массовый ТК')
                imgui.CloseCurrentPopup()
             end
                         if imgui.Button(u8'Закрыть', bsize) then
                imgui.CloseCurrentPopup()
            end
               imgui.EndPopup()
        end
        imgui.End()
        imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(w-x, 198), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"Информация##reconInfo", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoSavedSettings)
        local isPed, pPed = sampGetCharHandleBySampPlayerId(rInfo.id)
        local score, ping = sampGetPlayerScore(rInfo.id), sampGetPlayerPing(rInfo.id)
        local health, armor, ammo, orgActive = sampGetPlayerHealth(rInfo.id), sampGetPlayerArmor(rInfo.id), getAmmoRecon(), getActiveOrganization(rInfo.id)
        if ammo == 0 then
            ammo = u8'Нет'
        else
            ammo = getAmmoRecon()
        end
        if armor == 0 then
            armor = u8'Нет'
        else
            armor = sampGetPlayerArmor(rInfo.id)
        end
        rInfo.nickname = getNick(rInfo.id)
        if isPed and doesCharExist(pPed) then
            local speed, model, interior = getCharSpeed(pPed), getCharModel(pPed), getCharActiveInterior(playerPed)
            imgui.Text(u8(getNick(rInfo.id)..'['..rInfo.id..']'))
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 2.5))
            imgui.Text(u8'Жизни: '..health)
            imgui.Text(u8'Броня: '..armor)
            imgui.Text(u8'Уровень: '..score)
            imgui.Text(u8'Пинг: '..ping)
            if isCharInAnyCar(pPed) then
                imgui.Text(u8('Скорость: В машине'))
            else
                imgui.Text(u8('Скорость: '..math.floor(speed)))
            end
            imgui.Text(u8'Скин: '..model)
            if orgActive ~= nil then
                imgui.Text(u8'Организация: '..orgActive)
            elseif orgActive == nil then
                imgui.Text(u8'Организация: Нет')
            end
            imgui.Text(u8"Интерьер: "..interior)
            imgui.Text(u8"Патроны: "..ammo)
            imgui.PopStyleVar()
            local y = y + 196
            if isCharInAnyCar(pPed) then
                local carHundle = storeCarCharIsInNoSave(pPed)
                local carSpeed = getCarSpeed(carHundle)
                local carModel = getCarModel(carHundle)
                local carHealth = getCarHealth(carHundle)
                local carEngine = isCarEngineOn(carHundle)
                if carEngine then
                    carEngine = u8'Включён'
                else
                    carEngine = u8'Выключен'
                end
                imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.0, 0.0))
                imgui.SetNextWindowSize(imgui.ImVec2(w-x, 97), imgui.Cond.FirstUseEver)
                imgui.Begin(u8"##reconCarInfo", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoSavedSettings)
                imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 2.5))
                imgui.Text(u8"Транспорт: "..tCarsName[carModel-399])
                imgui.Text(u8"Жизни: "..carHealth)
                imgui.Text(u8"Модель: "..carModel)
                imgui.Text(u8"Скорость: "..math.floor(carSpeed))
                imgui.Text(u8"Двигатель: "..carEngine)
                imgui.PopStyleVar()
                imgui.End()
            end
        else
            imgui.Text(u8"Вы следите за ботом\nПереключитесь на\nКорректный ИД игрока.")
        end
        imgui.End()
    end
end

function samp.onShowDialog(id, style, title, button1, button2, text)
    if elements.checkbox.autoCome.v then
        if elements.input.adminPassword ~= '' then
            lua_thread.create(function()
                while true do
                    wait(0)
                    if title:match("Админ авторизация") then
                        sampSendDialogResponse(sampGetCurrentDialogId(), 2934, _, elements.input.adminPassword.v)
                        sampCloseCurrentDialogWithButton(0)
                        break
                    end
                end
            end)
        else
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Авто-вход не будет произведён, по-скольку вы не указали админ-пароль.', stColor)
            elements.checkbox.autoCome.v = false
            HLcfg.config.autoCome = elements.checkbox.autoCome.v
            save()
        end
        if elements.input.loginPassword ~= '' then
            lua_thread.create(function()
                while true do
                    wait(0)
                    if title:match("Авторизация") then
                        sampSendDialogResponse(sampGetCurrentDialogId(), 2, _, elements.input.loginPassword.v)
                        sampCloseCurrentDialogWithButton(0)
                        break
                    end
                end
            end)
        else
            sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Авто-вход не будет произведён, по-скольку вы не указали пароль.', stColor)
            elements.checkbox.autoCome.v = false
            HLcfg.config.autoCome = elements.checkbox.autoCome.v
            save()
        end
	end
end

function samp.onPlayerDeathNotification(killerId, killedId, reason)
	if elements.checkbox.showKillerId.v then
		local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
		local _, myid = sampGetPlayerIdByCharHandle(playerPed)

		local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
		local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
		lua_thread.create(function()
			wait(0)
			if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
			if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
		end)
	end
end

function imgui.HelpMarker(text)
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

function getActiveOrganization(id)
	local color = sampGetPlayerColor(id)
	if color == 553648127 then
		organization = u8'Нет[0]'
	elseif color == 2854633982 then
		organization = u8'LSPD[1]'
	elseif color == 2855350577 then
		organization = u8'FBI[2]'
	elseif color == 2855512627 then
		organization = u8'Армия[3]'
	elseif color == 4289014314 then
		organization = u8'МЧС[4]'
	elseif color == 4292716289 then
		organization = u8'LCN[5]'
	elseif color == 2868838400 then
		organization = u8'Якудза[6]'
	elseif color == 4279324017 then
		organization = u8'Мэрия[7]'
	elseif color == 2854633982 then
		organization = u8'SFPD[10]'
	elseif color == 4279475180 then
		organization = u8'Инструкторы[11]'
	elseif color == 4287108071 then
		organization = u8'Баллас[12]'
	elseif color == 2866533892 then
		organization = u8'Вагос[13]'
	elseif color == 4290033079 then
		organization = u8'Мафия[14]'
	elseif color == 2852167424 then
		organization = u8'Грув[15]'
	elseif color == 2856354955 then
		organization = u8'Sa News[16]'
	elseif color == 3355573503 then
		organization = u8'Ацтеки[17]'
	elseif color == 2860761023 then
		organization = u8'Рифа[18]'
	elseif color == 2854633982 then
		organization = u8'LVPD[21]'
	elseif color == 4285563024 then
		organization = u8'Хитманы[22]'
	elseif color == 4294201344 then
		organization = u8'Стритрейсеры[23]'
	elseif color == 4281240407 then
		organization = u8'SWAT[24]'
	elseif color == 2859499664 then
		organization = u8'АП[25]'
	elseif color == 2868838400 then
		organization = u8'Казино[26]'
	elseif color == 2863280947 then
		organization = u8'ПБ Red[()]'
	elseif color == 4281576191 then
		organization = u8'ПБ Blue[()]'
	elseif color == 8025703 then
		organization = u8'В маске[()]'
	end
	return organization
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr()
	memory.setfloat(pStSet + 39, 1488.0)
	memory.setint8(pStSet + 47, 0)
	memory.setint8(pStSet + 56, 1)
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr()
	memory.setfloat(pStSet + 39, 50.0)
	memory.setint8(pStSet + 47, 0)
	memory.setint8(pStSet + 56, 1)
end

function save()
    inicfg.save(HLcfg, "LuxwenTools.ini")
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..' ' or '')..'%H:%M:%S', time + timezone_offset)
end

function samp.onShowMenu()
	if rInfo.id ~= -1 then
		return false
	end
end
function samp.onHideMenu()
	if rInfo.id ~= -1 then
		return false
	end
end

function getAmmoRecon()
	local result, recon_handle = sampGetCharHandleBySampPlayerId(rInfo.id)
	if result then
		local weapon = getCurrentCharWeapon(recon_handle)
		local struct = getCharPointer(recon_handle) + 0x5A0 + getWeapontypeSlot(weapon) * 0x1C
		return getStructElement(struct, 0x8, 4)
	end
end

function samp.onTogglePlayerSpectating(state)
	rInfo.state = state
	if not state then
		rInfo.id = -1
    end
end

function isSpawnerFor(number)
    local lasttime = os.time()
    local lasttimes = 0
    local time_out = number
    lua_thread.create(function()
        while lasttimes < time_out do
            local lasttimes = os.time() - lasttime
            wait(0)
            printStyledString("Cars will be spawned in >> "..time_out - lasttimes, 1000, 4)
            if lasttimes == time_out then
                break
            end
        end
    end)
end 

function refresh_current_report()
	table.remove(reports, 1)
end

function samp.onShowTextDraw(id, data)
	if rInfo.id ~= -1 then
		lua_thread.create(function()
			while true do 
				wait(0)
				if data.text:find('.*') then
					sampTextdrawDelete(id)
				end
			end
		end)
	end
end

function samp.onSendCommand(cmd)
    rID = cmd:match('/re%s+(%d+)')
    rGoto = cmd:match('/goto%s+(%d+)')
	if rID then
		if rID:len() > -1 and rID:len() < 4 then
            rInfo.id = tonumber(rID)
		else
			sampAddChatMessage('{FF0000}[Ошибка] {ffffff}Укажите корректный ИД.', stColor)
		end
    end
    if rGoto or rID then 
        enAirBrake = false
    end
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

ChatBox = function(pagesize, blacklist)
    local obj = {
      pagesize = elements.int.limitPageSize.v,
          active = false,
          font = nil,
          messages = {},
          blacklist = blacklist,
          firstMessage = 0,
          currentMessage = 0,
    }
  
      function obj:initialize()
          if self.font == nil then
              self.font = renderCreateFont('Verdana', 8, FCR_BORDER + FCR_BOLD)
          end
      end
  
      function obj:free()
          if self.font ~= nil then
              renderReleaseFont(self.font)
              self.font = nil
          end
      end
  
      function obj:toggle(show)
          self:initialize()
          self.active = show
      end
  
    function obj:draw(x, y)
          local add_text_draw = function(text, color)
              renderFontDrawText(self.font, text, x, y, color)
              y = y + renderGetFontDrawHeight(self.font)
          end
  
          -- draw caption
      add_text_draw("Admin Chat", 0xFFE4D8CC)
  
          -- draw page indicator
          if #self.messages == 0 then return end
          local cur = self.currentMessage
          local to = cur + math.min(self.pagesize, #self.messages) - 1
          add_text_draw(string.format("%d/%d", to, #self.messages), 0xFFE4D8CC)
  
          -- draw messages
          x = x + 4
          for i = cur, to do
              local it = self.messages[i]
              add_text_draw(
                  string.format("{E4E4E4}[%s] (%.1fm) {%06X}%s{D4D4D4}({EEEEEE}%d{D4D4D4}): {%06X}%s",
                      it.time,
                      it.dist,
                      argb_to_rgb(it.playerColor),
                      it.nickname,
                      it.playerId,
                      argb_to_rgb(it.color),
                      it.text),
                  it.color)
          end
    end
  
      function obj:add_message(playerId, color, distance, text)
          -- ignore blacklisted messages
          if self:is_text_blacklisted(text) then return end
  
          -- process only streamed in players
          local dist = get_distance_to_player(playerId)
          if dist ~= nil then
              color = bgra_to_argb(color)
              if dist > distance then color = set_argb_alpha(color, 0xA0)
              else color = set_argb_alpha(color, 0xF0)
              end
              table.insert(self.messages, {
                  playerId = playerId,
                  nickname = sampGetPlayerNickname(playerId),
                  color = color,
                  playerColor = sampGetPlayerColor(playerId),
                  dist = dist,
                  distLimit = distance,
                  text = text,
                  time = os.date('%X')})
  
              -- limit message list
              if #self.messages > elements.int.maxPagesBubble.v then
                  self.messages[self.firstMessage] = nil
                  self.firstMessage = #self.messages - elements.int.maxPagesBubble.v
              else
                  self.firstMessage = 1
              end
              self:scroll(1)
          end
      end
  
      function obj:is_text_blacklisted(text)
          for _, t in pairs(self.blacklist) do
              if string.match(text, t) then
                  return true
              end
          end
          return false
      end
  
      function obj:scroll(n)
          self.currentMessage = self.currentMessage + n
          if self.currentMessage < self.firstMessage then
              self.currentMessage = self.firstMessage
          else
              local max = math.max(#self.messages, self.pagesize) + 1 - self.pagesize
              if self.currentMessage > max then
                  self.currentMessage = max
              end
          end
      end
  
    setmetatable(obj, {})
    return obj
end

function take_vehicle_back(vehicleId)
	sampSendExitVehicle(vehicleId)
	wait(0)
	sampForceOnfootSync()
	wait(0)
	sampSendEnterVehicle(vehicleId, false)
	wait(15)
	sampForceVehicleSync(vehicleId)
end

function samp.onVehicleSync(playerId, vehicleId, data)
    if elements.checkbox.antiEjectCar.v and is_player_stealing_my_vehicle(playerId, vehicleId) then
		if not warningMsgTick or gameClock() - warningMsgTick > 3 then
			warningMsgTick = gameClock()
		end
		lua_thread.create(take_vehicle_back, vehicleId)
		return false
    end
    infoCar.pcar.idLastCar = vehicleId
end

function samp.onPlayerEnterVehicle(playerId, vehicleId, passenger)
    if elements.checkbox.antiEjectCar.v and is_player_stealing_my_vehicle(playerId, vehicleId) then
		return false
    end
end

function is_player_stealing_my_vehicle(playerId, vehicleId)
	if isCharInAnyCar(playerPed) and sampIsPlayerConnected(playerId) then
		local _, myVehId = sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(playerPed))
		return myVehId == vehicleId
	end
	return false
end
  
function get_distance_to_player(playerId)
      if sampIsPlayerConnected(playerId) then
          local result, ped = sampGetCharHandleBySampPlayerId(playerId)
          if result and doesCharExist(ped) then
              local myX, myY, myZ = getCharCoordinates(playerPed)
              local playerX, playerY, playerZ = getCharCoordinates(ped)
              return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
          end
      end
      return nil
end

function cleanStreamMemory()
	local huy = callFunction(0x53C500, 2, 2, true, true)
	local huy1 = callFunction(0x53C810, 1, 1, true)
	local huy2 = callFunction(0x40CF80, 0, 0)
	local huy3 = callFunction(0x4090A0, 0, 0)
	local huy4 = callFunction(0x5A18B0, 0, 0)
	local huy5 = callFunction(0x707770, 0, 0)
	
	local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
	requestCollision(pX, pY)
	loadScene(pX, pY, pZ)
end
  
function is_key_check_available()
    if not isSampfuncsLoaded() then
      return not isPauseMenuActive()
    end
    local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
    if isSampLoaded() and isSampAvailable() then
      result = result and not sampIsChatInputActive() and not sampIsDialogActive()
    end
    return result
end
  
function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end
  
function bgra_to_argb(bgra)
    local b, g, r, a = explode_argb(bgra)
    return join_argb(a, r, g, b)
end
  
function set_argb_alpha(color, alpha)
        local _, r, g, b = explode_argb(color)
          return join_argb(alpha, r, g, b)
end
  
function get_argb_alpha(color)
      local alpha = explode_argb(color)
      return alpha
end
  
function argb_to_rgb(argb)
      return bit.band(argb, 0xFFFFFF)
end

function onScriptTerminate(script)
    if script == thisScript() then
      if doesFileExist(directory) then
        os.remove(directory)
      end
      local f = io.open(directory, "w")
      if f then
        f:write(encodeJson(playersList))
        f:close()
      end
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'w+')
        if f then
          f:write(encodeJson(defTable)):close()
        end
      end
    end
end

function samp.onPlayerChatBubble(playerId, color, distance, duration, message)
	if sampIsPlayerConnected(playerId) and bubbleBox then
		bubbleBox:add_message(playerId, color, distance, message)
	end
end

function luasave()
    luacfg.save(filename_settings, cfg)
end 

function click_warp()
    lua_thread.create(function()
        while true do
        if cursorEnabled and not AdminTools.v and not changePosition and rInfo.id == -1 and not tableOfNew.AutoReport.v then
          local mode = sampGetCursorMode()
          if mode == 0 then
            showCursor(true)
          end
          local sx, sy = getCursorPos()
          local sw, sh = getScreenResolution()
          if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
            local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
            local camX, camY, camZ = getActiveCameraCoordinates()
            local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ,
            true, true, false, true, false, false, false)
            if result and colpoint.entity ~= 0 then
              local normal = colpoint.normal
              local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
              local zOffset = 300
              if normal[3] >= 0.5 then zOffset = 1 end
              local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                true, true, false, true, false, false, false)
              if result then
                pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

                local curX, curY, curZ  = getCharCoordinates(playerPed)
                local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                local hoffs             = renderGetFontDrawHeight(font)

                sy = sy - 2
                sx = sx - 2
                renderFontDrawText(font, string.format("{FFFFFF}%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)

                local tpIntoCar = nil
                if colpoint.entityType == 2 then
                  local car = getVehiclePointerHandle(colpoint.entity)
                  if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                    displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                    local color = 0xFFFFFFFF
                    if isKeyDown(VK_RBUTTON) then
                      tpIntoCar = car
                      color = 0xFFFFFFFF
                    end
                    renderFontDrawText(font, "{FFFFFF}Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                  end
                end

                createPointMarker(pos.x, pos.y, pos.z)

                if isKeyDown(VK_LBUTTON) then
                  if tpIntoCar then
                    if not jumpIntoCar(tpIntoCar) then
                      teleportPlayer(pos.x, pos.y, pos.z)
                      local veh = storeCarCharIsInNoSave(playerPed)
                      local cordsVeh = {getCarCoordinates(veh)}
                      setCarCoordinates(veh, cordsVeh[1], cordsVeh[2], cordsVeh[3])
                    end
                  else
                    if isCharInAnyCar(playerPed) then
                      local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                      local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                      rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                      pos = pos - norm * 1.8
                      pos.z = pos.z - 1.1
                    end
                    teleportPlayer(pos.x, pos.y, pos.z)
                  end
                  removePointMarker()

                  while isKeyDown(VK_LBUTTON) do wait(0) end
                  showCursor(false)
                end
              end
            end
          end
        end
        wait(0)
        removePointMarker()
        end
    end)
end

function imgui.ToggleButton(str_id, bool)
    local rBool = false

	if LastActiveTime == nil then
		LastActiveTime = {}
	end
	if LastActive == nil then
		LastActive = {}
	end

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
	
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing()
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool.v = not bool.v
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	local t = bool.v and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= ANIM_SPEED then
			local t_anim = ImSaturate(time / ANIM_SPEED)
			t = bool.v and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg
	if bool.v then
		col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
		col_bg = imgui.ImColor(100, 100, 100, 180):GetU32()
	end

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImColor(150, 150, 150, 255):GetVec4()))

	return rBool
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function time()
	startTime = os.time()
    while true do
        wait(1000)
        if sampGetGamestate() == 3 then 								
	        nowTime = os.date("%H:%M:%S", os.time()) 			

	        sessionOnline.v = sessionOnline.v + 1 							
	        sessionFull.v = os.time() - startTime 					
	        sessionAfk.v = sessionFull.v - sessionOnline.v						

	        HLcfg.onDay.online = HLcfg.onDay.online + 1 				
	        HLcfg.onDay.full = dayFull.v + sessionFull.v 						
			HLcfg.onDay.afk = HLcfg.onDay.full - HLcfg.onDay.online
			
	    else
	    	startTime = startTime + 1
	    end
    end
end

function autoSave()
	while true do 
		wait(60000)
		save()
	end
end

function fixChatCoursor()
    lua_thread.create(function()
        sampSetChatInputEnabled(true)
        wait(100)
        sampSetChatInputEnabled(false)
    end)
end

function dialogHiderText()
    lua_thread.create(function()
    local result, button, list, input = sampHasDialogRespond(3910)
	if result then
		if list == 0 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, бегать не по назначению, стрелять без команды.')
			wait(1000)
			sampSendChat('/s Я вызываю 2-ух игроков, они становятся спиной к спине на любой дистанции...')
			wait(1000)
			sampSendChat('/s И на счет 1-2-3 начинают ПВП.')
		elseif list == 1 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, бегать не по назначению, убегать.')
			wait(1000)
			sampSendChat('/s Через /try мы найдем победителя.')
		elseif list == 2 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, менять машину.')
			wait(1000)
			sampSendChat('/s Последний оставшийся вне взорванной машине - победил.')
		elseif list == 3 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, стрелять по игрокам.')
			wait(1000)
			sampSendChat('/s Кто первый пройдет паркур - победил.')
		elseif list == 4 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, стрелять по игрокам.')
			wait(1000)
			sampSendChat('/s Кто первый останется на поверхности - победил.')
		elseif list == 5 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, стрелять по игрокам.')
			wait(1000)
			sampSendChat('/s Кто последний останется в живых - победил.')
		elseif list == 6 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие, стрелять по игрокам.')
			wait(1000)
			sampSendChat('/s Кто лучше всех спрячется - победил.')
		elseif list == 7 and button == 1 then
			sampSendChat('/s Внимание, озвучиваю правила!')
			wait(1000)
			sampSendChat('/s Запрещено: Срывать мероприятие.')
			wait(1000)
			sampSendChat('/s Вы должны будете убить друг друга. Кто последний останется в живых - победил.')
		end
    end
    end)
end

function samp.onSendPlayerSync(data)
    if ainvisible then data.surfingVehicleId = 2001 end
end

function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
      rotAxis:crossProduct(vec)
      rotAxis:normalize()
      rotAxis:zeroNearZero()
      mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
end
  
function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end
  
function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function samp.onPlayerQuit(id, reason)
	if elements.checkbox.leaveChecker.v then
		sampAddChatMessage(string.format("{0093E3}[Luxwen Tools] {ffffff}%s[%d] отключился. Причина: {FF0000}%s", getNick(id), id, quitReason[reason+1]), stColor)
    end
end
  
function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        local rx, ry, rz, fx, fy, fz, ux, uy, uz
        rx = readFloatArray(mat, 0)
        ry = readFloatArray(mat, 1)
        rz = readFloatArray(mat, 2)
  
        fx = readFloatArray(mat, 4)
        fy = readFloatArray(mat, 5)
        fz = readFloatArray(mat, 6)
  
        ux = readFloatArray(mat, 8)
        uy = readFloatArray(mat, 9)
        uz = readFloatArray(mat, 10)
        return rx, ry, rz, fx, fy, fz, ux, uy, uz
      end
    end
end

function getNick(id)
    local nick = sampGetPlayerNickname(id)
    return nick
end

function getMyNick()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end

function getMyId()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        return id
    end
end
  
function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        writeFloatArray(mat, 0, rx)
        writeFloatArray(mat, 1, ry)
        writeFloatArray(mat, 2, rz)
  
        writeFloatArray(mat, 4, fx)
        writeFloatArray(mat, 5, fy)
        writeFloatArray(mat, 6, fz)
  
        writeFloatArray(mat, 8, ux)
        writeFloatArray(mat, 9, uy)
        writeFloatArray(mat, 10, uz)
      end
    end
end
  
function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.33, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 255, 255, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
end
  
function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end
  
function removePointMarker()
    if pointMarker then
      removeUser3dMarker(pointMarker)
      pointMarker = nil
    end
end

function samp.onSendBulletSync(data)
    if elements.checkbox.showMyBullets.v and elements.checkbox.bulletTracer.v then
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSyncMy.lastId = bulletSyncMy.lastId + 1
                    if bulletSyncMy.lastId < 1 or bulletSyncMy.lastId > bulletSyncMy.maxLines then
                        bulletSyncMy.lastId = 1
                    end
                    bulletSyncMy[bulletSyncMy.lastId].my.time = os.time() + elements.int.secondToCloseTwo.v
                    bulletSyncMy[bulletSyncMy.lastId].my.o.x, bulletSyncMy[bulletSyncMy.lastId].my.o.y, bulletSyncMy[bulletSyncMy.lastId].my.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSyncMy[bulletSyncMy.lastId].my.t.x, bulletSyncMy[bulletSyncMy.lastId].my.t.y, bulletSyncMy[bulletSyncMy.lastId].my.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, staticObjectMy.v[1]*255, staticObjectMy.v[2]*255, staticObjectMy.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, pedPMy.v[1]*255, pedPMy.v[2]*255, pedPMy.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, carPMy.v[1]*255, carPMy.v[2]*255, carPMy.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, dinamicObjectMy.v[1]*255, dinamicObjectMy.v[2]*255, dinamicObjectMy.v[3]*255)
                    end
                end
            end 
        end
    end
end 

function samp.onBulletSync(playerid, data)
    if elements.checkbox.bulletTracer.v then
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSync.lastId = bulletSync.lastId + 1
                    if bulletSync.lastId < 1 or bulletSync.lastId > bulletSync.maxLines then
                        bulletSync.lastId = 1
                    end
                    bulletSync[bulletSync.lastId].other.time = os.time() + elements.int.secondToClose.v
                    bulletSync[bulletSync.lastId].other.o.x, bulletSync[bulletSync.lastId].other.o.y, bulletSync[bulletSync.lastId].other.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSync[bulletSync.lastId].other.t.x, bulletSync[bulletSync.lastId].other.t.y, bulletSync[bulletSync.lastId].other.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, staticObject.v[1]*255, staticObject.v[2]*255, staticObject.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, pedP.v[1]*255, pedP.v[2]*255, pedP.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, carP.v[1]*255, carP.v[2]*255, carP.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, dinamicObject.v[1]*255, dinamicObject.v[2]*255, dinamicObject.v[3]*255)
                    end
                end
            end
        end
    end
end
function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
      local maxPassengers = getMaximumNumberOfPassengers(car)
      for i = 0, maxPassengers do
        if isCarPassengerSeatFree(car, i) then
          return i + 1
        end
      end
      return nil -- no free seats
    else
      return 0 -- driver seat
    end
end
  
function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end                         -- no free seats
    if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
    end
    restoreCameraJumpcut()
    return true
end

function fps_correction()
	return representIntAsFloat(readMemory(0xB7CB5C, 4, false))
end
  
function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
      setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function isKeysDown(keycombo_or_keyId)
    keycombo_or_keyId = table.concat(keycombo_or_keyId, ", ")
    for w in string.gmatch(keycombo_or_keyId, "%d+") do
      if isKeyDown(w) then
        return true
      end
    end
end
  
function savesettings()
    if doesFileExist(fpath) then
      local f = io.open(fpath, 'w+')
      if f then
        f:write(encodeJson(defTable)):close()
      end
    end
end
  
function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
      local ptr = getCharPointer(char)
      setEntityCoordinates(ptr, x, y, z)
    end
end
  
function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
      local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
      if matrixPtr ~= 0 then
        local posPtr = matrixPtr + 0x30
        writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
        writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
        writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
      end
    end
end
  
function showCursor(toggle)
    if toggle then
      sampSetCursorMode(CMODE_LOCKCAM)
    else
      sampToggleCursor(false)
    end
    cursorEnabled = toggle
end


function salat()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.42, 0.48, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.77, 0.88, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.82, 0.98, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.85, 0.98, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.85, 0.98, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.63, 0.75, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.63, 0.75, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.85, 0.98, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.85, 0.98, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.85, 0.98, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blackred()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end

function violet()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.Alpha = 1.00

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 9.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.442, 0.115, 0.718, 0.540)
    colors[clr.FrameBgHovered]         = ImVec4(0.389, 0.190, 0.718, 0.400)
    colors[clr.FrameBgActive]          = ImVec4(0.441, 0.125, 0.840, 0.670)
    colors[clr.TitleBg]                = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.TitleBgActive]          = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.CheckMark]              = ImVec4(0.643, 0.190, 0.862, 1.000)
    colors[clr.SliderGrab]             = ImVec4(0.434, 0.100, 0.757, 1.000)
    colors[clr.SliderGrabActive]       = ImVec4(0.434, 0.100, 0.757, 1.000)
    colors[clr.Button]                 = ImVec4(0.423, 0.142, 0.829, 1.000)
    colors[clr.ButtonHovered]          = ImVec4(0.508, 0.000, 1.000, 1.000)
    colors[clr.ButtonActive]           = ImVec4(0.508, 0.000, 1.000, 1.000)
    colors[clr.Header]                 = ImVec4(0.628, 0.098, 0.884, 0.310)
    colors[clr.HeaderHovered]          = ImVec4(0.695, 0.000, 0.983, 0.800)
    colors[clr.HeaderActive]           = ImVec4(0.695, 0.000, 0.983, 0.800)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.ResizeGripHovered]      = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.ResizeGripActive]       = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blue()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.Alpha = 1.00

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 9.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function brown()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4

   style.WindowRounding = 2.0
   style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
   style.ChildWindowRounding = 2.0
   style.FrameRounding = 2.0
   style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
   style.ScrollbarSize = 9.0
   style.ScrollbarRounding = 0
   style.GrabMinSize = 8.0
   style.GrabRounding = 1.0

   colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
   colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
   colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
   colors[clr.TitleBg]                = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
   colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
   colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
   colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
   colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
   colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.Separator]              = colors[clr.Border]
   colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
   colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
   colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
   colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
   colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
   colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
   colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
   colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
   colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
   colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
   colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
   colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.ComboBg]                = colors[clr.PopupBg]
   colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
   colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
   colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
   colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
   colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
   colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
   colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
   colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
   colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
   colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function red()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 9.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
