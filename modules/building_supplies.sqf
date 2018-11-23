/*
	Original Construction "IKEA" Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 11-15-2018
*/

private ["_spawnChance","_radius","_timeout","_debug","_nameMarker","_markPos","_lootAmount","_type","_visitMarker","_distance","_crate","_chainsawChance","_vaultChance","_lootList",
"_pos","_lootPos""_saw","_vault","_loot","_pack","_img","_title","_time","_marker","_pMarker","_vMarker","_dot","_done","_visited","_isNear","_box"];

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_chainsawChance = .25; // Chance that a chainsaw with mixed gas will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_vaultChance = .25; // Chance that a safe or lockbox will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_radius = 350; // Radius the loot can spawn and used for the marker.
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_debug = false; // Diagnostic logs used for troubleshooting.
_nameMarker = false; // Center marker with the name of the mission.
_markPos = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 15; // This is the number of times a random loot selection is made.
_type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMarker = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_distance = 20; // Distance in meters from crate before crate is considered "visited"
_crate = "USVehicleBox"; // Class name of loot crate.
#define TITLE_COLOR "#00FF11" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

_lootList = [ // If the item has a number in front of it, then that many will be added to the crate if it is selected one time. Each item can be selected multiple times. Adjust the array configuration to your preferences.
	[3,"MortarBucket"],"ItemWoodStairs",[12,"CinderBlocks"],"plot_pole_kit",[12,"PartPlankPack"],[12,"PartPlywoodPack"],"m240_nest_kit","light_pole_kit","ItemWoodCrateKit","ItemFuelBarrel",
	[4,"metal_floor_kit"],[4,"ItemWoodFloor"],[4,"half_cinder_wall_kit"],[4,"metal_panel_kit"],"fuel_pump_kit",[4,"full_cinder_wall_kit"],"ItemWoodWallWithDoorLgLocked","storage_shed_kit","sun_shade_kit","wooden_shed_kit",
	[2,"ItemComboLock"],[4,"ItemWoodWallLg"],"ItemWoodWallGarageDoorLocked",[4,"ItemWoodWallWindowLg"],"wood_ramp_kit",[8,"ItemWoodFloorQuarter"],"bulk_ItemSandbag","bulk_ItemTankTrap","bulk_ItemWire","bulk_PartGeneric",
	"workbench_kit","cinder_garage_kit","cinder_door_kit","wood_shack_kit","deer_stand_kit",[3,"ItemWoodWallThird"],"ItemWoodLadder",[3,"desert_net_kit"],[3,"forest_net_kit"],[2,"ItemSandbagLarge"]
];

if (random 1 > _spawnChance and !_debug) exitWith {};

_pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["IKEA Event spawning at %1", _pos];
 
_lootPos = [_pos,0,(_radius - 100),10,0,.4,0] call BIS_fnc_findSafePos;
 
if (_debug) then {diag_log format["IKEA Event: creating ammo box at %1", _lootPos];};

_box = _crate createVehicle [0,0,0];
_box setPos _lootPos;

clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

if (random 1 < _vaultChance) then {
	_vault = ["ItemVault","ItemLockbox"] call dz_fn_array_selectRandom;
	_box addMagazineCargoGlobal [_vault,1];
};

if (random 1 < _chainsawChance) then {
	_saw = ["Chainsaw","ChainSawB","ChainsawG","ChainsawP"] call dz_fn_array_selectRandom;
	_box addMagazineCargoGlobal ["ItemJerryMixed",2];
	_box addWeaponCargoGlobal [_saw,1];
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

if (_type == "Hint") then {
	_img = (getText (configFile >> "CfgVehicles" >> "UralCivil_DZE" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_IKEA_TITLE","STR_CL_ESE_IKEA"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_IKEA"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["IKEA Event setup, event will end in %1 minutes", _timeout];};

_time = diag_tickTime;
_done = false;
_visited = false;
_isNear = true;

while {!_done} do {
	
	_marker = createMarker [ format ["eventMark%1", _time], _pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorGreen";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [_radius,_radius];
	
	if (_nameMarker) then {
		_dot = createMarker [format["eventDot%1",_time],_pos];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "IKEA supply";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [format["eventDebug%1",_time],_lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorGreen";
	};
	
	if (_visitMarker) then {
		{if (isPlayer _x && _x distance _box <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		// Add the visit marker to the center of the mission if enabled
		if (_visited) then {
			_vMarker = createMarker [ format ["EventVisit%1", _time], [(_pos select 0), (_pos select 1) + 25]];
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

// Clean up
deleteVehicle _box;

diag_log "IKEA Event Ended";
