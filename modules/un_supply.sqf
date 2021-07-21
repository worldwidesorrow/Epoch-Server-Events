/*
	Original UN Supply Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Updated for DayZ Epoch 1.0.7+ by JasonTM
	Last update: 06-01-2021
*/

local _spawnChance = 1; // Percentage chance of event happening. The number must be between 0 and 1. 1 = 100% chance.
local _vaultChance = .25; // Percentage chance of safe or lockbox being added to the crate. The number must be between 0 and 1. 1 = 100% chance.
local _radius = 350; // Radius the loot can spawn and used for the marker
local _debug = false; // Diagnostic logs used for troubleshooting.
local _nameMarker = false; // Center marker with the name of the mission.
local _timeout = 3; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
local _markPos = true; // Puts a marker exactly were the loot spawns.
local _lootAmount = 50; // This is the number of times a random loot selection is made.
local _type = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
local _visitMark = false; // Places a "visited" check mark on the mission if a player gets within range of the crate.
local _distance = 20; // Distance from crate before crate is considered "visited"
local _crate = "DZ_AmmoBoxBigUS"; // Class name of loot crate.
#define TITLE_COLOR "#0D00FF" // Hint Option: Color of Top Line
#define TITLE_SIZE "1.75" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image

local _bloodbag = ["bloodBagONEG","ItemBloodbag"] select dayz_classicBloodBagSystem;

local _lootList = [
	"ItemAntibiotic3","ItemEpinephrine","ItemHeatPack","ItemMorphine","ItemBandage","ItemAntibacterialWipe","ItemPainkiller6","ItemSepsisBandage","equip_woodensplint","ItemKiloHemp",_bloodbag, // meds
	"FoodCanBakedBeans","FoodCanFrankBeans","FoodCanPasta","FoodCanSardines","FoodCanBeef","FoodCanPotatoes","FoodCanGriff","FoodCanBadguy","FoodCanBoneboy","FoodCanCorn","FoodCanCurgon","FoodCanDemon","FoodCanFraggleos","FoodCanHerpy","FoodCanDerpy","FoodCanOrlok","FoodCanPowell","FoodCanTylers","FoodCanUnlabeled","FoodCanRusUnlabeled","FoodCanRusStew","FoodCanRusPork","FoodCanRusPeas","FoodCanRusMilk","FoodCanRusCorn","FoodChipsSulahoops","FoodChipsMysticales","FoodChipsChocolate","FoodCandyChubby","FoodCandyAnders","FoodCandyLegacys","FoodCakeCremeCakeClean","FoodCandyMintception","FoodPistachio","FoodNutmix","FoodMRE","FoodbaconCooked","FoodbeefCooked","FoodchickenCooked","FoodGoatCooked","FoodmuttonCooked","FoodrabbitCooked","FishCookedTrout","FishCookedSeaBass","FishCookedTuna", // food
	"ItemSodaCoke","ItemSodaPepsi","ItemSodaMdew","ItemSodaMtngreen","ItemSodaR4z0r","ItemSodaClays","ItemSodaSmasht","ItemSodaDrwaste","ItemSodaFranka","ItemSodaLemonade","ItemSodaLirik","ItemSodaLvg","ItemSodaMzly","ItemSodaPeppsy","ItemSodaRabbit","ItemSodaSacrite","ItemSodaRocketFuel","ItemSodaGrapeDrink","ItemSherbet","ItemSodaRbull","ItemSodaOrangeSherbet","ItemWaterbottle","ItemWaterBottleSafe","ItemWaterBottleBoiled","ItemWaterBottleHerbal","ItemPlasticWaterBottleSafe","ItemPlasticWaterBottleBoiled","ItemPlasticWaterBottleHerbal", // drink
	"PartFueltank","PartWheel","PartEngine","PartGlass","PartGeneric","PartVRotor","ItemJerrycan","ItemFuelBarrel","equip_hose", // vehicle parts
	"ItemCanvas","ItemTent","ItemTentWinter","ItemDomeTent","ItemWinterDomeTent","ItemDesertTent","equip_floppywire","equip_scrapelectronics","equip_rope","equip_tent_poles" // tents and stuff
];

