/*
	Original Labyrinth Event by Caveman
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Updated for DayZ Epoch 1.0.7+ by JasonTM
	Last update: 06-01-2021
*/

local _spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
local _numGems = [0,1]; // Random number of gems to add to the crate [minimum, maximum]. For no gems, set to [0,0].
local _radius = 250; // Radius the loot can spawn and used for the marker
local _timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _debug = false; // Diagnostic logs used for troubleshooting.
local _nameMarker = true; // Center marker with the name of the mission.
local _markPos = false; // Puts a marker exactly where the loot spawns.
local _lootAmount = 4; // This is the number of times a random loot selection is made.
local _messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
local _visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
local _distance = 20; // Distance from crate before crate is considered "visited"
local _crate = "GuerillaCacheBox";
#define TITLE_COLOR "#ccff33" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

local _lootList = [[5,"ItemGoldBar"],[3,"ItemGoldBar10oz"],"ItemBriefcase100oz",[20,"ItemSilverBar"],[10,"ItemSilverBar10oz"]];

if (random 1 > _spawnChance and !_debug) exitWith {};

local _pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["Labyrinth Event Spawning At %1", _pos];

local _posarray = [
	[(_pos select 0) + 9, (_pos select 1) + 2.3,-0.012],
	[(_pos select 0) - 18.6, (_pos select 1) + 15.6,-0.012],
	[(_pos select 0) - 8.5, (_pos select 1) - 21,-0.012],
	[(_pos select 0) - 33, (_pos select 1) - 6,-0.012],
	[(_pos select 0) + 5, (_pos select 1) - 44,-0.012],
	[(_pos select 0) - 23, (_pos select 1) - 20,-0.012],
	[(_pos select 0) + 13, (_pos select 1) - 23,-0.012],
	[(_pos select 0) + 7, (_pos select 1) - 6,-0.012],
	[(_pos select 0) - 5, (_pos select 1) + 1,-0.012],
	[(_pos select 0) - 42, (_pos select 1) - 6,-0.012],
	[(_pos select 0) - 4.3, (_pos select 1) - 39,-0.012]
];

local _spawnObjects = {
	local _pos = _this select 1;
	local _objArray = [];
	local _obj = objNull;
	{
		local _offset = _x select 1;
		local _position = [(_pos select 0) + (_offset select 0), (_pos select 1) + (_offset select 1), 0];
		local _obj = (_x select 0) createVehicle [0,0,0];
		if (count _x > 2) then {
			_obj setDir (_x select 2);
		};
		_obj setPos _position;
		_obj setVectorUp surfaceNormal position _obj;
		_obj addEventHandler ["HandleDamage",{0}];
		_obj enableSimulation false;
		_objArray set [count _objArray, _obj];
	} count (_this select 0);
	_objArray
};

local _lootPos = _posarray call BIS_fnc_selectRandom;

if (_debug) then {diag_log format["Labyrinth Event: creating ammo box at %1", _lootPos];};

local _box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

local _clutter = createVehicle ["ClutterCutter_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
_clutter setPos _lootPos;

local _objects = [[
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
],_pos] call _spawnObjects;

local _gems = (round(random((_numGems select 1) - (_numGems select 0)))) + (_numGems select 0);

if (_debug) then {diag_log format["Labyrinth Event: %1 gems added to crate", _gems];};

if (_gems > 0) then {
	for "_i" from 1 to _gems do {
		local _gem = ["ItemTopaz","ItemObsidian","ItemSapphire","ItemAmethyst","ItemEmerald","ItemCitrine","ItemRuby"] call BIS_fnc_selectRandom;
		_box addMagazineCargoGlobal [_gem,1];
	};
};

for "_i" from 1 to _lootAmount do {
	local _loot = _lootList call BIS_fnc_selectRandom;
	
	if ((typeName _loot) == "ARRAY") then {
		_box addMagazineCargoGlobal [_loot select 1,_loot select 0];
	} else {
		_box addMagazineCargoGlobal [_loot,1];
	};
};

local _pack = ["Patrol_Pack_DZE1","Assault_Pack_DZE1","Czech_Vest_Pouch_DZE1","TerminalPack_DZE1","TinyPack_DZE1","ALICE_Pack_DZE1","TK_Assault_Pack_DZE1","CompactPack_DZE1","British_ACU_DZE1","GunBag_DZE1","NightPack_DZE1","SurvivorPack_DZE1","AirwavesPack_DZE1","CzechBackpack_DZE1","WandererBackpack_DZE1","LegendBackpack_DZE1","CoyoteBackpack_DZE1","LargeGunBag_DZE1"] call BIS_fnc_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_messageType == "Hint") then {
	local _img = (getText (configFile >> "CfgVehicles" >> "Land_MBG_Shoothouse_1" >> "icon"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_LABYRINTH_TITLE","STR_CL_ESE_LABYRINTH"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_LABYRINTH"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Labyrinth event setup, waiting for %1 minutes", _timeout];};

local _time = diag_tickTime;
local _finished = false;
local _visited = false;
local _isNear = true;
local _markers = [1,1,1,1];

//[position,createMarker,setMarkerColor,setMarkerType,setMarkerShape,setMarkerBrush,setMarkerSize,setMarkerText,setMarkerAlpha]
_markers set [0, [_pos, format ["eventMark%1", _time], "ColorYellow", "","ELLIPSE", "", [_radius, _radius], [], 0.5]];
if (_nameMarker) then {_markers set [1, [_pos, format ["eventDot%1",_time], "ColorBlack", "mil_dot","ICON", "", [], ["STR_CL_ESE_LABYRINTH_TITLE"], 0]];};
if (_markPos) then {_markers set [2, [_lootPos, format ["eventDebug%1",_time], "ColorYellow", "mil_dot","ICON", "", [], [], 0]];};
DZE_ServerMarkerArray set [count DZE_ServerMarkerArray, _markers]; // Markers added to global array for JIP player requests.
local _markerIndex = count DZE_ServerMarkerArray - 1;
PVDZ_ServerMarkerSend = ["start",_markers];
publicVariable "PVDZ_ServerMarkerSend";

while {!_finished} do {
	uiSleep 3;
	if (_visitMark && !_visited) then {
		{
			if (isPlayer _x && {_x distance _box <= _distance}) exitWith {
				_visited = true;
				_markers set [3, [[(_pos select 0), (_pos select 1) + 25], format ["EventVisit%1", _time], "ColorBlack", "hd_pickup","ICON", "", [], [], 0]];
				PVDZ_ServerMarkerSend = ["createSingle",(_markers select 3)];
				publicVariable "PVDZ_ServerMarkerSend";
				DZE_ServerMarkerArray set [_markerIndex, _markers];
			};
		} count playableUnits;
	};
	
	if (_timeout != -1) then {
		if (diag_tickTime - _time >= _timeout*60) then {
			_finished = true;
		};
	};
};

while {_isNear} do {
	{if (isPlayer _x && _x distance _box >= _distance) exitWith {_isNear = false};} count playableUnits;
};

// Tell all clients to remove the markers from the map
local _remove = [];
{
	if (typeName _x == "ARRAY") then {
		_remove set [count _remove, (_x select 1)];
	};
} count _markers;
PVDZ_ServerMarkerSend = ["end",_remove];
publicVariable "PVDZ_ServerMarkerSend";
DZE_ServerMarkerArray set [_markerIndex, -1];
{
	deleteVehicle _x;
} count _objects;
deleteVehicle _box;
deleteVehicle _clutter;

diag_log "Labyrinth Event Ended";

