/*
	Original UN Supply Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 7-3-2018
*/

_spawnChance =  1; // Percentage chance of event happening. The number must be between 0 and 1. 1 = 100% chance.
_vaultChance = .25; // Percentage chance of safe or lockbox being added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_markerRadius = 350; // Radius the loot can spawn and used for the marker
_debug = false; // Puts a marker exactly were the loot spawns
_nameMarker = false; // Center marker with the name of the mission.
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_markPosition = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 50; // This is the number of times a random loot selection is made.
_messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_visitDistance = 20; // Distance from crate before crate is considered "visited"
_crate = "USVehicleBox"; // Class name of loot crate.

_bloodbag = "";
if(dayz_classicBloodBagSystem) then {_bloodbag = "ItemBloodbag";} else {_bloodbag = "bloodBagONEG";};

_lootList = 
[
	_bloodbag,"ItemBandage","ItemAntibiotic","ItemEpinephrine","ItemMorphine","ItemPainkiller","ItemAntibacterialWipe","ItemHeatPack","ItemKiloHemp", // meds
	"Skin_Camo1_DZ","Skin_CZ_Soldier_Sniper_EP1_DZ","Skin_CZ_Special_Forces_GL_DES_EP1_DZ","Skin_Drake_Light_DZ","Skin_FR_OHara_DZ","Skin_FR_Rodriguez_DZ","Skin_Graves_Light_DZ","Skin_Sniper1_DZ","Skin_Soldier1_DZ","Skin_Soldier_Bodyguard_AA12_PMC_DZ", // skins
	"ItemSodaSmasht","ItemSodaClays","ItemSodaR4z0r","ItemSodaPepsi","ItemSodaCoke","FoodCanBakedBeans","FoodCanPasta","FoodCanSardines","FoodMRE","ItemWaterBottleBoiled","ItemSodaRbull","FoodBeefCooked","FoodMuttonCooked","FoodChickenCooked","FoodRabbitCooked","FoodBaconCooked","FoodGoatCooked","FoodDogCooked","FishCookedTrout","FishCookedSeaBass","FishCookedTuna", // food
	"PartFueltank","PartWheel","PartEngine","PartGlass","PartGeneric","PartVRotor","ItemJerrycan","ItemFuelBarrel","equip_hose", // vehicle parts
	"ItemDesertTent","ItemDomeTent","ItemTent"// tents
];
_toolList = ["ItemToolbox","ItemToolbox","ItemKnife","ItemEtool","ItemGPS","Binocular_Vector","NVGoggles_DZE","ItemHatchet","ItemCrowbar","ItemSledge"];
_vaultList = ["ItemVault","ItemLockbox"];

// Random chance of event happening
_spawnRoll = random 1;
if (_spawnRoll > _spawnChance and !_debug) exitWith {};

// Random location
_position = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,2000,0] call BIS_fnc_findSafePos;

diag_log format["UN Supply Drop Event spawning at %1", _position];

_lootPos = [_position,0,(_markerRadius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["UN Supply Drop: creating ammo box at %1", _lootPos];};

_lootBox = createVehicle [_crate,_lootPos,[], 0, "CAN_COLLIDE"];
clearMagazineCargoGlobal _lootBox;
clearWeaponCargoGlobal _lootBox;

// Chance for a vault
if (_spawnRoll < _vaultChance) then {
	_vault = _vaultList call dz_fn_array_selectRandom;
	_lootBox addMagazineCargoGlobal [_vault,1];
};

 // Add loot
for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	_lootBox addMagazineCargoGlobal [_loot,1];
};

 // Add tools
for "_i" from 1 to 5 do {
	_tool = _toolList call dz_fn_array_selectRandom;
	_lootBox addWeaponCargoGlobal [_tool,1];
};

// Add backpack
_backpack = DayZ_Backpacks call dz_fn_array_selectRandom;
_lootBox addBackpackCargoGlobal [_backpack,1];

if (_messageType == "Hint") then {
	 _image = (getText (configFile >> "CfgVehicles" >> "Mi17_UN_CDF_EP1" >> "picture"));
	 _hint = "STR_CL_ESE_UNSUPPLY_HINT";
	RemoteMessage = ["hint", _hint, [_image]];
} else {
	_message = "STR_CL_ESE_UNSUPPLY";
	RemoteMessage = ["titleText",_message];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["U.N. Supply Drop Event setup, waiting for %1 minutes", _timeout];};

_startTime = diag_tickTime;
_eventMarker = "";
_crateMarker = "";
_visitMarker = "";
_textMarker = "";
_finished = false;
_visitedCrate = false;
_playerNear = true;
_detached = false;

while {!_finished} do {
	
	_eventMarker = createMarker [ format ["loot_eventMarker_%1", _startTime], _position];
	_eventMarker setMarkerShape "ELLIPSE";
	_eventMarker setMarkerColor "ColorBlue";
	_eventMarker setMarkerAlpha 0.5;
	_eventMarker setMarkerSize [(_markerRadius + 50), (_markerRadius + 50)];
	
	if (_nameMarker) then {
		_textMarker = createMarker [format["loot_text_marker_%1",_startTime],_position];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_dot";
		_textMarker setMarkerColor "ColorBlack";
		_textMarker setMarkerText "UN Supply Drop";
	};
	
	if (_markPosition) then {
		_crateMarker = createMarker [format["loot_event_debug_marker_%1",_startTime],_lootPos];
		_crateMarker setMarkerShape "ICON";
		_crateMarker setMarkerType "mil_dot";
		_crateMarker setMarkerColor "ColorBlue";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _lootBox <= _visitDistance && !_visitedCrate) then {_visitedCrate = true};} count playableUnits;
	
		// Add the visit marker to the center of the mission
		if (_visitedCrate) then {
			_visitMarker = createMarker [ format ["loot_event_visitMarker_%1", _startTime], [(_position select 0), (_position select 1) + 25]];
			_visitMarker setMarkerShape "ICON";
			_visitMarker setMarkerType "hd_pickup";
			_visitMarker setMarkerColor "ColorBlack";
		}; 
	};
	
	uiSleep 1;
	
	deleteMarker _eventMarker;
	if !(isNil "_textMarker") then {deleteMarker _textMarker;};
	if !(isNil "_crateMarker") then {deleteMarker _crateMarker;};
	if !(isNil "_visitMarker") then {deleteMarker _visitMarker;};
	
	if (_timeout != -1) then {
		if (diag_tickTime - _startTime >= _timeout*60) then {
			_finished = true;
		};
	};
};

// Prevent the crate from being deleted if a player is still visiting because that's just rude.
while {_playerNear} do {
	{if (isPlayer _x && _x distance _lootBox >= _visitDistance) then {_playerNear = false};} count playableUnits;
};

// Clean up
deleteVehicle _lootBox;

if (_debug) then {diag_log "EVENT: U.N. Supply Crate Ended";};
