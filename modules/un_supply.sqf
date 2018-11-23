/*
	Original UN Supply Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 11-15-2018
*/

private ["_spawnChance","_vaultChance","_radius","_debug","_nameMarker","_timeout","_markPos","_lootAmount","_type","_visitMark",
"_distance","_crate","_bloodbag","_lootList","_tools","_pos","_lootPos","_box","_vault","_pack",
"_loot","_time","_marker","_pMarker","_vMarker","_dot","_done","_visited","_isNear"];

_spawnChance = 1; // Percentage chance of event happening. The number must be between 0 and 1. 1 = 100% chance.
_vaultChance = .25; // Percentage chance of safe or lockbox being added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_radius = 350; // Radius the loot can spawn and used for the marker
_debug = false; // Diagnostic logs used for troubleshooting.
_nameMarker = false; // Center marker with the name of the mission.
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_markPos = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 50; // This is the number of times a random loot selection is made.
_type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_distance = 20; // Distance from crate before crate is considered "visited"
_crate = "USVehicleBox"; // Class name of loot crate.
#define TITLE_COLOR "#0D00FF" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

_bloodbag = if (dayz_classicBloodBagSystem) then {"ItemBloodbag";} else {"bloodBagONEG";};

_lootList = [
	_bloodbag,"ItemBandage","ItemAntibiotic","ItemEpinephrine","ItemMorphine","ItemPainkiller","ItemAntibacterialWipe","ItemHeatPack","ItemKiloHemp", // meds
	"Skin_Camo1_DZ","Skin_CZ_Soldier_Sniper_EP1_DZ","Skin_CZ_Special_Forces_GL_DES_EP1_DZ","Skin_Drake_Light_DZ","Skin_FR_OHara_DZ","Skin_FR_Rodriguez_DZ","Skin_Graves_Light_DZ","Skin_Sniper1_DZ","Skin_Soldier1_DZ","Skin_Soldier_Bodyguard_AA12_PMC_DZ", // skins
	"ItemSodaSmasht","ItemSodaClays","ItemSodaR4z0r","ItemSodaPepsi","ItemSodaCoke","FoodCanBakedBeans","FoodCanPasta","FoodCanSardines","FoodMRE","ItemWaterBottleBoiled","ItemSodaRbull","FoodBeefCooked","FoodMuttonCooked","FoodChickenCooked","FoodRabbitCooked","FoodBaconCooked","FoodGoatCooked","FoodDogCooked","FishCookedTrout","FishCookedSeaBass","FishCookedTuna", // food
	"PartFueltank","PartWheel","PartEngine","PartGlass","PartGeneric","PartVRotor","ItemJerrycan","ItemFuelBarrel","equip_hose", // vehicle parts
	"ItemDesertTent","ItemDomeTent","ItemTent"// tents
];

_tools = ["ItemToolbox","ItemToolbox","ItemKnife","ItemEtool","ItemGPS","Binocular_Vector","NVGoggles_DZE","ItemHatchet","ItemCrowbar","ItemSledge"];

if (random 1 > _spawnChance and !_debug) exitWith {};

_pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["UN Supply Drop Event spawning at %1", _pos];

_lootPos = [_pos,0,(_radius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["UN Supply Drop: creating ammo box at %1", _lootPos];};

_box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

if (random 1 < _vaultChance) then {
	_vault = ["ItemVault","ItemLockbox"] call dz_fn_array_selectRandom;
	_box addMagazineCargoGlobal [_vault,1];
};

for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	_box addMagazineCargoGlobal [_loot,1];
};

for "_i" from 1 to 5 do {
	_tool = _tools call dz_fn_array_selectRandom;
	_box addWeaponCargoGlobal [_tool,1];
};

_pack = DayZ_Backpacks call dz_fn_array_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_type == "Hint") then {
	_img = (getText (configFile >> "CfgVehicles" >> "Mi17_UN_CDF_EP1" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_UNSUPPLY_TITLE","STR_CL_ESE_UNSUPPLY"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_UNSUPPLY"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["U.N. Supply Drop Event setup, waiting for %1 minutes", _timeout];};

_time = diag_tickTime;
_done = false;
_visited = false;
_isNear = true;

while {!_done} do {
	
	_marker = createMarker [ format ["eventMark%1", _time], _pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorBlue";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [(_radius + 50), (_radius + 50)];
	
	if (_nameMarker) then {
		_dot = createMarker [format["eventDot%1",_time],_pos];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "UN Supply Drop";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [format["eventDebug%1",_time],_lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorBlue";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _box <= _distance && !_visited) then {_visited = true};} count playableUnits;
	
		if (_visited) then {
			_vMarker = createMarker [ format ["eventVisit%1", _time], [(_pos select 0), (_pos select 1) + 25]];
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

deleteVehicle _box;

diag_log "EVENT: U.N. Supply Crate Ended";
