# Realistic Firearm Framework

A lua framework for realistic firearms mechanics in games, game mods, and other applications.

This project is in extreme alpha state.

What this project is:

* A evolution of the ORGM mod for Project Zomboid, redesigned to be a application independent framework.

* A system incorporating realistic firearm mechanics, operation of the weapons, mechanical and ammunition failures, and 
recalculation of firearm stats based on factors such as current ammo in the chamber (multi ammo types supported), 
weight of attachments absorbing recoil, and much more.

* Abstract enough potential uses include anything from 3d shooters to 2d turn based games. 

What this project is **NOT**:

* A scientific simulation of ballistic performance

The Framework is made up of several components:

### RFF (Core): 
Contains firing and reloading logic, global settings, item information and attributes in a realistic (or abstract) fashion. 
Attributes such as range, recoil, accuracy etc should not be application specific. 
To handle translating data and concepts between the application and RFF, it exports a Interface and Event System.

It needs to be able to blindly track and pass around variables such as the player or applications representation of the firearm while never directly accessing them (or even knowing how to)


### The Bridge:
Contains all application specific code. Registers events into RFF's event systems, overwrites the RFF Inferface, and does any application specific requirements such as loading 3d models, UI elements etc.

Beyond callbacks registered to the Event System and Interface overwrites, the RFF core will access any other parts of the Bridge. 


### The Interface:
The interface is a set of placeholder functions, intended to be overwritten by the Bridge.
Any time the RFF core would need a application specific function, it would look here, and run the code defined by the Bridge.

The Interface is responsible converting data such as firearm range into application specific values. 


### The Event System:
In addition to the Interface, a event/callback system is used so the Bridge can run custom application specific code at key points, and potentially stop the current RFF code block from executing.

Example events:

* MagazineInserted
* MagazineEjected
* MagazineLoaded
* MagazineUnload
* FirearmReload
* FirearmUnload
* RoundChambered
* TriggerPulled
* ShotFired
* BoltOpened
* BoltClosed

 