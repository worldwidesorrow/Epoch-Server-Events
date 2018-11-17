_cycle = true; // If this is set to true, then the missions will not repeat before all are spawned

if (isNil "Server_Events_Array") then {
	Server_Events_Array = [
		//"animated_crash_spawner",
		"building_supplies",
		"pirate_treasure",
		"special_forces",
		"un_supply",
		"labyrinth",
		"rubble_town",
		"abandoned_vaults"
	];
};

_event = Server_Events_Array call dz_fn_array_selectRandom;

execVM format ["\z\addons\dayz_server\modules\%1.sqf",_event];

if (_cycle) then {
	Server_Events_Array = Server_Events_Array - [_event];
};

if (count Server_Events_Array == 0) then {
	Server_Events_Array = nil;
};