# VBM365

one questions always get asked if it is possible to know “who has touched/restored what and when” to audit for compliance or for any other requirement. For Veeam Backup for Microsoft 365, there is already great information published in the post(s) and blog of Jorge, explaining all in very great detail: https://community.veeam.com/blogs-and-podcasts-57/vb365-restore-audit-the-definitive-guide-2557

Possibly, where you need a quick dump of all restore activities (now!), you may also utilize PowerShell interacting with the RESTAPI of VBM365 and list all restore sessions and their events. And the script below is just an “example” to achieve such. You may play with all properties per your needs and create output as you require, even the modified output could even be used to feed into some other applications. (Currently it is only for v6)

RestoreSession and RestoreSessionEvent is what we need to use mainly. The script finds the restore sessions, and then iterates through each of them to spit out the details of each session with its events (session start, views, restores, … session end)

The script finds the restore sessions, and then iterates through each of them to spit out the details of each session with its events (session start, views, restores, … session end)

![outputbig](https://user-images.githubusercontent.com/111152711/184495682-adcfc4f1-43ec-43f2-b4e2-a4f0245654e4.png)

•	Org: Which 365 organization
•	SessionID: Restore Session ID for reference 
  o	The output could seem to have duplicated rows at first but they are not… I wanted to output all events for a session and each restore session can have multiple events. 
•	Initiated by: Who has started
•	Session Name: From which job
•	Type : Which explorer
•	Time
•	Clienthost
•	itemName: Which item has been touched
•	itemtype: Folder, mail, etc
•	Source/target
•	Event: View, Restore, Send, Export, Save, and None (session start, and session end)
•	Message: details about the event
•	Order: the order of events within each session 
PS: I am not a script guru, but finding my way around 😊 Please let me know if there is any issues. 
