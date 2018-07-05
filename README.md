# Epoch-Server-Events

- These DayZ Epoch Server events were originally created by ***[Aidem](https://epochmod.com/forum/topic/3779-4-types-of-side-missions-events/)***
- I have updated them to work with DayZ Epoch 1.0.6+
- Includes the optional visited check mark concept by ***[Payden](https://epochmod.com/forum/topic/44197-crate-visited-marker-for-non-ai-missions/)***

### Installation Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/Epoch-Server-Events/archive/master.zip)*** the green button on the right side of the Github page.
2. Extract the downloaded folder to your desktop and open it
3. Go to your server pbo and unpack it.
4. Navigate to the new ***dayz_server*** folder and copy the ***modules*** folder into this directory.
5. Open each of the files and make adjustments to the configuration variables at the top to meet your preferences.
6. Save the file and repack your server PBO

7. Unpack your mission PBO

8. Edit ***init.sqf*** with notepad++

	Find:

	```sqf
	waitUntil {scriptDone progress_monitor};	
	```
	
	And add the following line ***above*** it: 
	
	```sqf
	[] execVM "dayz_code\compile\remote_message.sqf";
	```
	If you already have ZSC or WAI installed then just verify that this line is already there.

	Find this line:
	
	```sqf
	EpochUseEvents = false;
	```
	
	Change it to true, if not already:
	
	```sqf
	EpochUseEvents = true;
	```
	
	Find this line right below:
	
	```sqf
	EpochEvents = [["any","any","any","any",30,"crash_spawner"],["any","any","any","any",0,"crash_spawner"],["any","any","any","any",15,"supply_drop"]];
	```
	
	Replace it with this, if you have other events already, then just work these in:
	
	```sqf
	EpochEvents = [["any","any","any","any",0,"building_supplies"],["any","any","any","any",15,"pirate_treasure"],["any","any","any","any",30,"special_forces"],["any","any","any","any",45,"un_supply"]];
	```
	
9. Copy the dayz_code folder over to your mission folder.
10. Repack your mission folder into a PBO.

Configuration Notes:
1. At the top of each file you will find a section that looks like this:

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
