# rc_objectiveCreator

This is a more or less simple script that lets you create some basic objectives, like go to point A, wait till you are there and send an event.

!IMPORTANT!
This is not a final version! It will remain in this state for some time since I will need time to get it to work perfectly. This is just an inside look of what it might look like in future with all the parts fully released. If you have any ideas as to what you want to see in something like that, be sure to dm me on FiveM Forum or Pull Request or create Issue!

Things that are +/- working:

-gt: = go to(1p, 2p, 3p, 4p) = int, int, int, bool
-cnt: = continue(0p) after previous statement has been finished(only gt will work with this for now)
-inf: = information(1p) = str, displays in chat, simple TriggerEvent with chat message, change it in source if you want
-cnpc: = Create NPC(1p, 2p, 3p, 4p, 5p, 6p) = model[str], int, int, int, int, bool, creates npc
