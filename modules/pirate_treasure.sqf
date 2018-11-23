/*
	Original Treasure Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 11-15-2018
*/

private ["_spawnChance","_gemChance","_radius","_timeout","_debug","_nameMarker","_markPos",
"_lootAmount","_type","_visitMark","_distance","_crate","_lootList",
"_pos","_lootPos","_cutGrass","_gem","_loot","_wep","_pack","_img","_time",
"_marker","_pMarker","_vMarker","_dot","_done","_visited","_isNear"];

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_gemChance = .25; // Chance that a gem will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_radius = 350; // Radius the loot can spawn and used for the marker
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_debug = false; // Diagnostic logs used for troubleshooting.
_nameMarker = false; // Center marker with the name of the mission.
_markPos = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 4; // This is the number of times a random loot selection is made.
_type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_distance = 20; // Distance from crate before crate is considered "visited"
_crate = "GuerillaCacheBox";
#define TITLE_COLOR "#FFFF66" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

_lootList = [[5,"ItemGoldBar"],[3,"ItemGoldBar10oz"],"ItemBriefcase100oz",[20,"ItemSilverBar"],[10,"ItemSilverBar10oz"]];

if (random 1 > _spawnChance and !_debug) exitWith {};

_pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["Pirate Treasure Event Spawning At %1", _pos];

_lootPos = [_pos,0,(_radius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["Pirate Treasure Event: creating ammo box at %1", _lootPos];};

_crate = _crate createVehicle [0,0,0];
_crate setPos _lootPos;
clearMagazineCargoGlobal _crate;
clearWeaponCargoGlobal _crate;

_cutGrass = createVehicle ["ClutterCutter_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
_cutGrass setPos _lootPos;

if (random 1 < _gemChance) then {
	_gem = ["ItemTopaz","ItemObsidian","ItemSapphire","ItemAmethyst","ItemEmerald","ItemCitrine","ItemRuby"] call dz_fn_array_selectRandom;
	_crate addMagazineCargoGlobal [_gem,1];
};

for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	
	if ((typeName _loot) == "ARRAY") then {
		_crate addMagazineCargoGlobal [_loot select 1,_loot select 0];
	} else {
		_crate addMagazineCargoGlobal [_loot,1];
	};
};

_wep = [["revolver_gold_EP1","6Rnd_45ACP"],["AKS_GOLD","30Rnd_762x39_AK47"]] call dz_fn_array_selectRandom;
_crate addWeaponCargoGlobal [_wep select 0,1];
_crate addMagazineCargoGlobal [_wep select 1,3];

_pack = DayZ_Backpacks call dz_fn_array_selectRandom;
_crate addBackpackCargoGlobal [_pack,1];

if (_type == "Hint") then {
	_img = (getText (configFile >> "CfgMagazines" >> "ItemRuby" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_TREASURE_TITLE","STR_CL_ESE_TREASURE"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_TREASURE"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Pirate Treasure event setup, waiting for %1 minutes", _timeout];};

_time = diag_tickTime;
_done = false;
_visited = false;
_isNear = true;

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
		{if (isPlayer _x && _x distance _crate <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		if (_visited) then {
			_vMarker = createMarker [ format ["loot_event_vMarker_%1", _time], [(_pos select 0), (_pos select 1) + 25]];
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
	{if (isPlayer _x && _x distance _crate >= _distance) then {_isNear = false};} count playableUnits;
};

// Clean up
deleteVehicle _crate;
deleteVehicle _cutGrass;

diag_log "Pirate Treasure Event Ended";
