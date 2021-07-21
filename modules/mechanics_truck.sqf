/*
	Mechanic's Truck event by JasonTM
	This event spawns a truck filled with vehicle upgrade parts inside a building of type "Land_Hangar_2"
	7-8-2021
*/

local _timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _key = true; // Issue a key for the truck. The key will be in the gear.
local _visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the vehicle.
local _numpacks = 2; // Be mindful of how many backpacks cargo trucks can hold.
local _distance = 20; // Distance from vehicle before event is considered "visited"
local _nameMarker = true; // Center marker with the name of the mission.
local _type = "Hint"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
#define TITLE_COLOR "#ff9933" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define DEBUG false

// Get a list of all of the vehicle hangars on the map
local _list = (getMarkerPos "center") nearObjects ["Land_Hangar_2", 15000];
if (count _list == 0) exitWith {diag_log "Mechanic's Truck Event: No Land_Hangar_2 on the map.";};
local _garage = objNull;
local _pos = [];
local _i = 1;
local _success = false;

while {_i < 50} do {
	_garage = _list call BIS_fnc_selectRandom;
	_pos = getPosATL _garage;
	
	local _nearPlayer = false;
	{
		if (_x distance _pos < 50) exitWith {
			_nearPlayer = true;
		};
	} count playableUnits;
	
	// Check for near vehicles, players and plots
	if (count (_pos nearObjects ["LandVehicle", 20]) == 0 && !_nearPlayer && {count (_pos nearEntities ["Plastic_Pole_EP1_DZ", 100]) == 0}) exitWith {
		_success = true;
	};
	_i = _i + 1;
};

if (!_success) exitWith {diag_log "Mechanic's Truck Event: No suitable locations found.";};

local _near = nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","NameLocal"],1000];
local _loc = "Unknown Location";
if (count _near > 0) then {
	_loc = text (_near select 0);
};

diag_log format["Mechanic's Truck Event spawning near %1, at %2", _loc, _pos];

// Vehicle Upgrade kits - these include all parts to fully upgrade a DZE vehicle.
local _kit = [
	[["ItemTruckORP",1],["ItemTruckAVE",1],["ItemTruckLRK",1],["ItemTruckTNK",1],["PartEngine",2],["PartWheel",6],["ItemScrews",8],["PartGeneric",10],["equip_metal_sheet",5],["ItemWoodCrateKit",2],["PartFueltank",3],["ItemGunRackKit",2],["ItemFuelBarrel",2]],
	[["ItemORP",1],["ItemAVE",1],["ItemLRK",1],["ItemTNK",1],["PartEngine",2],["PartWheel",4],["ItemScrews",8],["equip_metal_sheet",6],["PartGeneric",8],["ItemWoodCrateKit",2],["ItemGunRackKit",2],["PartFueltank",2],["ItemFuelBarrel",1]],
	[["ItemHeliAVE",1],["ItemHeliLRK",1],["ItemHeliTNK",1],["equip_metal_sheet",5],["ItemScrews",2],["ItemTinBar",3],["equip_scrapelectronics",5],["equip_floppywire",5],["PartGeneric",4],["ItemWoodCrateKit",1],["ItemGunRackKit",1],["PartFueltank",2],["ItemFuelBarrel",1]],
	[["ItemTankORP",1],["ItemTankAVE",1],["ItemTankLRK",1],["ItemTankTNK",1],["PartEngine",6],["PartGeneric",6],["ItemScrews",6],["equip_metal_sheet",8],["ItemWoodCrateKit",2],["ItemGunRackKit",2],["PartFueltank",6],["ItemFuelBarrel",4]]
] call BIS_fnc_selectRandom;

// Tools needed to upgrade vehicles.
local _tools = ["ItemToolbox","ItemCrowbar","ItemSolder_DZE"];

