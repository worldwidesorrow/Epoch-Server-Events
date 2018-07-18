/*
	Original Military "Special Forces" Event by Aidem
	Original "crate visited" marker concept and code by Payden
	Rewritten and updated for DayZ Epoch 1.0.6+ by JasonTM
	Last update: 7-3-2018
*/

_spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
_hpSniperChance = .25; // Chance that an as50, KSVK, m107, or Anzio 20 will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
_markerRadius = 350; // Radius the loot can spawn and used for the marker
_timeout = 20; // Time it takes for the event to time out (in minutes). To disable timeout set to -1.
_debug = false; // Puts a marker exactly were the loot spawns
_nameMarker = false; // Center marker with the name of the mission.
_markPosition = false; // Puts a marker exactly were the loot spawns.
_lootAmount = 10; // This is the number of times a random loot selection is made.
_messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the crate.
_visitDistance = 20; // Distance from crate before crate is considered "visited"
_crate = "USVehicleBox";
_weapons = ["SCAR_L_CQC","SCAR_L_CQC_Holo","SCAR_L_STD_Mk4CQT","SCAR_L_STD_EGLM_RCO","SCAR_L_CQC_EGLM_Holo","SCAR_L_STD_HOLO","SCAR_L_CQC_CCO_SD","SCAR_H_CQC_CCO","SCAR_H_CQC_CCO_SD","SCAR_H_STD_EGLM_Spect","SCAR_H_LNG_Sniper","SCAR_H_LNG_Sniper_SD","M4SPR_DZE","VSS_vintorez_DZE","AKM_DZ","AKM_Kobra_DZ","AKM_PSO1_DZ","RPK_DZ","RPK_Kobra_DZ","RPK_PSO1_DZ","DMR_DZ","DMR_Gh_DZ","FNFAL_DZ","FNFAL_CCO_DZ","FNFAL_Holo_DZ","FNFAL_ANPVS4_DZ","FN_FAL_ANPVS4_DZE","G36K_Camo_DZ","G36K_Camo_SD_DZ","G36A_Camo_DZ","G36C_DZ","G36C_SD_DZ","G36C_CCO_DZ","G36C_CCO_SD_DZ","G36C_Holo_DZ","G36C_Holo_SD_DZ","G36C_ACOG_DZ","G36C_ACOG_SD_DZ","M4A1_DZ","M4A1_FL_DZ","M4A1_MFL_DZ","M4A1_SD_DZ","M4A1_SD_FL_DZ","M4A1_SD_MFL_DZ","M4A1_GL_DZ","M4A1_GL_FL_DZ","M4A1_GL_MFL_DZ","M4A1_GL_SD_DZ","M4A1_GL_SD_FL_DZ","M4A1_GL_SD_MFL_DZ","M4A1_CCO_DZ","M4A1_CCO_FL_DZ","M4A1_CCO_MFL_DZ","M4A1_CCO_SD_DZ","M4A1_CCO_SD_FL_DZ","M4A1_CCO_SD_MFL_DZ","M4A1_GL_CCO_DZ","M4A1_GL_CCO_FL_DZ","M4A1_GL_CCO_MFL_DZ","M4A1_GL_CCO_SD_DZ","M4A1_GL_CCO_SD_FL_DZ","M4A1_GL_CCO_SD_MFL_DZ","M4A1_Holo_DZ","M4A1_Holo_FL_DZ","M4A1_Holo_MFL_DZ","M4A1_Holo_SD_DZ","M4A1_Holo_SD_FL_DZ","M4A1_Holo_SD_MFL_DZ","M4A1_GL_Holo_DZ","M4A1_GL_Holo_FL_DZ","M4A1_GL_Holo_MFL_DZ","M4A1_GL_Holo_SD_DZ","M4A1_GL_Holo_SD_FL_DZ","M4A1_GL_Holo_SD_MFL_DZ","M4A1_ACOG_DZ","M4A1_ACOG_FL_DZ","M4A1_ACOG_MFL_DZ","M4A1_ACOG_SD_DZ","M4A1_ACOG_SD_FL_DZ","M4A1_ACOG_SD_MFL_DZ","M4A1_GL_ACOG_DZ","M4A1_GL_ACOG_FL_DZ","M4A1_GL_ACOG_MFL_DZ","M4A1_GL_ACOG_SD_DZ","M4A1_GL_ACOG_SD_FL_DZ","M4A1_GL_ACOG_SD_MFL_DZ","M14_DZ","M14_Gh_DZ","M14_CCO_DZ","M14_CCO_Gh_DZ","M14_Holo_DZ","M14_Holo_Gh_DZ","M24_DZ","M24_Gh_DZ","M40A3_Gh_DZ","M40A3_DZ","M249_CCO_DZ","M249_DZ","M249_Holo_DZ","M249_EP1_DZ","M249_m145_EP1_DZE","L110A1_CCO_DZ","L110A1_Holo_DZ","L110A1_DZ","BAF_L110A1_Aim_DZE","M240_DZ","M240_CCO_DZ","M240_Holo_DZ","m240_scoped_EP1_DZE","M60A4_EP1_DZE","M1014_DZ","M1014_CCO_DZ","M1014_Holo_DZ","Mk48_CCO_DZ","Mk48_DZ","Mk48_Holo_DZ","PKM_DZ","Pecheneg_DZ","UK59_DZ","SVD_PSO1_DZ","SVD_PSO1_Gh_DZ","SVD_DZ","SVD_Gh_DZ","Mosin_DZ","Mosin_BR_DZ","Mosin_FL_DZ","Mosin_MFL_DZ","Mosin_Belt_DZ","Mosin_Belt_FL_DZ","Mosin_Belt_MFL_DZ","Mosin_PU_DZ","Mosin_PU_FL_DZ","Mosin_PU_MFL_DZ","Mosin_PU_Belt_DZ","Mosin_PU_Belt_FL_DZ","Mosin_PU_Belt_MFL_DZ","MP5_DZ","MP5_SD_DZ","M16A2_DZ","M16A2_GL_DZ","M16A4_DZ","M16A4_FL_DZ","M16A4_MFL_DZ","M16A4_GL_DZ","M16A4_GL_FL_DZ","M16A4_GL_MFL_DZ","M16A4_CCO_DZ","M16A4_CCO_FL_DZ","M16A4_CCO_MFL_DZ","M16A4_GL_CCO_DZ","M16A4_GL_CCO_FL_DZ","M16A4_GL_CCO_MFL_DZ","M16A4_Holo_DZ","M16A4_Holo_FL_DZ","M16A4_Holo_MFL_DZ","M16A4_GL_Holo_DZ","M16A4_GL_Holo_FL_DZ","M16A4_GL_Holo_MFL_DZ","M16A4_ACOG_DZ","M16A4_ACOG_FL_DZ","M16A4_ACOG_MFL_DZ","M16A4_GL_ACOG_DZ","M16A4_GL_ACOG_FL_DZ","M16A4_GL_ACOG_MFL_DZ","SA58_DZ","SA58_RIS_DZ","SA58_RIS_FL_DZ","SA58_RIS_MFL_DZ","SA58_CCO_DZ","SA58_CCO_FL_DZ","SA58_CCO_MFL_DZ","SA58_Holo_DZ","SA58_Holo_FL_DZ","SA58_Holo_MFL_DZ","SA58_ACOG_DZ","SA58_ACOG_FL_DZ","SA58_ACOG_MFL_DZ","L85A2_DZ","L85A2_FL_DZ","L85A2_MFL_DZ","L85A2_SD_DZ","L85A2_SD_FL_DZ","L85A2_SD_MFL_DZ","L85A2_CCO_DZ","L85A2_CCO_FL_DZ","L85A2_CCO_MFL_DZ","L85A2_CCO_SD_DZ","L85A2_CCO_SD_FL_DZ","L85A2_CCO_SD_MFL_DZ","L85A2_Holo_DZ","L85A2_Holo_FL_DZ","L85A2_Holo_MFL_DZ","L85A2_Holo_SD_DZ","L85A2_Holo_SD_FL_DZ","L85A2_Holo_SD_MFL_DZ","L85A2_ACOG_DZ","L85A2_ACOG_FL_DZ","L85A2_ACOG_MFL_DZ","L85A2_ACOG_SD_DZ","L85A2_ACOG_SD_FL_DZ","L85A2_ACOG_SD_MFL_DZ","Bizon_DZ","Bizon_SD_DZ","CZ550_DZ","LeeEnfield_DZ","MR43_DZ","Winchester1866_DZ","Remington870_DZ","Remington870_FL_DZ","Remington870_MFL_DZ","L115A3_DZ","L115A3_2_DZ"];
_hpSnipers = ["Anzio_20_DZ","BAF_AS50_scoped_DZ","m107_DZ","KSVK_DZE"];

