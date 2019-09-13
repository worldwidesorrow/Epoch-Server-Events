/*
	Original Rubble Town Event by Caveman
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 11-15-2018
*/

private ["_spawnChance","_chainsawChance","_radius","_debug","_nameMarker","_timeout","_markPos","_lootAmount","_messageType","_visitMark","_wepAmount","_lootPos","_runover","_type",
"_visitDistance","_crate","_weapons","_lootList","_position","_box","_attachments","_attachment","_bloodbag","_posarray","_spawnObjects","_clutter","_saw",
"_time","_marker","_pMarker","_vMarker","_dot","_finished","_visited","_isNear","_magazine","_ammoArray","_weapon","_attach","_cfg","_loot","_backpack"];

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_chainsawChance = .5; // Chance that a chainsaw with mixed gas will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_radius = 200; // Radius the loot can spawn and used for the marker
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_debug = false; // Diagnostic logs used for troubleshooting.
_nameMarker = true; // Center marker with the name of the mission.
_markPos = false; // Puts a marker exactly where the loot spawns.
_lootAmount = 30; // This is the number of times a random loot selection is made.
_wepAmount = 4; // This is the number of times a random weapon selection is made.
_messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_visitDistance = 20; // Distance from crate before crate is considered "visited"
_crate = "GuerillaCacheBox";
#define TITLE_COLOR "#ff9933" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line

_bloodbag = if(dayz_classicBloodBagSystem) then {"ItemBloodbag";} else {"bloodBagONEG";};

_lootList = [
	_bloodbag,"ItemBandage","ItemAntibiotic","ItemEpinephrine","ItemMorphine","ItemPainkiller","ItemAntibacterialWipe","ItemHeatPack","ItemKiloHemp", // meds
	"Skin_Camo1_DZ","Skin_CZ_Soldier_Sniper_EP1_DZ","Skin_CZ_Special_Forces_GL_DES_EP1_DZ","Skin_Drake_Light_DZ","Skin_FR_OHara_DZ","Skin_FR_Rodriguez_DZ","Skin_Graves_Light_DZ","Skin_Sniper1_DZ","Skin_Soldier1_DZ","Skin_Soldier_Bodyguard_AA12_PMC_DZ", // skins
	"ItemSodaSmasht","ItemSodaClays","ItemSodaR4z0r","ItemSodaPepsi","ItemSodaCoke","FoodCanBakedBeans","FoodCanPasta","FoodCanSardines","FoodMRE","ItemWaterBottleBoiled","ItemSodaRbull","FoodBeefCooked","FoodMuttonCooked","FoodChickenCooked","FoodRabbitCooked","FoodBaconCooked","FoodGoatCooked","FoodDogCooked","FishCookedTrout","FishCookedSeaBass","FishCookedTuna", // food
	"PartFueltank","PartWheel","PartEngine","PartGlass","PartGeneric","PartVRotor","ItemJerrycan","ItemFuelBarrel","equip_hose", // vehicle parts
	"ItemDesertTent","ItemDomeTent","ItemTent"// tents
];

