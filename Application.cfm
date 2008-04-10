<!---
	Name         : C:\Apache2\htdocs\CFIDE\administrator\spoolmail\Application.cfm
	Author       : Raymond Camden 
	Created      : 01/20/06
	Last Updated : 7/29/07
	History      : Written by Phillip Duba. I modified it a bit.
				 : Added requesttimeout and include for security (both finds by my users, thanks!)
				 : Perpage (rkc 12/7/6)
				 : allowdownload (rkc 7/20/7)
				 : moved the cfsetting to after CFADMIN's core cfsetting (rkc 7/29/07)
--->
<cfinclude template="../Application.cfm">

<cfsetting showdebugoutput=false requestTimeout="180">

<cfapplication name="SpoolMail" applicationtimeout="#createTimeSpan(0,2,0,0)#" sessionmanagement="yes" 
			   loginstorage="Session" sessiontimeout="#createTimeSpan(0,2,0,0)#" clientmanagement="no">

<cfif not structKeyExists(application, "init") or structKeyExists(url, "reinit")>
	<cfset application.maildir = server.coldfusion.rootdir & "/Mail/Undelivr/">
	<cfset application.spooldir = server.coldfusion.rootdir & "/Mail/Spool/">
	<cfset application.fileCache = structNew()>
	<cfset application.perpage = 20>
	<cfset application.allowdownload = false>
	<cfset application.init = now()>
</cfif>

<cfinclude template="udf.cfm">