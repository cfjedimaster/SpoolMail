<!---
	Name         : C:\JRun4\servers\cfmx7\cf\CFIDE\administrator\spoolmail\bottom.cfm
	Author       : Raymond Camden 
	Created      : 01/16/06
	Last Updated : 12/8/06
	History      : Added activateURL (rkc 1/20/06)
				 : UI changes, notice html versus text (rkc 12/7/06)
				 : Don't activateURL on HTML emails (rkc 12/8/06)
--->

<cfif not structKeyExists(url, "mail")>
	<cfabort>
</cfif>

<cfset mail = getMail(url.mail)>

<cfif mail.type is "text">
	<cfset mailbody = activateURL(trim(mail.body),"_new")>
<cfelse>
	<cfset mailbody = trim(mail.body)>
</cfif>

<cfoutput>
<style>
h2 {
	font-family: Arial;
}

p, td {
	font-family: Arial;
}

pre {

	font-family: Courier;
}

</style>
</cfoutput>

<!--- Display mail. --->
<cfoutput>
<table>
	<tr>
		<td><b>Filename:</b></td>
		<td>#mail.filename#</td>
	</tr>
	<tr>
		<td><b>Server:</b></td>
		<td>#mail.server#</td>
	</tr>
	<tr>
		<td><b>From:</b></td>
		<td><a href="mailto:#mail.sender#">#HTMLEditFormat(mail.sender)#</a></td>
	</tr>
	<tr>
		<td><b>Subject:</b></td>
		<td>#HTMLEditFormat(mail.subject)#</td>
	</tr>
	<tr>
		<td><b>To:</b></td>
		<td><a href="mailto:#mail.to#">#HTMLEditFormat(mail.to)#</a></td>
	</tr>
	<cfif structKeyExists(mail, "cc")>
	<tr>
		<td><b>CC:</b></td>
		<td>#HTMLEditFormat(mail.cc)#</td>
	</tr>
	</cfif>
	<cfif structKeyExists(mail, "bcc")>
	<tr>
		<td><b>BCC:</b></td>
		<td>#HTMLEditFormat(mail.bcc)#</td>
	</tr>
	</cfif>
	<cfif structKeyExists(mail, "attachments") and arrayLen(mail.attachments)>
	<tr valign="top">
		<td><b>Attachments:</b></td>
		<td>
		<cfloop index="x" from="1" to="#arrayLen(mail.attachments)#">
			<cfif application.allowdownload>
				<a href="download.cfm?filename=#urlEncodedFormat(mail.attachments[x])#">#mail.attachments[x]#</a><br/>
			<cfelse>
				#mail.attachments[x]#<br />
			</cfif>
		</cfloop>
		</td>
	</tr>
	</cfif>

	<tr>
		<td><b>Sent:</b></td>
		<td>#dateFormat(mail.sent)# #timeFormat(mail.sent)#</td>
	</tr>
</table>

<hr />

<cfif mail.type is "text">
<pre>
#mailbody#
</pre>
<cfelseif mail.type is "multipart">
	#replace(activateURL(mail.plain,"_new"),"#chr(10)#","<br>","all")#
	<hr>
	#mail.html#
<cfelse>
#mailbody#
</cfif>

</cfoutput>