if (_type == "Hint") then {
	RemoteMessage = ["hintNoImage",["STR_CL_ESE_MECHANIC_TITLE",["STR_CL_ESE_MECHANIC_START",_loc]],[TITLE_COLOR,TITLE_SIZE]];
} else {
	RemoteMessage = ["titleText",["STR_CL_ESE_MECHANIC_START",_loc]];
};
publicVariable "RemoteMessage";

// Spawn truck
local _class = ["Ural_INS_DZE","Ural_CDF_DZE","UralOpen_CDF_DZE","Ural_TK_CIV_EP1_DZE","Ural_UN_EP1_DZE","UralCivil_DZE","UralCivil2_DZE","UralSupply_TK_EP1_DZE","UralReammo_CDF_DZE","UralReammo_INS_DZE","UralRepair_CDF_DZE","UralRepair_INS_DZE","V3S_Open_TK_CIV_EP1_DZE","V3S_Open_TK_EP1_DZE","V3S_Civ_DZE","V3S_TK_EP1_DZE","V3S_Camper_DZE","V3S_RA_TK_GUE_EP1_DZE","Kamaz_DZE","KamazOpen_DZE","KamazRepair_DZE","KamazReammo_DZE","MTVR_DES_EP1_DZE","MTVR_DZE","MTVR_Open_DZE","MtvrRepair_DZE","MtvrReammo_DZE","T810A_ACR_DZE","T810A_ACR_DES_DZE","T810A_ACR_OPEN_DZE","T810A_ACR_DES_OPEN_DZE","T810_ACR_REAMMO_DZE","T810_ACR_REAMMO_DES_DZE","T810_ACR_REPAIR_DZE","T810_ACR_REPAIR_DES_DZE"] call BIS_fnc_selectRandom;
local _truck = _class createVehicle _pos;
_truck setDir (getDir _garage - 180); // Turn truck around to face the door.
_truck setPosATL (_garage modelToWorld [8.56738,2.10254,-2.55316]);
_truck setVariable ["ObjectID","1", true];
_truck setVariable ["CharacterID","0",true];
dayz_serverObjectMonitor set [count dayz_serverObjectMonitor, _truck];
clearWeaponCargoGlobal _truck;
clearMagazineCargoGlobal _truck;
_truck setVariable["Cleanup" + dayz_serverKey, true];

// Assign the hitpoints
{
	local _selection = getText(configFile >> "cfgVehicles" >> _class >> "HitPoints" >> _x >> "name");
	local _strH = "hit_" + (_selection);
	_truck setHit[_selection,0];
	_truck setVariable [_strH,0,true];
} count (_truck call vehicle_getHitpoints);

// Add key to the gear of the truck
if (_key) then {
	local _keyColor = ["Green","Red","Blue","Yellow","Black"] call BIS_fnc_selectRandom;
	local _keyNumber = (floor(random 2500)) + 1;
	local _keySelected = format["ItemKey%1%2",_keyColor,_keyNumber];
	local _isKeyOK = isClass(configFile >> "CfgWeapons" >> _keySelected);
	local _characterID = str(getNumber(configFile >> "CfgWeapons" >> _keySelected >> "keyid"));

	if (_isKeyOK) then {
		_truck addWeaponCargoGlobal [_keySelected,1];
		_truck setVariable ["CharacterID",_characterID,true];	
	} else {
		diag_log format ["Mechanic's Vehicle Event: There was a problem generating a key for the %1", _truck];
	};
};

// Add the loot
{
	_truck addMagazineCargoGlobal [(_x select 0), (_x select 1)];
} count _kit;

{
	_truck addWeaponCargoGlobal [_x, 1];
} count _tools;

for "_i" from 1 to _numpacks do {
	local _pack = ["CzechBackpack_DZE1","WandererBackpack_DZE1","LegendBackpack_DZE1","CoyoteBackpack_DZE1","LargeGunBag_DZE1"] call BIS_fnc_selectRandom;
	_truck addBackpackCargoGlobal [_pack,1];
};

