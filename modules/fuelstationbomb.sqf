/*
	Fuel Station Bombing event by JasonTM
	Credit to juandayz for original "Random Explosions on Gas Stations" event.
	Updated to work with DayZ Epoch 1.0.7
	Last edited 6-1-2021
	***As of now, this event only has gas station positions for Chernarus.
*/

local _timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _delay = 2; // This is the time in minutes it will take for the explosion to occur after announcement
local _lowerGrass = true; // remove grass underneath loot so it is easier to find small objects
local _visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the vehicle.
local _distance = 20; // Distance from vehicle before event is considered "visited"

// You can adjust these loot selections to your liking. Must be magazine/item slot class name, not weapon or tool belt.
// Nested arrays are number of each item and item class name.
local _lootArrays = [
	[[6,"full_cinder_wall_kit"],[1,"cinder_door_kit"],[1,"cinder_garage_kit"],[4,"forest_large_net_kit"]],
	[[6,"metal_floor_kit"],[6,"ItemWoodFloor"],[2,"ItemWoodStairs"],[10,"ItemSandbag"]],
	[[24,"CinderBlocks"],[8,"MortarBucket"]]
];

// Select random loot array from above
local _loot = _lootArrays call BIS_fnc_selectRandom;

// Initialize locations array
if (isNil "FuelStationEventArray") then {
	FuelStationEventArray = [
		// Vehicle direction, vehicle position, fuel station name
		[96.8,[3640.58,8979.26,0],"Vybor"],
		[58.3,[6708.22,2986.89,0],"Cherno"],
		[10,[5849.21,10085.1,0],"Grishino"],
		[130,[7243.35,7644.83,0],"Novy Sobor"],
		[29,[10163.4,5304.94,0],"Staroye"],
		[94.6,[9497.25,2016,0],"Elektro"],
		[347,[13394.8,6605.09,0],"Solnechiy"],
		[200,[2034.43,2242.05,0],"Kamenka"],
		[8.5,[2681.41,5604.03,0],"Zelenogorsk"],
		[87,[4734.43,6373.43,0],"Pogorevka"],
		[329.3,[10456.5,8868.75,0],"Gorka"],
		[10.5,[12998.1,10074.4,0],"Berezino"]
	];
};

// Don't spawn the event at a fuel station where a player is refueling/repairing a vehicle
local _validSpot = false;
local _random = [];
local _pos = [0,0,0];

while {!_validSpot} do {
	_random = FuelStationEventArray call BIS_fnc_selectRandom;
	_pos = _random select 1;
	{if (isPlayer _x && _x distance _pos >= 100) then {_validSpot = true};} count playableUnits; // players are at least 100 meters away.
};

local _dir = _random select 0;
local _name = _random select 2;

{ // Remove current location from array so there are no repeats
	if (_name == (_x select 2)) exitWith {
		FuelStationEventArray = [FuelStationEventArray,_forEachIndex] call fnc_deleteAt;
	};
} forEach FuelStationEventArray;

// If all locations have been removed, reset to original array by destroying global variable
if (count FuelStationEventArray == 0) then {FuelStationEventArray = nil;};

[nil,nil,rTitleText,format["A bomb has been planted on a truck at the %1 fuel station\nIt will explode in %2 minutes", _name, _delay], "PLAIN",10] call RE;

// Spawn truck
local _truck = "Ural_CDF" createVehicle _pos;
_truck setDir _dir;
_truck setPos _pos;
_truck setVehicleLock "locked";
_truck setVariable ["CharacterID","9999",true];

// Disable damage to near fuel pumps so the explosion doesn't destroy them.
// Otherwise players will complain about not being able to refuel and repair their vehicles.
{
	_x allowDamage false;
} count (_pos nearObjects ["Land_A_FuelStation_Feed", 30]);

local _time = diag_tickTime;
local _done = false;
local _visited = false;
local _isNear = true;
local _spawned = false;
local _lootArray = [];
local _grassArray = [];
local _marker = "";
local _dot = "";
local _vMarker = "";
local _lootRad = 0;
local _lootPos = [0,0,0];
local _lootVeh = objNull;
local _lootArray = [];
local _grass = objNull;
local _grassArray = [];

// Start monitoring loop
while {!_done} do {
	
	_marker = createMarker ["fuel" + str _time,_pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerAlpha 0.4;
	_marker setMarkerSize [150,150];
	
	_dot = createMarker ["explosion" + str _time, _pos];
	_dot setMarkerShape "ICON";
	_dot setMarkerType "mil_dot";
	_dot setMarkerColor "ColorBlack";
	_dot setMarkerText "Fuel Station Explosion";
	
	if (_visitMark) then {
		if (!_visited) then {
			{
				if (isPlayer _x && _x distance _pos <= _distance) then {
					_visited = true;
				};
			} count playableUnits;
		};
	
		if (_visited) then {
			_vMarker = createMarker ["fuelVmarker" + str _time, [(_pos select 0), (_pos select 1) + 25]];
			_vMarker setMarkerShape "ICON";
			_vMarker setMarkerType "hd_pickup";
			_vMarker setMarkerColor "ColorBlack";
		}; 
	};
	
	uiSleep 3;
	
	deleteMarker _marker;
	deleteMarker _dot;
	if !(isNil "_vMarker") then {deleteMarker _vMarker;};
	
	if (!_spawned && {diag_tickTime - _time >= _delay*60}) then {
		
		[nil,nil,rTitleText,format["Explosion at the %1 fuel station!\nRecover the building supplies!",_name], "PLAIN",10] call RE;
		
		// Blow the vehicle up
		"Bo_GBU12_LGB" createVehicle _pos;
		
		uiSleep 2;
		
		// Spawn loot around the destroyed vehicle
		{
			for "_i" from 1 to (_x select 0) do {
				_lootRad = (random 10) + 4;
				_lootPos = [_pos, _lootRad, random 360] call BIS_fnc_relPos;
				_lootPos set [2, 0];
				_lootVeh = createVehicle ["WeaponHolder", _lootPos, [], 0, "CAN_COLLIDE"];
				_lootVeh setVariable ["permaLoot", true];
				_lootVeh addMagazineCargoGlobal [(_x select 1), 1];
				_lootArray set[count _lootArray, _lootVeh];
				if (_lowerGrass) then {
					_grass = createVehicle ["ClutterCutter_small_2_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
					_grassArray set[count _grassArray, _grass];
				};
			};
		} count _loot;
		
		// Reset the timer once loot is spawned
		_time = diag_tickTime;
		_spawned = true;
	};
	
	// Timeout timer starts after loot is spawned
	if (_spawned && {_timeout != -1}) then {
		if (diag_tickTime - _time >= _timeout*60) then {
			_done = true;
		};
	};
};

// If player is near, don't delete the loot piles
while {_isNear} do {
	{if (isPlayer _x && _x distance _pos >= 30) then {_isNear = false};} count playableUnits;
};

// Delete loot piles and grass cutters
{deleteVehicle _x;} count _lootArray;
if (count _grassArray > 0) then {{deleteVehicle _x;} count _grassArray;};