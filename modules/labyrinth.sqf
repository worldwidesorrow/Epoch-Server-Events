/*
	Original Labyrinth Event by Caveman
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 7-25-2018
*/

private ["_spawnChance","_markerRadius","_timeout","_debug","_nameMarker","_markPos",
"_lootAmount","_messageType","_visitMark","_distance","_crate","_numGems","_lootList",
"_gems","_position","_posarray","_spawnObjects","_lootPos","_box",
"_runover","_clutter","_gems","_gem","_loot","_pack","_img",
"_time","_marker","_pMarker","_vMarker","_dot","_finished","_visited","_isNear"];

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_numGems = [0,1]; // Random number of gems to add to the crate [minimum, maximum]. For no gems, set to [0,0].
_markerRadius = 200; // Radius the loot can spawn and used for the marker
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_debug = false; // Diagnostic logs used for troubleshooting.
_nameMarker = true; // Center marker with the name of the mission.
_markPos = false; // Puts a marker exactly where the loot spawns.
_lootAmount = 4; // This is the number of times a random loot selection is made.
_messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_distance = 20; // Distance from crate before crate is considered "visited"
_crate = "GuerillaCacheBox";
#define TITLE_COLOR "#ccff33" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

_lootList = [[5,"ItemGoldBar"],[3,"ItemGoldBar10oz"],"ItemBriefcase100oz",[20,"ItemSilverBar"],[10,"ItemSilverBar10oz"]];

if (random 1 > _spawnChance and !_debug) exitWith {};

// Random location
_position = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.2,0] call BIS_fnc_findSafePos;

diag_log format["Labyrinth Event Spawning At %1", _position];

_posarray = [
	[(_position select 0) + 9, (_position select 1) + 2.3,-0.012],
	[(_position select 0) - 18.6, (_position select 1) + 15.6,-0.012],
	[(_position select 0) - 8.5, (_position select 1) - 21,-0.012],
	[(_position select 0) - 33, (_position select 1) - 6,-0.012],
	[(_position select 0) + 5, (_position select 1) - 44,-0.012],
	[(_position select 0) - 23, (_position select 1) - 20,-0.012],
	[(_position select 0) + 13, (_position select 1) - 23,-0.012],
	[(_position select 0) + 7, (_position select 1) - 6,-0.012],
	[(_position select 0) - 5, (_position select 1) + 1,-0.012],
	[(_position select 0) - 42, (_position select 1) - 6,-0.012],
	[(_position select 0) - 4.3, (_position select 1) - 39,-0.012]
];

_spawnObjects = {
	private ["_objArray","_offset","_position","_obj","_objects","_type","_pos"];

	_objects = _this select 0;
	_pos = _this select 1;
	_objArray = [];

	{
		_type = _x select 0;
		_offset = _x select 1;
		_position = [(_pos select 0) + (_offset select 0), (_pos select 1) + (_offset select 1), (_offset select 2)];
		_obj = _type createVehicle [0,0,0];
		if (count _x > 2) then {
			_obj setDir (_x select 2);
		};
		_obj setPos _position;
		_obj setVectorUp surfaceNormal position _obj;
		_obj addEventHandler ["HandleDamage",{0}];
		_obj enableSimulation false;
		_objArray set [count _objArray, _obj];
	} forEach _objects;

	_objArray
};

_lootPos = _posarray call dz_fn_array_selectRandom;

if (_debug) then {diag_log format["Labyrinth Event: creating ammo box at %1", _lootPos];};

_box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

_clutter = createVehicle ["ClutterCutter_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
_clutter setPos _lootPos;

_runover = [[
	["Land_MBG_Shoothouse_1",[-35,-6.5,-0.12]],
	["Land_MBG_Shoothouse_1",[-12,9,-0.12]],
	["Land_MBG_Shoothouse_1",[-16,-19.3,-0.12]],
	["Land_MBG_Shoothouse_1",[7,-15,-0.12]],
	["Land_MBG_Shoothouse_1",[3,-39.5,-0.12]],
	["Land_A_Castle_Bergfrit",[9.5,3,-10.52]],
	["Land_A_Castle_Donjon_dam",[4,17,-1.93]],
	["Land_A_Castle_Wall1_20",[-11.6,21.7,-7.28]],
	["Land_A_Castle_Wall1_20",[-35.4,6.4,-7.28]],
	["Land_A_Castle_Donjon",[16,-10.3,-1.93]],
	["Sign_arrow_down_large_EP1",[15,-35,0.52]],
	["Sign_arrow_down_large_EP1",[-8.6,-51,0.52]],
	["Sign_arrow_down_large_EP1",[-27,-30.5,0.52]],
	["Sign_arrow_down_large_EP1",[-46,-17.4,0.52]],
	["Sign_arrow_down_large_EP1",[-22.7,7.7,0.52]],
	["MAP_t_acer2s",[-8,-31,-0.12]],
	["MAP_t_acer2s",[-46.5,-15,-0.12],91.4],
	["MAP_t_acer2s",[-23,10,-0.12],89.09],
	["MAP_t_acer2s",[-27.3,-28,-0.12],90.6],
	["MAP_t_acer2s",[14,-32,-0.12],-88.1],
	["MAP_t_acer2s",[-8.5,-48,-0.12],86.08]
],_position] call _spawnObjects;

_gems = (round(random((_numGems select 1) - (_numGems select 0)))) + (_numGems select 0);

if (_debug) then {diag_log format["Labyrinth Event: %1 gems added to crate", _gems];};

if (_gems > 0) then {
	for "_i" from 1 to _gems do {
		_gem = ["ItemTopaz","ItemObsidian","ItemSapphire","ItemAmethyst","ItemEmerald","ItemCitrine","ItemRuby"] call dz_fn_array_selectRandom;
		_box addMagazineCargoGlobal [_gem,1];
	};
};

for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	
	if ((typeName _loot) == "ARRAY") then {
		_box addMagazineCargoGlobal [_loot select 1,_loot select 0];
	} else {
		_box addMagazineCargoGlobal [_loot,1];
	};
};

_pack = DayZ_Backpacks call dz_fn_array_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_messageType == "Hint") then {
	_img = (getText (configFile >> "CfgVehicles" >> "Land_MBG_Shoothouse_1" >> "icon"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_LABYRINTH_TITLE","STR_CL_ESE_LABYRINTH"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_LABYRINTH"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Labyrinth event setup, waiting for %1 minutes", _timeout];};

_time = diag_tickTime;
_finished = false;
_visited = false;
_isNear = true;

while {!_finished} do {
	
	_marker = createMarker [ format ["eventmarker%1", _time], _position];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorYellow";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [(_markerRadius + 50), (_markerRadius + 50)];
	
	if (_nameMarker) then {
		_dot = createMarker [format["eventDot%1",_time],_position];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "Labyrinth";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [ format ["eventPos%1", _time], _lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorYellow";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _box <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		if (_visited) then {
			_vMarker = createMarker [ format ["eventVisit%1", _time], [(_position select 0), (_position select 1) + 25]];
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
			_finished = true;
		};
	};
};

while {_isNear} do {
	{if (isPlayer _x && _x distance _box >= _distance) then {_isNear = false};} count playableUnits;
};

deleteVehicle _box;
deleteVehicle _clutter;

{
	deleteVehicle _x;
} forEach _runover;

diag_log "Labyrinth Event Ended";