_weapons = ["SCAR_L_CQC","SCAR_L_CQC_Holo","SCAR_L_STD_Mk4CQT","SCAR_L_STD_EGLM_RCO","SCAR_L_CQC_EGLM_Holo","SCAR_L_STD_HOLO","SCAR_L_CQC_CCO_SD","SCAR_H_CQC_CCO","SCAR_H_CQC_CCO_SD","SCAR_H_STD_EGLM_Spect","SCAR_H_LNG_Sniper","SCAR_H_LNG_Sniper_SD","M4SPR_DZE","VSS_vintorez_DZE","AKM_DZ","AKM_Kobra_DZ","AKM_PSO1_DZ","RPK_DZ","RPK_Kobra_DZ","RPK_PSO1_DZ","DMR_DZ","DMR_Gh_DZ","FNFAL_DZ","FNFAL_CCO_DZ","FNFAL_Holo_DZ","FNFAL_ANPVS4_DZ","FN_FAL_ANPVS4_DZE","G36K_Camo_DZ","G36K_Camo_SD_DZ","G36A_Camo_DZ","G36C_DZ","G36C_SD_DZ","G36C_CCO_DZ","G36C_CCO_SD_DZ","G36C_Holo_DZ","G36C_Holo_SD_DZ","G36C_ACOG_DZ","G36C_ACOG_SD_DZ","M4A1_DZ","M4A1_FL_DZ","M4A1_MFL_DZ","M4A1_SD_DZ","M4A1_SD_FL_DZ","M4A1_SD_MFL_DZ","M4A1_GL_DZ","M4A1_GL_FL_DZ","M4A1_GL_MFL_DZ","M4A1_GL_SD_DZ","M4A1_GL_SD_FL_DZ","M4A1_GL_SD_MFL_DZ","M4A1_CCO_DZ","M4A1_CCO_FL_DZ","M4A1_CCO_MFL_DZ","M4A1_CCO_SD_DZ","M4A1_CCO_SD_FL_DZ","M4A1_CCO_SD_MFL_DZ","M4A1_GL_CCO_DZ","M4A1_GL_CCO_FL_DZ","M4A1_GL_CCO_MFL_DZ","M4A1_GL_CCO_SD_DZ","M4A1_GL_CCO_SD_FL_DZ","M4A1_GL_CCO_SD_MFL_DZ","M4A1_Holo_DZ","M4A1_Holo_FL_DZ","M4A1_Holo_MFL_DZ","M4A1_Holo_SD_DZ","M4A1_Holo_SD_FL_DZ","M4A1_Holo_SD_MFL_DZ","M4A1_GL_Holo_DZ","M4A1_GL_Holo_FL_DZ","M4A1_GL_Holo_MFL_DZ","M4A1_GL_Holo_SD_DZ","M4A1_GL_Holo_SD_FL_DZ","M4A1_GL_Holo_SD_MFL_DZ","M4A1_ACOG_DZ","M4A1_ACOG_FL_DZ","M4A1_ACOG_MFL_DZ","M4A1_ACOG_SD_DZ","M4A1_ACOG_SD_FL_DZ","M4A1_ACOG_SD_MFL_DZ","M4A1_GL_ACOG_DZ","M4A1_GL_ACOG_FL_DZ","M4A1_GL_ACOG_MFL_DZ","M4A1_GL_ACOG_SD_DZ","M4A1_GL_ACOG_SD_FL_DZ","M4A1_GL_ACOG_SD_MFL_DZ","M14_DZ","M14_Gh_DZ","M14_CCO_DZ","M14_CCO_Gh_DZ","M14_Holo_DZ","M14_Holo_Gh_DZ","M24_DZ","M24_Gh_DZ","M40A3_Gh_DZ","M40A3_DZ","M249_CCO_DZ","M249_DZ","M249_Holo_DZ","M249_EP1_DZ","M249_m145_EP1_DZE","L110A1_CCO_DZ","L110A1_Holo_DZ","L110A1_DZ","BAF_L110A1_Aim_DZE","M240_DZ","M240_CCO_DZ","M240_Holo_DZ","m240_scoped_EP1_DZE","M60A4_EP1_DZE","M1014_DZ","M1014_CCO_DZ","M1014_Holo_DZ","Mk48_CCO_DZ","Mk48_DZ","Mk48_Holo_DZ","PKM_DZ","Pecheneg_DZ","UK59_DZ","SVD_PSO1_DZ","SVD_PSO1_Gh_DZ","SVD_DZ","SVD_Gh_DZ","Mosin_DZ","Mosin_BR_DZ","Mosin_FL_DZ","Mosin_MFL_DZ","Mosin_Belt_DZ","Mosin_Belt_FL_DZ","Mosin_Belt_MFL_DZ","Mosin_PU_DZ","Mosin_PU_FL_DZ","Mosin_PU_MFL_DZ","Mosin_PU_Belt_DZ","Mosin_PU_Belt_FL_DZ","Mosin_PU_Belt_MFL_DZ","MP5_DZ","MP5_SD_DZ","M16A2_DZ","M16A2_GL_DZ","M16A4_DZ","M16A4_FL_DZ","M16A4_MFL_DZ","M16A4_GL_DZ","M16A4_GL_FL_DZ","M16A4_GL_MFL_DZ","M16A4_CCO_DZ","M16A4_CCO_FL_DZ","M16A4_CCO_MFL_DZ","M16A4_GL_CCO_DZ","M16A4_GL_CCO_FL_DZ","M16A4_GL_CCO_MFL_DZ","M16A4_Holo_DZ","M16A4_Holo_FL_DZ","M16A4_Holo_MFL_DZ","M16A4_GL_Holo_DZ","M16A4_GL_Holo_FL_DZ","M16A4_GL_Holo_MFL_DZ","M16A4_ACOG_DZ","M16A4_ACOG_FL_DZ","M16A4_ACOG_MFL_DZ","M16A4_GL_ACOG_DZ","M16A4_GL_ACOG_FL_DZ","M16A4_GL_ACOG_MFL_DZ","SA58_DZ","SA58_RIS_DZ","SA58_RIS_FL_DZ","SA58_RIS_MFL_DZ","SA58_CCO_DZ","SA58_CCO_FL_DZ","SA58_CCO_MFL_DZ","SA58_Holo_DZ","SA58_Holo_FL_DZ","SA58_Holo_MFL_DZ","SA58_ACOG_DZ","SA58_ACOG_FL_DZ","SA58_ACOG_MFL_DZ","L85A2_DZ","L85A2_FL_DZ","L85A2_MFL_DZ","L85A2_SD_DZ","L85A2_SD_FL_DZ","L85A2_SD_MFL_DZ","L85A2_CCO_DZ","L85A2_CCO_FL_DZ","L85A2_CCO_MFL_DZ","L85A2_CCO_SD_DZ","L85A2_CCO_SD_FL_DZ","L85A2_CCO_SD_MFL_DZ","L85A2_Holo_DZ","L85A2_Holo_FL_DZ","L85A2_Holo_MFL_DZ","L85A2_Holo_SD_DZ","L85A2_Holo_SD_FL_DZ","L85A2_Holo_SD_MFL_DZ","L85A2_ACOG_DZ","L85A2_ACOG_FL_DZ","L85A2_ACOG_MFL_DZ","L85A2_ACOG_SD_DZ","L85A2_ACOG_SD_FL_DZ","L85A2_ACOG_SD_MFL_DZ","Bizon_DZ","Bizon_SD_DZ","CZ550_DZ","LeeEnfield_DZ","MR43_DZ","Winchester1866_DZ","Remington870_DZ","Remington870_FL_DZ","Remington870_MFL_DZ","L115A3_DZ","L115A3_2_DZ"];

