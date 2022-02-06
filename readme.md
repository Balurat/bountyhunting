\[work in progress \| v0\.1\]

# RedM Resource for Bounty Hunter

This Resource adds a way for bounty hunters to track fugitives, that is compatible with roleplay.

Whenever a bounty is placed on a player, that player can be recognized by NPCs in towns. If bounty hunters ask around with the Gather Information action, they can find out if the fugitive was here or not and maybe a few other things.

**Reguirements**

* VORP\_CORE
* a bounty system

## Installation

1. Clone the repo or copy its content into a subfolder of your resources, called bountyhunting
e.g. <span class="colour" style="color:var(--vscode-unotes-wysList)"><span class="font" style="font-family:var(--vscode-editor-font-family)"><span class="size" style="font-size:1em">`C:\FXServer\server-data\resources\[abc]\bountyhunting`</span></span></span>
2. <span class="colour" style="color:var(--vscode-unotes-wysList)"><span class="font" style="font-family:var(--vscode-editor-font-family)"><span class="size" style="font-size:1em"></span></span></span>Import the sql schema for the table `bounty_sightings`
3. Add the resource to your `server.cfg`, after all requirements
4. [Optional] Add the commands to your favorite menu

## How it works

***This implementation is bare bones. It currently serves only as a proof of concept.***

For now, users can interface with this resource via commands. *This may get changed into events later.*

| Command | Args | Description |
| ------- | ---- | ----------- |
| <span style="color: #ce9178;">loadbountyinfo</span> | none | fetches bounty data from server |
| <span style="color: #ce9178;">gatherinformation</span> | bountyId<br>(optional) | Checks if bounty with the given id was seen in the town.<br>If no id was given, then it checks whether or not bounty hunters have asked for the caller of the command |
| <span style="color: #ce9178;">bountyhuntermenu</span> | none | toggles the bounty hunter menu on and off [not implemented yet] |

To reduce server calls, the relevant db data is cached on the client and only updates when needed and with a limit of 1 call / 5 min.
This could even be called a feature for rp. Because a bounty hunter can not immediatly know, when a sighting in his current town happened.

### Ideas

* better integration with other resources
e.g.
    * make it possible to update bounty information on bounty boards only
* UI for gathered information
* more involved gathering process
    * hunters have to interact with npcs to gather information
    * depending on how much information there is to gather, multiple interactions could be needed
    * give hints where the next sighting might be
* if a fugitive is in a town while a hunter is gathering information about him or her, display a warning after a set time

<br>
## ToDo

* [ ] refactor and cleanup
* [ ] comment code / simple documentation
* [ ] inform client after a bounty is placed on its character