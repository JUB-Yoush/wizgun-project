player** interactions:
*DONE**
- have two players on the screen 
- make sure they're seperate instances
- respawers
- have them be able to shoot each other
- slash deflects bullets
- picking up more ammo
- smaller hitbox on slide
- change physics and sizes for the new dimensions
- think about enviroment coliisions and enemy collisions, use two different hitboxes I guess, make bullets target the area instead of the body
- set up slash hitbox, 
	- only make it active when in the slashing state,
	- when it touches an area, check its group
	- if it touches another slash box, do a defect thing

DOING
- find a good system to manage player animations (states of somekind???)
- get the gun animations working, with muzzle flash and the gun turning to face the direction held
- dw about gun for now, can do that later
- fix the weird reflect state bug? do a printout and investigate


- make the level
- different level geometry 
- get character area stuff setup


P ANIMATIONS:
- flip based on direction
- no idle for now
- run
- slide
- jump
-death



feel based stuff:
- squish the player a bit when they dash
- players move past each other
- have gun kb be slighly based on the x dir too
- have an input buffer 
- variable jump height
- jump speed carries into slide
- slide just reduces your friction until you stop?