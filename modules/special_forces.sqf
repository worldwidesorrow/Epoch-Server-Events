/*
	Original Military "Special Forces" Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Updated for DayZ Epoch 1.0.7+ by JasonTM
	Last update: 06-01-2021
*/

local _spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
local _sniperChance = .25; // Chance that an as50, KSVK, m107, or Anzio 20 will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
local _radius = 350; // Radius the loot can spawn and used for the marker
local _timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _debug = false; // Diagnostic logs used for troubleshooting.
local _nameMarker = false; // Center marker with the name of the mission.
local _markPos = false; // Puts a marker exactly were the loot spawns.
local _lootAmount = 10; // This is the number of times a random loot selection is made.
local _type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
local _visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
local _distance = 20; // Distance from crate before crate is considered "visited"
local _crate = "USVehicleBox";
local _weapons = ["M16A2_DZ","M4A1_DZ","M4A1_SD_DZ","SA58_RIS_DZ","L85A2_DZ","L85A2_SD_DZ","AKM_DZ","G36C_DZ","G36C_SD_DZ","G36A_Camo_DZ","G36K_Camo_DZ","G36K_Camo_SD_DZ","CTAR21_DZ","ACR_WDL_DZ","ACR_WDL_SD_DZ","ACR_BL_DZ","ACR_BL_SD_DZ","ACR_DES_DZ","ACR_DES_SD_DZ","ACR_SNOW_DZ","ACR_SNOW_SD_DZ","AK74_DZ","AK74_SD_DZ","AK107_DZ","CZ805_A1_DZ","CZ805_A1_GL_DZ","CZ805_A2_DZ","CZ805_A2_SD_DZ","CZ805_B_GL_DZ","Famas_DZ","Famas_SD_DZ","G3_DZ","HK53A3_DZ","HK416_DZ","HK416_SD_DZ","HK417_DZ","HK417_SD_DZ","HK417C_DZ","M1A_SC16_BL_DZ","M1A_SC16_TAN_DZ","M1A_SC2_BL_DZ","Masada_DZ","Masada_SD_DZ","Masada_BL_DZ","Masada_BL_SD_DZ","MK14_DZ","MK14_SD_DZ","MK16_DZ","MK16_CCO_SD_DZ","MK16_BL_CCO_DZ","MK16_BL_Holo_SD_DZ","MK17_DZ","MK17_CCO_SD_DZ","MK17_ACOG_SD_DZ","MK17_BL_Holo_DZ","MK17_BL_GL_ACOG_DZ","MR43_DZ","PDR_DZ","RK95_DZ","RK95_SD_DZ","SCAR_H_AK_DZ","SteyrAug_A3_Green_DZ","SteyrAug_A3_Black_DZ","SteyrAug_A3_Blue_DZ","XM8_DZ","XM8_DES_DZ","XM8_GREY_DZ","XM8_GREY_2_DZ","XM8_GL_DZ","XM8_DES_GL_DZ","XM8_GREY_GL_DZ","XM8_Compact_DZ","XM8_DES_Compact_DZ","XM8_GREY_Compact_DZ","XM8_GREY_2_Compact_DZ","XM8_SD_DZ"];
local _snipers = ["Anzio_20_DZ","BAF_AS50_scoped_DZ","m107_DZ","KSVK_DZE"];
#define TITLE_COLOR "#FF0000" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

if (random 1 > _spawnChance and !_debug) exitWith {};

local _pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["Special Forces Event spawning at %1", _pos];

local _lootPos = [_pos,0,(_radius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["Special Forces Event: creating ammo box at %1", _lootPos];};


local _box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

if (random 1 < _sniperChance) then {
	local _wep = _snipers call BIS_fnc_selectRandom;
	_box addWeaponCargoGlobal [_wep,1];
	
	local _ammoArray = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
	if (count _ammoArray > 0) then {
		local _mag = _ammoArray select 0;
		_box addMagazineCargoGlobal [_mag, (3 + round(random 2))];
	};
};

for "_i" from 1 to _lootAmount do {

	local _wep = _weapons call BIS_fnc_selectRandom;
	_box addWeaponCargoGlobal [_wep,1];
	
	local _ammoArray = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
	if (count _ammoArray > 0) then {
		local _mag = _ammoArray select 0;
		_box addMagazineCargoGlobal [_mag, (3 + floor(random 3))];
	};
	
	local _cfg = configFile >> "CfgWeapons" >> _wep >> "Attachments";
	if (isClass _cfg && count _cfg > 0) then {
		local _attach = configName (_cfg call BIS_fnc_selectRandom);
		if !(_attach == "Attachment_Tws") then { // no thermal optics in regular game
			_box addMagazineCargoGlobal [_attach,1];
		};
	};
};

local _pack = ["Patrol_Pack_DZE1","Assault_Pack_DZE1","Czech_Vest_Pouch_DZE1","TerminalPack_DZE1","TinyPack_DZE1","ALICE_Pack_DZE1","TK_Assault_Pack_DZE1","CompactPack_DZE1","British_ACU_DZE1","GunBag_DZE1","NightPack_DZE1","SurvivorPack_DZE1","AirwavesPack_DZE1","CzechBackpack_DZE1","WandererBackpack_DZE1","LegendBackpack_DZE1","CoyoteBackpack_DZE1","LargeGunBag_DZE1"] call BIS_fnc_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_type == "Hint") then {
	local _img = getText (configFile >> "CfgWeapons" >> "UK59_DZ" >> "picture");
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_MILITARY_TITLE","STR_CL_ESE_MILITARY"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_MILITARY"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Special Forces Event setup, waiting for %1 minutes", _timeout];};

local _time = diag_tickTime;
local _done = false;
local _visited = false;
local _isNear = true;
local _marker = "";
local _dot = "";
local _pMarker = "";
local _vMarker = "";

while {!_done} do {
	_marker = createMarker [ format ["eventMarker%1", _time], _pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [(_radius + 50), (_radius + 50)];
	
	if (_nameMarker) then {
		_dot = createMarker [format["eventDot%1",_time],_pos];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "Special Forces Supply";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [ format ["eventPos%1", _time], _lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorRed";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _box <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		if (_visited) then {
			_vMarker = createMarker [ format ["eventVisit%1", _time], [(_pos select 0), (_pos select 1) + 25]];
			_vMarker setMarkerShape "ICON";
			_vMarker setMarkerType "hd_pickup";
			_vMarker setMarkerColor "ColorBlack";
		}; 
	};
	
	uiSleep 1;
	
	deleteMarker _marker;
	if !(isNil "_dot") then {deleteMarker _dot;};
	if !(isNil "_pMarker") then {deleteMarker _pMarker;};
	if !(isNil "_vMarker") then {deleteMarker _vMarker;}; 
	
	if (_timeout != -1) then {
		if (diag_tickTime - _time >= _timeout*60) then {
			_done = true;
		};
	};
};

while {_isNear} do {
	{if (isPlayer _x && _x distance _box >= _distance) then {_isNear = false};} count playableUnits;
};

deleteVehicle _box;

diag_log "Special Forces Event Ended";
