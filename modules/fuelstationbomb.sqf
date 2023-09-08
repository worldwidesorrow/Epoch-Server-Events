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
local _nameMarker = true; // Center marker with the name of the mission.
local _type = "Hint"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
#define TITLE_COLOR "#ff9933" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line

// You can adjust these loot selections to your liking. Must be magazine/item slot class name, not weapon or tool belt.
// Nested arrays are number of each item and item class name.
/*
local _lootArrays = [
	[[6,"full_cinder_wall_kit"],[1,"cinder_door_kit"],[1,"cinder_garage_kit"],[4,"forest_large_net_kit"]],
	[[6,"metal_floor_kit"],[6,"ItemWoodFloor"],[2,"ItemWoodStairs"],[10,"ItemSandbag"]],
	[[24,"CinderBlocks"],[8,"MortarBucket"]]
];
*/

// Vehicle Upgrade kits
local _lootArrays = [
/*Truck*/		[["ItemTruckORP",1],["ItemTruckAVE",1],["ItemTruckLRK",1],["ItemTruckTNK",1],["PartEngine",2],["PartWheel",6],["ItemScrews",8],["PartGeneric",10],["equip_metal_sheet",5],["ItemWoodCrateKit",2],["PartFueltank",3],["ItemGunRackKit",2],["ItemFuelBarrel",2]],
/*Vehicle*/		[["ItemORP",1],["ItemAVE",1],["ItemLRK",1],["ItemTNK",1],["PartEngine",2],["PartWheel",4],["ItemScrews",8],["equip_metal_sheet",6],["PartGeneric",8],["ItemWoodCrateKit",2],["ItemGunRackKit",2],["PartFueltank",2],["ItemFuelBarrel",1]],
/*Helicopter*/	[["ItemHeliAVE",1],["ItemHeliLRK",1],["ItemHeliTNK",1],["equip_metal_sheet",5],["ItemScrews",2],["ItemTinBar",3],["equip_scrapelectronics",5],["equip_floppywire",5],["PartGeneric",4],["ItemWoodCrateKit",1],["ItemGunRackKit",1],["ItemFuelBarrel",1]],
/*Tank-APC*/	[["ItemTankORP",1],["ItemTankAVE",1],["ItemTankLRK",1],["ItemTankTNK",1],["PartEngine",6],["PartGeneric",6],["ItemScrews",6],["equip_metal_sheet",8],["ItemWoodCrateKit",2],["ItemGunRackKit",2],["PartFueltank",6],["ItemFuelBarrel",4]]
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

if (_type == "Hint") then {
	RemoteMessage = ["hintNoImage",["STR_CL_ESE_FUELBOMB_TITLE",["STR_CL_ESE_FUELBOMB_START", _name, _delay]],[TITLE_COLOR,TITLE_SIZE]];
} else {
	RemoteMessage = ["titleText",["STR_CL_ESE_FUELBOMB_START", _name, _delay]];
};
publicVariable "RemoteMessage";

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
local _lootRad = 0;
local _lootPos = [0,0,0];
local _lootVeh = objNull;
local _lootArray = [];
local _grass = objNull;
local _grassArray = [];
local _markers = [1,1,1];

//[position,createMarker,setMarkerColor,setMarkerType,setMarkerShape,setMarkerBrush,setMarkerSize,setMarkerText,setMarkerAlpha]
_markers set [0, [_pos, "fuel" + str _time, "ColorRed", "","ELLIPSE", "", [150,150], [], 0.4]];
if (_nameMarker) then {_markers set [1, [_pos, "explosion" + str _time, "ColorBlack", "mil_dot","ICON", "", [], ["STR_CL_ESE_FUELBOMB_TITLE"], 0]];};
DZE_ServerMarkerArray set [count DZE_ServerMarkerArray, _markers]; // Markers added to global array for JIP player requests.
local _markerIndex = count DZE_ServerMarkerArray - 1;
PVDZ_ServerMarkerSend = ["start",_markers];
publicVariable "PVDZ_ServerMarkerSend";

// Start monitoring loop
while {!_done} do {
	uiSleep 3;
	if (_visitMark && !_visited) then {
		{
			if (isPlayer _x && {_x distance _pos <= _distance}) exitWith {
				_visited = true;
				_markers set [2, [[(_pos select 0), (_pos select 1) + 25], "fuelVmarker" + str _time, "ColorBlack", "hd_pickup","ICON", "", [], [], 0]];
				PVDZ_ServerMarkerSend = ["createSingle",(_markers select 2)];
				publicVariable "PVDZ_ServerMarkerSend";
				DZE_ServerMarkerArray set [_markerIndex, _markers];
			};
		} count playableUnits;
	};
	
	if (!_spawned && {diag_tickTime - _time >= _delay*60}) then {
		if (_type == "Hint") then {
			RemoteMessage = ["hintNoImage",["STR_CL_ESE_FUELBOMB_TITLE",["STR_CL_ESE_FUELBOMB_END",_name]],[TITLE_COLOR,TITLE_SIZE]];
		} else {
			RemoteMessage = ["titleText",["STR_CL_ESE_FUELBOMB_END",_name]];
		};
		publicVariable "RemoteMessage";
		
		// Blow the vehicle up
		"Bo_GBU12_LGB" createVehicle _pos;
		
		uiSleep 2;
		
		/*
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
		*/
		
		// Spawn loot around the destroyed vehicle
		{
			for "_i" from 1 to (_x select 1) do {
				_lootRad = (random 10) + 4;
				_lootPos = [_pos, _lootRad, random 360] call BIS_fnc_relPos;
				_lootPos set [2, 0];
				_lootVeh = createVehicle ["WeaponHolder", _lootPos, [], 0, "CAN_COLLIDE"];
				_lootVeh setVariable ["permaLoot", true];
				_lootVeh addMagazineCargoGlobal [(_x select 0), 1];
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
	uiSleep 3;
	_isNear = false;
	{if (isPlayer _x && _x distance _pos <= _distance) exitWith {_isNear = true;};} count playableUnits;
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

// Delete loot piles and grass cutters
{deleteVehicle _x;} count _lootArray;
if (count _grassArray > 0) then {{deleteVehicle _x;} count _grassArray;};