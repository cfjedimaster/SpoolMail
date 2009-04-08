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

 <!--- Only if Edit form action happens --->
<cfif StructKeyExists(Form, "Edit") OR StructKeyExists(Form, "Resend")>

	<cffile action="read" file="#application.maildir#/#url.mail#" variable="EditedMail">
		
	<!--- Only if "server" address is changed --->
	<cfif form.Mail_Server NEQ form.Mail_Server_orig>
		<cfset MailServerPosition = reFindNoCase("(?m)^server: (.*?)\n", EditedMail, 1, 1)>
		<cfset EditedMail = ReplaceAtNoCase(EditedMail, form.Mail_Server_orig, form.Mail_Server,MailServerPosition.pos[2], "ONE")>
	</cfif>
	
	<!--- Only if "from" address is changed --->
	<cfif form.MailSender NEQ form.MailSender_orig>
		<cfset MailSenderPosition = reFindNoCase("(?m)^from: (.*?)\n", EditedMail, 1, 1)>
		<cfset EditedMail = ReplaceAtNoCase(EditedMail, form.MailSender_orig, form.MailSender,MailSenderPosition.pos[2], "ONE")>
	</cfif>
		
	<!--- Only if "to" address is changed --->
	<cfif form.MailTo NEQ form.MailTo_orig>
		<cfset MailToPosition = reFindNoCase("(?m)^to: (.*?)\n", EditedMail, 1, 1)>
		<cfset EditedMail = ReplaceAtNoCase(EditedMail, form.MailTo_orig, form.MailTo,MailToPosition.pos[2], "ONE")>
	</cfif>
		
	<!--- Only if "cc" address exists and is changed --->
	<cfif structKeyExists(Form, "MailCC")>
		<cfif form.MailCC NEQ form.MailCC_orig>
			<cfset MailCCPosition = reFindNoCase("(?m)^cc: (.*?)\n", EditedMail, 1, 1)>
			<cfset EditedMail = ReplaceAtNoCase(EditedMail, form.MailCC_orig, form.MailCC,MailCCPosition.pos[2], "ONE")>
		</cfif>
	</cfif>

	<!--- Only if "bcc" address exists and is changed --->
	<cfif structKeyExists(Form, "MailBCC")>
		<cfif form.MailBCC NEQ form.MailBCC_orig>
			<cfset MailBCCPosition = reFindNoCase("(?m)^bcc: (.*?)\n", EditedMail, 1, 1)>
			<cfset EditedMail = ReplaceAtNoCase(EditedMail, form.MailBCC_orig, form.MailBCC,MailBCCPosition.pos[2], "ONE")>
		</cfif>
	</cfif>
	
	<cfif StructKeyExists(Form, "Edit")>
		<cffile action="write" nameconflict="OVERWRITE" file="#application.maildir#/#url.mail#" output="#EditedMail#">
		<cfset mail = getMail(url.mail)>
	</cfif>
	<cfif StructKeyExists(Form, "Resend")>
		<cffile action="write" nameconflict="OVERWRITE" file="#application.spooldir#/#url.mail#" output="#EditedMail#">
		<cffile action="delete" file="#application.maildir#/#url.mail#">
		<script>
		<cfoutput>
		parent.frames[0].location.href='top.cfm?x=#urlEncodedFormat(createUUID())#';
		</cfoutput>
		</script>
		<cfabort>
	</cfif>
	
</cfif>

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
<form name="frmEditEmail" action="bottom.cfm?mail=#url.mail#" target="_self" method="post">
<table>
	<tr>
		<td><b>Filename:</b></td>
		<td>#mail.filename#</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td><b>Server:</b></td>
		<td>#mail.server#</td>
		<td></td>
		<td>
			<input type="Text" name="Mail_Server" value="#mail.server#">
			<input type="hidden" name="Mail_Server_orig" value="#mail.server#">
		</td>
	</tr>
	<tr>
		<td><b>From:</b></td>
		<td><a href="mailto:#HTMLEditFormat(mail.sender)#">#HTMLEditFormat(mail.sender)#</a></td>
		<td></td>
		<td>
			<input type="Text" name="MailSender" value="#HTMLEditFormat(mail.sender)#">
			<input type="hidden" name="MailSender_orig" value="#HTMLEditFormat(mail.sender)#">
		</td>
	</tr>
	<cfif structKeyExists(mail, "replyto")>
		<tr>
		<td><b>ReplyTo:</b></td>
		<td><a href="mailto:#mail.replyto#">#HTMLEditFormat(mail.replyto)#</a></td>
		</tr>
	</cfif>
	<tr>
		<td><b>Subject:</b></td>
		<td>#HTMLEditFormat(mail.subject)#</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td><b>To:</b></td>
		<td><a href="mailto:#mail.to#">#HTMLEditFormat(mail.to)#</a></td>
		<td></td>
		<td>
			<input type="Text" name="MailTo" value="#mail.to#">
			<input type="hidden" name="MailTo_orig" value="#mail.to#">
		</td>
	</tr>
	<cfif structKeyExists(mail, "cc")>
	<tr>
		<td><b>CC:</b></td>
		<td>#HTMLEditFormat(mail.cc)#</td>
		<td></td>
		<td>
			<input type="Text" name="MailCC" value="#mail.cc#">
			<input type="hidden" name="MailCC_orig" value="#mail.cc#">
		</td>
	</tr>
	</cfif>
	<cfif structKeyExists(mail, "bcc")>
	<tr>
		<td><b>BCC:</b></td>
		<td>#HTMLEditFormat(mail.bcc)#</td>
		<td></td>
		<td>
			<input type="Text" name="MailBCC" value="#mail.bcc#">
			<input type="hidden" name="MailBCC_orig" value="#mail.bcc#">
		</td>
	</tr>
	</cfif>
	<cfif structKeyExists(mail, "attachments") and arrayLen(mail.attachments)>
	<tr valign="top">
		<td><b>Attachments:</b></td>
		<td>
		<cfloop index="x" from="1" to="#arrayLen(mail.attachments)#">
			<cfif application.allowdownload>
				<a href="download.cfm?filename=#urlEncodedFormat(mail.attachments[x])#">#mail.attachments[x]#</a><br />
			<cfelse>
				#mail.attachments[x]#<br />
			</cfif>
		</cfloop>
		</td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	<tr>
		<td><b>Sent:</b></td>
		<td>#dateFormat(mail.sent)# #timeFormat(mail.sent)#</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td colspan="2"><input type="Submit" name="Edit" value="Edit"></td>
		<td><input type="Submit" name="Resend" value="Resend"></td>
	</tr>
	
</form>
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
