<!---
	Name         : C:\JRun4\servers\cfmx7\cf\CFIDE\administrator\spoolmail\index.cfm
	Author       : Raymond Camden 
	Created      : 01/16/06
	Last Updated : 12/7/06
	History      : Changed height a bit (rkc 12/7/6)
--->


<cfif not directoryExists(application.maildir)>
	<cfoutput>
	<h2>Sorry!</h2>
	
	<p>
	Something has gone wrong. I cann't seem to find your undelivered folder at:<br />
	#maildir#
	</p>
	</cfoutput>
	
	<cfabort>
</cfif>

<cfoutput>
<html>

<head>
<frameset rows="320,*" resizeable="true" >
<frame src="top.cfm" marginheight="0" marginwidth="0">
<frame src="bottom.cfm" marginheight="0" marginwidth="0" name="bottom" id="bottom">
</frameset>
</head>

<body></body>
</html>
</cfoutput>
