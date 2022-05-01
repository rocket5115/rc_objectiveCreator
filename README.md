# rc_objectiveCreator

This is a more or less simple script that lets you create some basic objectives, like go to point A, wait till you are there and send an event.

!IMPORTANT!
This is not a final version! It will remain in this state for some time since I will need time to get it to work perfectly. This is just an inside look of what it might look like in future with all the parts fully released. If you have any ideas as to what you want to see in something like that, be sure to dm me on FiveM Forum or Pull Request or create Issue!

![image](https://user-images.githubusercontent.com/65498427/166116814-f8023a9e-7839-41ff-98a2-eb0dc87ab485.png)

Things that are +/- working:

notification - p1 - str\n
text - p1, p2 - str, int
marker - up to 23p, all from docs except for material and p19, additionally: onButton(bool), Button(int)
createnpc - p1, p2, p3, p4, p5, p6, p7 - str, int, int, int, int, bool, str
playanim - p1, p2, p3 - str, str, str
scenario - p1, p2, p3 - str, str, str
loadnpc - p1 - str
goto - p1, p2, p3 - int, int, int
ignore(await) - p0 - goto or marker
delay(wait) - p1 - int