if (random 1 > _spawnChance and !_debug) exitWith {};

_position = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.2,0] call BIS_fnc_findSafePos;

diag_log format["Rubble Town Event Spawning At %1", _position];

_posarray = [
	[(_position select 0) - 39.8, (_position select 1) + 11],
	[(_position select 0) - 47.7, (_position select 1) + 37.8],
	[(_position select 0) - 24.3, (_position select 1) + 38.2],
	[(_position select 0) - 6.6, (_position select 1) + 42.7],
	[(_position select 0) - 16.5, (_position select 1) - 6.5],
	[(_position select 0) - 56.8, (_position select 1) + 30.3],
	[(_position select 0) - 23.3, (_position select 1) + 22.5],
	[(_position select 0) + 1, (_position select 1) + 20.7],
	[(_position select 0) - 21.7, (_position select 1) + 6.7],
	[(_position select 0) - 8.7, (_position select 1) + 29.6],
	[(_position select 0) + 9.3, (_position select 1) + 9.4]
];

_spawnObjects = {
	private ["_objArray","_offset","_position","_obj","_objects","_type","_pos"];

	_objects = _this select 0;
	_pos = _this select 1;
	_objArray = [];

	{
		_type = _x select 0;
		_offset = _x select 1;
		_position = [(_pos select 0) + (_offset select 0), (_pos select 1) + (_offset select 1), 0];
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

if (_debug) then {diag_log format["Rubble Town Event: creating ammo box at %1", _lootPos];};

_box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

_clutter = createVehicle ["ClutterCutter_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
_clutter setPos _lootPos;

_runover = [[
	["MAP_HouseBlock_B2_ruins",[0,0]],
	["MAP_rubble_rocks_01",[-37,-5.8]],
	["MAP_HouseBlock_A1_1_ruins",[-52,13]],
	["MAP_rubble_bricks_02",[-22.5,-7.2]],
	["MAP_rubble_bricks_03",[-22.8,2.8]],
	["MAP_rubble_bricks_04",[-32.7,27.6]],
	["MAP_HouseV_2L_ruins",[-21.3,14.6]],
	["MAP_HouseBlock_B3_ruins",[-12.8,-15.7]],
	["MAP_A_MunicipalOffice_ruins",[26,-1.6]],
	["MAP_HouseBlock_A2_ruins",[-67.3,36.3]],
	["MAP_Ind_Stack_Big_ruins",[15,43.3]],
	["MAP_Nasypka_ruins",[-24,26.7]],
	["MAP_R_HouseV_2L",[-8.2,22.7]],
	["MAP_ruin_01",[.6,41.5]],
	["MAP_ruin_01",[-36.7,35.7]],
	["HMMWVWreck",[-14.4,-7.3]],
	["T72Wreck",[6,-9.7]],
	["UralWreck",[-31.3,36.6],-19.75],
	["UralWreck",[-37,11]],
	["UralWreck",[3.7,20.4],35.5],
	["UH60_ARMY_Wreck_DZ",[-21.7,38.3]]
],_position] call _spawnObjects;

if (random 1 < _chainsawChance) then {
	_saw = ["ChainSaw","ChainSawB","ChainSawG","ChainSawP","ChainSawR"] call dz_fn_array_selectRandom;
	_box addWeaponCargoGlobal [_saw,1];
	_box addMagazineCargoGlobal ["ItemJerryMixed",2];
};

for "_i" from 1 to _lootAmount do {
	_loot = _lootList call dz_fn_array_selectRandom;
	_box addMagazineCargoGlobal [_loot,1];
};

for "_i" from 1 to _wepAmount do {

	_weapon = _weapons call dz_fn_array_selectRandom;
	_box addWeaponCargoGlobal [_weapon,1];
	
	_ammoArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
	if (count _ammoArray > 0) then {
		_magazine = _ammoArray select 0;
		_box addMagazineCargoGlobal [_magazine, (3 + round(random 2))];
	};
	
	_cfg = configFile >> "CfgWeapons" >> _weapon >> "Attachments";
	if (isClass _cfg && count _cfg > 0) then {
		_attach = configName (_cfg call dz_fn_array_selectRandom);
		_box addMagazineCargoGlobal [_attach,1];
	};
};

_backpack = DayZ_Backpacks call dz_fn_array_selectRandom;
_box addBackpackCargoGlobal [_backpack,1];

if (_messageType == "Hint") then {
	RemoteMessage = ["hintNoImage",["STR_CL_ESE_RUBBLETOWN_TITLE","STR_CL_ESE_RUBBLETOWN"],[TITLE_COLOR,TITLE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_RUBBLETOWN"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Rubble Town Event setup, waiting for %1 minutes", _timeout];};

_time = diag_tickTime;
_finished = false;
_visited = false;
_isNear = true;

while {!_finished} do {
	_marker = createMarker [ format ["eventMarker%1", _time], _position];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorOrange";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [(_radius + 50), (_radius + 50)];
	
	if (_nameMarker) then {
		_dot = createMarker [format["eventDot%1",_time],_position];
		_dot setMarkerShape "ICON";
		_dot setMarkerType "mil_dot";
		_dot setMarkerColor "ColorBlack";
		_dot setMarkerText "Rubble Town";
	};
	
	if (_markPos) then {
		_pMarker = createMarker [ format ["eventPos%1", _time], _lootPos];
		_pMarker setMarkerShape "ICON";
		_pMarker setMarkerType "mil_dot";
		_pMarker setMarkerColor "ColorOrange";
	};
	
	if (_visitMark) then {
		{if (isPlayer _x && _x distance _box <= _visitDistance && !_visited) then {_visited = true};} count playableUnits;
	
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
	{if (isPlayer _x && _x distance _box >= _visitDistance) then {_isNear = false};} count playableUnits;
};

deleteVehicle _box;
deleteVehicle _clutter;

{
	deleteVehicle _x;
} forEach _runover;

diag_log "Rubble Town Event Ended";
