# Framework module structure

All files are in standard format:
```lua
local ThisModule = {}
 
return ThisModule
```

To handle the framework's files being in potentially unexpected module paths, your application should create the 
variable `ENV_RFF_PATH` before using `require` on any framework modules.

```lua
if not ENV_RFF_PATH then 
    ENV_RFF_PATH = "./rff/"
end

local RFF = require(ENV_RFF_PATH .. "init")
```
 
There is 2 ways of accessing the modules:
```lua
-- importing the main module, and using sub-module table structure
local RFF = require(ENV_RFF_PATH .. "init")
local gun = RFF.Firearm.get("SomeGun")

-- specific importing of sub-modules only
local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local gun = Firearm.get("SomeGun")
```


## Modules and files

* **RFF** (rff/init.lua)  
main module loading, sets up the submodule table.

* **RFF.Config** (rff/config.lua)  
functions for getting and setting configuration values. 

* **RFF.Const** (rff/constants.lua)  
various constant values.

* **RFF.Convert** (rff/convert.lua)  
functions for converting units of measurement.

* **RFF.EventSystem** (rff/events.lua)  
functions for registering and triggering event callbacks. 

* **RFF.ItemGroup** (rff/item_group.lua)  
base class for groups used to organize data.

* **RFF.ItemType** (rff/item_type.lua)  
base class for items. Used for firearm/ammo/item specific design templates.

* **RFF.Malfunctions** (rff/malfunctions.lua)  
functions for ammo and firearm malfunctions.

* **not imported** (rff/tests.lua)  
functions for automated tests.


#### Firearm Modules

* **RFF.Firearm** (rff/firearm/init.lua)  
functions for dealing with FirearmGroups and FirearmTypes.

* **RFF.Firearm.Actions** (rff/firearm/actions.lua)  
functions for performing actions on firearm instances.

* **RFF.Firearm.Flags** (rff/firearm/flags.lua)  
various constant flag values.

* **RFF.Firearm.FirearmGroup** (rff/firearm/group.lua)  
subclass of ItemGroup used to organize firearm data.

* **RFF.Firearm.Instance** (rff/firearm/instance.lua)  
functions for dealing with specific instances of firearm data.

* **RFF.Firearm.State** (rff/firearm/state.lua)  
various constant state values.

* **RFF.Firearm.FirearmType** (rff/firearm/type.lua) 
subclass of ItemType used for various firearm design templates.


#### Magazine Modules

* **RFF.Magazine** (rff/magazine/init.lua)  
functions for dealing with FirearmGroups and FirearmTypes.

* **RFF.Magazine.Actions** (rff/magazine/actions.lua)  
functions for performing actions on magazine instances.

* **RFF.Magazine.Flags** (rff/magazine/flags.lua)  
various constant flag values.

* **RFF.Magazine.MagazineGroup** (rff/magazine/group.lua)  
subclass of ItemGroup used to organize magazine data.

* **RFF.Magazine.Instance** (rff/magazine/instance.lua)  
functions for dealing with specific instances of magazine data.

* **RFF.Magazine.State** (rff/magazine/state.lua)  
various constant state values.

* **RFF.Magazine.MagazineType** (rff/magazine/type.lua) 
subclass of ItemType used for various magazine design templates.


#### Interface modules

* **RFF.Interface.Bit** (rff/interface/bit32.lua)  
Bitwise functions, to be overwritten to with specific lua version code

* **RFF.Interface.Logger** (rff/interface/logger.lua)  
Logging related functions.

* **RFF.Interface.Firearm** (rff/interface/firearm.lua)  
Functions for dealing with the application's game objects

* **RFF.Interface.Player** (rff/interface/player.lua)  
Functions for dealing with the application's game objects 

* **RFF.Interface.Container** (rff/interface/container.lua)  
Functions for dealing with the application's game objects 