// Random chance of event happening
_spawnRoll = random 1;
if (_spawnRoll > _spawnChance and !_debug) exitWith {};

// Random location
_position = [getMarkerPos "center",0,(((getMarkerSize "center") select 1)*0.75),10,0,2000,0] call BIS_fnc_findSafePos;

diag_log format["Special Forces Event spawning at %1", _position];

_lootPos = [_position,0,(_markerRadius - 100),10,0,2000,0] call BIS_fnc_findSafePos;

if (_debug) then {diag_log format["Special Forces Event: creating ammo box at %1", _lootPos];};

// Create ammo box
_lootBox = createVehicle [_crate,_lootPos,[], 0, "NONE"];
clearMagazineCargoGlobal _lootBox;
clearWeaponCargoGlobal _lootBox;

// Chance for a high power sniper
if (_spawnRoll < _hpSniperChance) then {
	_weapon = _hpSnipers call dz_fn_array_selectRandom;
	_lootBox addWeaponCargoGlobal [_weapon,1];
	
	_ammoArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
	if (count _ammoArray > 0) then {
		_magazine = _ammoArray select 0;
		_lootBox addMagazineCargoGlobal [_magazine, (3 + round(random 2))];
	};
};

// Add weapons, magazines, and attachments
for "_i" from 1 to _lootAmount do {

	_weapon = _weapons call dz_fn_array_selectRandom;
	_lootBox addWeaponCargoGlobal [_weapon,1];
	
	_ammoArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
	if (count _ammoArray > 0) then {
		_magazine = _ammoArray select 0;
		_lootBox addMagazineCargoGlobal [_magazine, (3 + floor(random 3))];
	};
	
	_config = configFile >> "CfgWeapons" >> _weapon >> "Attachments";
	if (isClass _config && (count _config) > 0) then {
		_attachments = [];
		for "_i" from 0 to (count _config)-1 do {
			_attach = _config select _i;
			_type = configName _attach;
			_attachments set [count _attachments,_type];
		};
		_attachment = _attachments call dz_fn_array_selectRandom;
		_lootBox addMagazineCargoGlobal [_attachment,1];
	};
};

