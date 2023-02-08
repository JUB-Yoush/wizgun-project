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
- fix the weird reflect state bug? do a printout and investigate
- ^ ion know what dat is dawg :flushed:


- make the level
- different level geometry 
- get character area stuff setup

GAMEPLAY LOOP STUFF:
- set up targets:
	- you shoot or dash into them to collect them
	- they get added to your target count
- baskets
	- used to cash in your target count
	- stay within the target area for long enough for it to count as a cash in 
	- 5 cash ins wins the round



Post MVP:
- find a good system to manage player animations (states of somekind???)
- re-balance the shooting mechaincs (can only be deflected twice)
- make it so that you can shoot through one-way platforms?
- get the gun animations working, with muzzle flash and the gun turning to face the direction held

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
