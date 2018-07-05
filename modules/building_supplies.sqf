/*
	Original Construction "IKEA" Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 7-3-2018
*/

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_chainsawChance = .25; // Chance that a chainsaw with mixed gas will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_vaultChance = .25; // Chance that a safe or lockbox will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_markerRadius = 350; // Radius the loot can spawn and used for the marker.
_timeout = 20; // Time it takes for the event to time out (in minutes).
_debug = false; // Diagnostic logs used for troubleshooting.
_markPosition = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 15; // This is the number of times a random loot selection is made.
_messageType = "Hint"; // Type of announcement message. Options "Hint","TitleText". Warning: Hint requires that you have remote_messages.sqf installed.
_visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_visitDistance = 20; // Distance in meters from crate before crate is considered "visited"
_crate = "USVehicleBox"; // Class name of loot crate.

_lootList = [ // If the item has a number in front of it, then that many will be added to the crate if it is selected one time. Each item can be selected multiple times. Adjust the array configuration to your preferences.
	[3,"MortarBucket"],"ItemWoodStairs",[12,"CinderBlocks"],"plot_pole_kit",[12,"PartPlankPack"],[12,"PartPlywoodPack"],"m240_nest_kit","light_pole_kit","ItemWoodCrateKit","ItemFuelBarrel",
	[4,"metal_floor_kit"],[4,"ItemWoodFloor"],[4,"half_cinder_wall_kit"],[4,"metal_panel_kit"],"fuel_pump_kit",[4,"full_cinder_wall_kit"],"ItemWoodWallWithDoorLgLocked","storage_shed_kit","sun_shade_kit","wooden_shed_kit",
	[2,"ItemComboLock"],[4,"ItemWoodWallLg"],"ItemWoodWallGarageDoorLocked",[4,"ItemWoodWallWindowLg"],"wood_ramp_kit",[8,"ItemWoodFloorQuarter"],"bulk_ItemSandbag","bulk_ItemTankTrap","bulk_ItemWire","bulk_PartGeneric",
	"workbench_kit","cinder_garage_kit","cinder_door_kit","wood_shack_kit","deer_stand_kit",[3,"ItemWoodWallThird"],"ItemWoodLadder",[3,"desert_net_kit"],[3,"forest_net_kit"],[2,"ItemSandbagLarge"]
];

_vaultList = ["ItemVault","ItemLockbox"];
_sawList = ["Chainsaw","ChainSawB","ChainsawG","ChainsawP"];

// Random chance of event happening
_spawnRoll = random 1;
if (_spawnRoll > _spawnChance and !_debug) exitWith {};

// Random location
_position = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,2000,0] call BIS_fnc_findSafePos;

diag_log format["IKEA Event spawning at %1", _position];
 
_lootPos = [_position,0,(_markerRadius - 100),10,0,2000,0] call BIS_fnc_findSafePos;
 
if (_debug) then {diag_log format["IKEA Event: creating ammo box at %1", _lootPos];};

_lootBox = createVehicle [_crate,_lootPos,[], 0, "CAN_COLLIDE"];

clearMagazineCargoGlobal _lootBox;
clearWeaponCargoGlobal _lootBox;

// Chance for a vault
if (_spawnRoll < _vaultChance) then {
	_vault = _vaultList call dz_fn_array_selectRandom;
	_lootBox addMagazineCargoGlobal [_vault,1];
};

// Chance for a chainsaw
if (_spawnRoll < _chainsawChance) then {
	_saw = _sawList call dz_fn_array_selectRandom;
	_lootBox addMagazineCargoGlobal ["ItemJerryMixed",2];
	_lootBox addWeaponCargoGlobal [_saw,1];
};

 // Add loot
for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	
	if ((typeName _loot) == "ARRAY") then {
		_lootBox addMagazineCargoGlobal [_loot select 1,_loot select 0];
	} else {
		_lootBox addMagazineCargoGlobal [_loot,1];
	};
};

if (_messageType == "Hint") then {
	_image = (getText (configFile >> "CfgVehicles" >> "UralCivil_DZE" >> "picture"));
	_hint = "STR_CL_ESE_IKEA_HINT";
	RemoteMessage = ["hint", _hint, [_image]];
} else {
	_message = "STR_CL_ESE_IKEA";
	RemoteMessage = ["titleText",_message];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["IKEA Event setup, event will end in %1 minutes", _timeout];};

_startTime = diag_tickTime;
_eventMarker = "";
_crateMarker = "";
_visitMarker = "";
_finished = false;
_visitedCrate = false;
_playerNear = true;

while {!_finished} do {
	
	// Markers are processed in a loop for JIP players
	_eventMarker = createMarker [ format ["loot_eventMarker_%1", _startTime], _position];
	_eventMarker setMarkerShape "ELLIPSE";
	_eventMarker setMarkerColor "ColorGreen";
	_eventMarker setMarkerAlpha 0.5;
	_eventMarker setMarkerSize [(_markerRadius + 50), (_markerRadius + 50)];
	
	if (_markPosition) then {
		_crateMarker = createMarker [format["loot_event_debug_marker_%1",_startTime],_lootPos];
		_crateMarker setMarkerShape "ICON";
		_crateMarker setMarkerType "mil_dot";
		_crateMarker setMarkerColor "ColorGreen";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _lootBox <= _visitDistance && !_visitedCrate) then {_visitedCrate = true};} count playableUnits;
	
		// Add the visit marker to the center of the mission if enabled
		if (_visitedCrate) then {
			_visitMarker = createMarker [ format ["loot_event_visitMarker_%1", _startTime], _position];
			_visitMarker setMarkerShape "ICON";
			_visitMarker setMarkerType "hd_pickup";
			_visitMarker setMarkerColor "ColorBlack";
		}; 
	};
	
	uiSleep 1;
	
	deleteMarker _eventMarker;
	if !(isNil "_crateMarker") then {deleteMarker _crateMarker;};
	if !(isNil "_visitMarker") then {deleteMarker _visitMarker;}; 
	
	if (diag_tickTime - _startTime >= _timeout*60) then {
		_finished = true;
	};
};

// Prevent the crate from being deleted if a player is still visiting because that's just rude.
while {_playerNear} do {
	{if (isPlayer _x && _x distance _lootBox >= _visitDistance) then {_playerNear = false};} count playableUnits;
};

// Clean up
deleteVehicle _lootBox;

if (_debug) then {diag_log "IKEA Event Ended";};