// Add backpack
_backpack = DayZ_Backpacks call dz_fn_array_selectRandom;
_lootBox addBackpackCargoGlobal [_backpack,1];

if (_messageType == "Hint") then {
	_image = getText (configFile >> "CfgWeapons" >> "UK59_DZ" >> "picture");
	_hint = "STR_CL_ESE_MILITARY_HINT";
	RemoteMessage = ["hint", _hint, [_image]];
} else {
	_message = "STR_CL_ESE_MILITARY";
	RemoteMessage = ["titleText",_message];
};
publicVariable "RemoteMessage";

if (_debug) then {diag_log format["Special Forces Event setup, waiting for %1 minutes", _timeout];};

_startTime = diag_tickTime;
_eventMarker = "";
_crateMarker = "";
_visitMarker = "";
_textMarker = "";
_finished = false;
_visitedCrate = false;
_playerNear = true;

while {!_finished} do {
	_eventMarker = createMarker [ format ["loot_eventMarker_%1", _startTime], _position];
	_eventMarker setMarkerShape "ELLIPSE";
	_eventMarker setMarkerColor "ColorRed";
	_eventMarker setMarkerAlpha 0.5;
	_eventMarker setMarkerSize [(_markerRadius + 50), (_markerRadius + 50)];
	
	if (_nameMarker) then {
		_textMarker = createMarker [format["loot_text_marker_%1",_startTime],_position];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_dot";
		_textMarker setMarkerColor "ColorBlack";
		_textMarker setMarkerText "Special Forces Supply";
	};
	
	if (_markPosition) then {
		_crateMarker = createMarker [ format ["loot_event_crateMarker_%1", _startTime], _lootPos];
		_crateMarker setMarkerShape "ICON";
		_crateMarker setMarkerType "mil_dot";
		_crateMarker setMarkerColor "ColorRed";
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

if (_debug) then {diag_log "Special Forces Event Ended";};
