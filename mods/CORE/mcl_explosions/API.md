# mcl_explosions
This mod provide helper functions to create explosions.

## mcl_explosions.explode(pos, strength, info, puncher)
* pos: position, initial position of the explosion
* strength: number, radius of the explosion
* info: table, explosion informations:
    * drop_chance: number, if specified becomes the drop chance of all nodes in the explosion (default: 1.0 / strength)
    * max_blast_resistance: int, if specified the explosion will treat all non-indestructible nodes as having a blast resistance of no more than this value
    * sound: bool, if true, the explosion will play a sound (default: true)
    * particles: bool, if true, the explosion will create particles (default: true)
    * fire: bool, if true, 1/3 of nodes become fire (default: false)
    * griefing: bool, if true, the explosion will destroy nodes (default: true)
    * grief_protected: bool, if true, the explosion will also destroy nodes which have been protected (default: false)
* puncher: (optional) entity, will be used as source for damage done by the explosion

Additional Node Definition Fields
* `on_blast`: callback of type 'function(pos, _, do_drop) called when a node is hit with an explosion
  * `pos`: Position of the node
  * `intensity`: Power of a 
  * `do_drop`: true if nodes should do drops
* `_mcl_blast_resistance`: a number between 0 (always blast) and 100000 (never blast) for how resistant a node is to explosions

Additional Entity Definition Fields
* `tnt_knockback`: if true, the entity will experience increased knockback when hit with an explosion