local _tools = ["ItemToolbox","ItemToolbox","ItemKnife","ItemEtool","ItemGPS","Binocular_Vector","NVGoggles_DZE","ItemHatchet","ItemCrowbar","ItemSledge"];

if (random 1 > _spawnChance and !_debug) exitWith {};

local _pos = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,.3,0] call BIS_fnc_findSafePos;

diag_log format["UN Supply Drop Event spawning at %1", _pos];

local _lootPos = [_pos,0,(_radius * .75),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["UN Supply Drop: creating ammo box at %1", _lootPos];};

local _box = _crate createVehicle [0,0,0];
_box setPos _lootPos;
clearMagazineCargoGlobal _box;
clearWeaponCargoGlobal _box;

if (random 1 < _vaultChance) then {
	local _vault = ["ItemVault","ItemLockbox"] call BIS_fnc_selectRandom;
	_box addMagazineCargoGlobal [_vault,1];
};

for "_i" from 1 to _lootAmount do {
	local _loot = _lootList call BIS_fnc_selectRandom;
	_box addMagazineCargoGlobal [_loot,1];
};

for "_i" from 1 to 5 do {
	local _tool = _tools call BIS_fnc_selectRandom;
	_box addWeaponCargoGlobal [_tool,1];
};

local _pack = ["Patrol_Pack_DZE1","Assault_Pack_DZE1","Czech_Vest_Pouch_DZE1","TerminalPack_DZE1","TinyPack_DZE1","ALICE_Pack_DZE1","TK_Assault_Pack_DZE1","CompactPack_DZE1","British_ACU_DZE1","GunBag_DZE1","NightPack_DZE1","SurvivorPack_DZE1","AirwavesPack_DZE1","CzechBackpack_DZE1","WandererBackpack_DZE1","LegendBackpack_DZE1","CoyoteBackpack_DZE1","LargeGunBag_DZE1"] call BIS_fnc_selectRandom;
_box addBackpackCargoGlobal [_pack,1];

if (_type == "Hint") then {
	local _img = (getText (configFile >> "CfgVehicles" >> "Mi17_UN_CDF_EP1" >> "picture"));
	RemoteMessage = ["hintWithImage",["STR_CL_ESE_UNSUPPLY_TITLE","STR_CL_ESE_UNSUPPLY"],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText","STR_CL_ESE_UNSUPPLY"];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["U.N. Supply Drop Event setup, waiting for %1 minutes", _timeout];};

local _time = diag_tickTime;
local _done = false;
local _visited = false;
local _isNear = true;
local _markers = [1,1,1,1];

//[position,createMarker,setMarkerColor,setMarkerType,setMarkerShape,setMarkerBrush,setMarkerSize,setMarkerText,setMarkerAlpha]
_markers set [0, [_pos, format ["eventMark%1", _time], "ColorBlue", "","ELLIPSE", "", [_radius, _radius], [], 0.5]];
if (_nameMarker) then {_markers set [1, [_pos, format ["eventDot%1",_time], "ColorBlack", "mil_dot","ICON", "", [], ["STR_CL_ESE_UNSUPPLY_TITLE"], 0]];};
if (_markPos) then {_markers set [2, [_lootPos, format ["eventDebug%1",_time], "ColorBlue", "mil_dot","ICON", "", [], [], 0]];};
DZE_ServerMarkerArray set [count DZE_ServerMarkerArray, _markers]; // Markers added to global array for JIP player requests.
local _markerIndex = count DZE_ServerMarkerArray - 1;
PVDZ_ServerMarkerSend = ["start",_markers];
publicVariable "PVDZ_ServerMarkerSend";

while {!_done} do {
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
			_done = true;
		};
	};
};

while {_isNear} do {
	{if (isPlayer _x && _x distance _box >= _distance) exitWith {_isNear = false};} count playableUnits;
};

deleteVehicle _box;
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

diag_log "EVENT: U.N. Supply Crate Ended";
