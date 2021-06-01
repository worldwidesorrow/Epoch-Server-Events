/*
	Original Treasure Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Updated for DayZ Epoch 1.0.7+ by JasonTM
	Last update: 06-01-2021
*/

local _spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
local _gemChance = .25; // Chance that a gem will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
local _radius = 350; // Radius the loot can spawn and used for the marker
local _timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _debug = false; // Diagnostic logs used for troubleshooting.
local _nameMarker = false; // Center marker with the name of the mission.
local _markPos = false; // Puts a marker exactly were the loot spawns.
local _lootAmount = 4; // This is the number of times a random loot selection is made.
local _weapons = 3; // The number of gold and silver guns to include in the crate.
local _type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
local _visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
local _distance = 20; // Distance from crate before crate is considered "visited"
local _crate = "GuerillaCacheBox";
#define TITLE_COLOR "#FFFF66" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

local _lootList = [[5,"ItemGoldBar"],[3,"ItemGoldBar10oz"],"ItemBriefcase100oz",[20,"ItemSilverBar"],[10,"ItemSilverBar10oz"]];
local _weaponList = ["AKS_Gold_DZ","AKS_Silver_DZ","SVD_Gold_DZ","Revolver_Gold_DZ","Colt_Anaconda_Gold_DZ","DesertEagle_Gold_DZ","DesertEagle_Silver_DZ"];

if (random 1 > _spawnChance and !_debug) exitWith {};

local _pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["Pirate Treasure Event Spawning At %1", _pos];

local _lootPos = [_pos,0,(_radius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["Pirate Treasure Event: creating ammo box at %1", _lootPos];};

local _box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

local _cutGrass = createVehicle ["ClutterCutter_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
_cutGrass setPos _lootPos;

if (random 1 < _gemChance) then {
	local _gem = ["ItemTopaz","ItemObsidian","ItemSapphire","ItemAmethyst","ItemEmerald","ItemCitrine","ItemRuby"] call BIS_fnc_selectRandom;
	_box addMagazineCargoGlobal [_gem,1];
};

for "_i" from 1 to _lootAmount do {
	local _loot = _lootList call BIS_fnc_selectRandom;
	
	if ((typeName _loot) == "ARRAY") then {
		_box addMagazineCargoGlobal [_loot select 1,_loot select 0];
	} else {
		_box addMagazineCargoGlobal [_loot,1];
	};
};

for "_i" from 1 to _weapons do {
	local _wep = _weaponList call BIS_fnc_selectRandom;
	_box addWeaponCargoGlobal [_wep,1];
	
	local _ammoArray = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
	if (count _ammoArray > 0) then {
		local _mag = _ammoArray select 0;
		_box addMagazineCargoGlobal [_mag, (3 + floor(random 3))];
	};
};

local _pack = ["Patrol_Pack_DZE1","Assault_Pack_DZE1","Czech_Vest_Pouch_DZE1","TerminalPack_DZE1","TinyPack_DZE1","ALICE_Pack_DZE1","TK_Assault_Pack_DZE1","CompactPack_DZE1","British_ACU_DZE1","GunBag_DZE1","NightPack_DZE1","SurvivorPack_DZE1","AirwavesPack_DZE1","CzechBackpack_DZE1","WandererBackpack_DZE1","LegendBackpack_DZE1","CoyoteBackpack_DZE1","LargeGunBag_DZE1"] call BIS_fnc_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_type == "Hint") then {
	local _img = (getText (configFile >> "CfgMagazines" >> "ItemRuby" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_TREASURE_TITLE","STR_CL_ESE_TREASURE"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_TREASURE"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Pirate Treasure event setup, waiting for %1 minutes", _timeout];};

local _time = diag_tickTime;
local _done = false;
local _visited = false;
local _isNear = true;
local _marker = "";
local _dot = "";
local _pMarker = "";
local _vMarker = "";

while {!_done} do {
	
	_marker = createMarker [ format ["loot_marker_%1", _time], _pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorYellow";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [(_radius + 50), (_radius + 50)];
	
	if (_nameMarker) then {
		_dot = createMarker [format["loot_text_marker_%1",_time],_pos];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "Pirate Treasure";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [ format ["loot_event_pMarker_%1", _time], _lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorYellow";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _box <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		if (_visited) then {
			_vMarker = createMarker [ format ["loot_event_vMarker_%1", _time], [(_pos select 0), (_pos select 1) + 25]];
			_vMarker setMarkerShape "ICON";
			_vMarker setMarkerType "hd_pickup";
			_vMarker setMarkerColor "ColorBlack";
		}; 
	};
	
	uiSleep 3;
	
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

// Clean up
deleteVehicle _box;
deleteVehicle _cutGrass;

diag_log "Pirate Treasure Event Ended";
