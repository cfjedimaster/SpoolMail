LICENSE 
Copyright 2006 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   
If you find this application worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)
Install directions may be found in install.doc/pdf.

Last Updated: October 31, 2007 (Version 1.3.2)
Fixed a dupe body in bottom.cfm

Last Updated: October 31, 2007 (Version 1.3.1)
Removed some CF8 only syntax.

Last Updated: October 30, 2007 (Version 1.3)
Sam Farmer made the following updates to udf.cfm and bottom.cfm:

Sam: One issue I ran into is that we send out multipart emails and these where showing up as html.  Which was fine but not ideal.  Anyhoo, I added some code to make it work with multipart emails:

Last Updated: June 29, 2007 (Version 1.2)
Somehow udf.cfm/getMail had the cache turned off. This greatly slowed down performance. I fixed
that and disabled output as well.

I moved the cfsetting in Application.cfm.

Last Updated: June 20, 2007 (Version 1.1)
Andrew Penhorwood added quite a bit of code. First off is a set of icons.
Second - he made it possible to change the 'per page' setting.
He also did some other changes - I've commented them out for now as they aren't working well for me on the Mac, but
they may come in later. I'm mainly warning folks here in case they wonder about the extra code.

Support for attachments. You can now see attachments in email. NOTE - I've disabled the downloading of attachments
from spoolmail as it may be a security issue. To turn it on, set allowdownload to true in Application.cfm

Last Updated: December 8, 2006 (Version 1.06)
Just a HTML fix in top.cfm 

Last Updated: December 8, 2006 (Version 1.05)
Don't do activateURL on html emails.

Last Updated: December 7, 2006 (Version 1.04)
Copy all the files over your existing install.
Added support for paging.
Support for HTML versus text emails.
General UI changes here and there.
Show size of emails.

Last Updated: July 13, 2006 (Version 1.03)
Peter F suggested a Refresh button show up if no mail exists. 
Todd Sharp sent two change. First I forgot to check for the existence of form.doit. 
Secondly, he added some JS code such that when you clicked a button, the bottom frame went back to blank.

Last Updated: July 7, 2006 (Version 1.02)
top.cfm - Added a Refresh button
udf.cfm - Get CC and BCC for emails if it has them
bottom.cfm - show CC/BCC if they exist.

Last Updated: January 27, 2006 (Version 1.01)
top.cfm modded by Steve 'Cutter' Blades (no.junk at comcast.net) to add select all functionality

Last Updated: January 23, 2006
I'm calling it version 1 now. Because I can.
Application.cfm updated to use security (imagine that) and use a timeout.
top.cfm updated to handle 0 length files

Last Updated: January 20, 2006
Changed from application.cfc to cfm
Added new udf to udf.cfm
bottom.cfm modified to use activateURL