// Add the publishing event handler
_truck addEventHandler ["GetIn", {
	local _truck = _this select 0;
	RemoteMessage = ["rollingMessages","STR_CL_DZMS_VEH1"];
	(owner (_this select 2)) publicVariableClient "RemoteMessage";
	local _class = typeOf _truck;
	local _worldspace = [getDir _truck, getPosATL _truck];
	_truck setVariable["Cleanup" + dayz_serverKey, false];
	local _uid = _worldspace call dayz_objectUID2;
	format ["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:", dayZ_instance, _class, 0, (_truck getVariable ["CharacterID", "0"]), _worldspace, [getWeaponCargo _truck,getMagazineCargo _truck,getBackpackCargo _truck], [], 1, _uid] call server_hiveWrite;
	local _result = (format["CHILD:388:%1:", _uid]) call server_hiveReadWrite;
	
	if ((_result select 0) != "PASS") then {
		deleteVehicle _truck;
		diag_log format ["Mechanic's Vehicle Event PublishVeh Error: failed to get id for %1 : UID %2.",_class, _uid];
	} else {
		_truck setVariable ["ObjectID", (_result select 1), true];
		_truck setVariable ["lastUpdate",diag_tickTime];
		_truck call fnc_veh_ResetEH;
		PVDZE_veh_Init = _truck;
		publicVariable "PVDZE_veh_Init";
		if (DEBUG) then {diag_log ("Mechanic's Vehicle Event PublishVeh: Created " + (_class) + " with ID " + str(_uid));};
	};
}];

local _time = diag_tickTime;
local _done = false;
local _visited = false;
local _isNear = true;
local _markers = [1,1,1];

//[position,createMarker,setMarkerColor,setMarkerType,setMarkerShape,setMarkerBrush,setMarkerSize,setMarkerText,setMarkerAlpha]
_markers set [0, [_pos, "MechanicsVeh" + str _time, "ColorBrown", "","ELLIPSE", "", [150,150], [], 0.7]];
if (_nameMarker) then {_markers set [1, [_pos, "MechanicsVehDot" + str _time, "ColorBlack", "mil_dot","ICON", "", [], ["Mechanic's Vehicle"], 0]];};
DZE_ServerMarkerArray set [count DZE_ServerMarkerArray, _markers]; // Markers added to global array for JIP player requests.
local _markerIndex = count DZE_ServerMarkerArray - 1;
PVDZ_ServerMarkerSend = ["start",_markers];
publicVariable "PVDZ_ServerMarkerSend";

while {!_done} do {
	uiSleep 3;
	if (_visitMark && !_visited) then {
		{
			if (isPlayer _x && {_x distance _pos <= _distance}) exitWith {
				_visited = true;
				_markers set [2, [[(_pos select 0), (_pos select 1) + 25], "MechanicsVehVmarker" + str _time, "ColorBlack", "hd_pickup","ICON", "", [], [], 0]];
				PVDZ_ServerMarkerSend = ["createSingle",(_markers select 2)];
				publicVariable "PVDZ_ServerMarkerSend";
				DZE_ServerMarkerArray set [_markerIndex, _markers];
			};
		} count playableUnits;
	};
	
	if (_timeout != -1) then {
		if (diag_tickTime - _time >= _timeout * 60) then {
			_done = true;
		};
	};
};

// If player is near, don't delete the truck.
while {_isNear} do {
	{if (isPlayer _x && _x distance _pos >= 30) exitWith {_isNear = false;};} count playableUnits;
};

// Tell all clients to remove the markers from the map.
local _remove = [];
{
	if (typeName _x == "ARRAY") then {
		_remove set [count _remove, (_x select 1)];
	};
} count _markers;

// Delete the truck if it has not been claimed.
if (_truck getVariable ("Cleanup" + dayz_serverKey)) then {deleteVehicle _truck;};

PVDZ_ServerMarkerSend = ["end",_remove];
publicVariable "PVDZ_ServerMarkerSend";
DZE_ServerMarkerArray set [_markerIndex, -1];