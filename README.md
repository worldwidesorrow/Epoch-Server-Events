# Epoch-Server-Events

- These DayZ Epoch Server events were originally created by ***[Aidem](https://epochmod.com/forum/topic/3779-4-types-of-side-missions-events/)*** , ***[Caveman](https://epochmod.com/forum/topic/36351-new-event-labyrinth/)*** , and ***[Cramps](https://epochmod.com/forum/topic/9660-player-safe-reset-mission/)***
- I have updated them to work with DayZ Epoch 1.0.6+
- Includes the optional visited check mark concept by ***[Payden](https://epochmod.com/forum/topic/44197-crate-visited-marker-for-non-ai-missions/)***

### Installation Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/Epoch-Server-Events/archive/master.zip)*** the green button on the right side of the Github page.
2. This mod is dependent on the Client Side Marker Manager. Download it ***[here](https://github.com/worldwidesorrow/Client-Side-Marker-Manager/)*** and install it according to the instructions.
3. This mod is dependent on the Epoch community stringtable. Download the stringtable ***[here](https://github.com/oiad/communityLocalizations/)*** and place file stringTable.xml in the root of your mission folder.
4. Extract the downloaded folder to your desktop and open it
5. Go to your server pbo and unpack it.
6. Navigate to the new ***dayz_server*** folder and copy the ***modules*** folder into this directory.
7. Open each of the files and make adjustments to the configuration variables at the top to meet your preferences.
8. Save the file and repack your server PBO
9. Unpack your mission PBO
10. Edit ***init.sqf***

	Find this block of code:
	
	```sqf
	EpochEvents = [ //[year,month,day of month, minutes,name of file - .sqf] If minutes is set to -1, the event will run once immediately after server start.
		//["any","any","any","any",-1,"Infected_Camps"], // (negatively impacts FPS)
		["any","any","any","any",-1,"Care_Packages"],
		["any","any","any","any",-1,"CrashSites"]
	];
	```
	
	Option 1: Add entries to spawn random events with the event_init function:
	
	```sqf
	EpochEvents = [ //[year,month,day of month, minutes,name of file - .sqf] If minutes is set to -1, the event will run once immediately after server start.
		//["any","any","any","any",-1,"Infected_Camps"], // (negatively impacts FPS)
		["any","any","any","any",-1,"Care_Packages"],
		["any","any","any","any",-1,"CrashSites"],
		["any","any","any","any",0,"event_init"],
		["any","any","any","any",15,"event_init"],
		["any","any","any","any",30,"event_init"],
		["any","any","any","any",45,"event_init"]
	];
	```
	
	This will spawn a random event every 15 minutes.
	
	Option 2: Add entries to spawn individual events like this:
	
	```sqf
	EpochEvents = [ //[year,month,day of month, minutes,name of file - .sqf] If minutes is set to -1, the event will run once immediately after server start.
		//["any","any","any","any",-1,"Infected_Camps"], // (negatively impacts FPS)
		["any","any","any","any",-1,"Care_Packages"],
		["any","any","any","any",-1,"CrashSites"],
		["any","any","any","any",0,"building_supplies"],
		["any","any","any","any",15,"pirate_treasure"],
		["any","any","any","any",30,"pirate_treasure"],
		["any","any","any","any",45,"un_supply"]
	];
	```
	
	You can edit file event_init.sqf to run only the events that you want.
11. Repack your mission PBO.

Configuration Notes:
At the top of each file you will find a section that looks like this:

  ```sqf
  _spawnChance =  1; // Percentage chance of event happening.The number must be between 0 and 1. 1 = 100% chance.
  _chainsawChance = .25; // Chance that a chainsaw with mixed gas will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
  _vaultChance = .25; // Chance that a safe or lockbox will be added to the crate. The number must be between 0 and 1. 1 = 100% chance.
  _markerRadius = 350; // Radius the loot can spawn and used for the marker.
  _timeout = 20; // Time it takes for the event to time out (in minutes).
  _debug = false; // Diagnostic logs used for troubleshooting.
  _markPosition = true; // Puts a marker exactly were the loot spawns.
  _lootAmount = 15; // This is the number of times a random loot selection is made.
  _messageType = "Hint"; // Type of announcement message. Options "Hint","TitleText". Warning: Hint requires that you have remote_messages.sqf installed.
  _visitMark = true; // Places a "visited" check mark on the mission if a player gets within range of the crate.
  _visitDistance = 20; // Distance in meters from crate before crate is considered "visited"
  _crate = "USVehicleBox"; // Class name of loot crate.
  ```
  
I placed comments behind each of the config variables so that you can understand what they do. Run these events on a test server and make sure that you have them configured how you want them before going to a live server.
