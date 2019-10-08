# Realistic Firearm Framework

A lua framework for realistic firearms mechanics in games, game mods, and other applications.

This project is in extreme alpha state.

Provides the core features for Project Zomboid's ORGM mod.

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

* MagazineInsert
* MagazineEject
* MagazineLoad
* MagazineUnload
* FirearmReload
* FirearmUnload
* RoundChambered
* PreFire
* PostFire
* BoltOpen
* BoltClose

 