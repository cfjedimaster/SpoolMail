<!---
	Name         : C:\JRun4\servers\cfmx7\cf\CFIDE\administrator\spoolmail\top.cfm
	Author       : Raymond Camden 
	Created      : 01/16/06
	Last Updated : 12/17/06
	History      : Fixes by Scott Krebs (skrebs@ewh.net) to handle 0-length files. (rkc 1/26/06)
				 : Select All functionality by Steve 'Cutter' Blades (no.junk at comcast.net) (rkc 1/27/06)
				 : Paging, show size (rkc 12/7/06)
				 : html fix (rkc 12/17/06)
--->
<cfif structKeyExists(form,"start") and IsNumeric(form.start) and Not structKeyExists(url,"start")>
	<cfset url.start = form.start>
</cfif>

<cfif structKeyExists(form,"zPerPage") and IsNumeric(form.zPerPage) and form.zPerPage NEQ application.perpage>
	<cfset application.perpage = form.zPerPage>
</cfif>

<cfif structKeyExists(url,"PerPage") and IsNumeric(url.PerPage) and url.PerPage NEQ application.perpage>
	<cfset application.perpage = url.PerPage>
</cfif>

<cfif structKeyExists(form,"delete_id") and form.delete_id neq "">
   <cffile action="delete" file="#application.maildir#/#form.delete_id#">
</cfif>

<cfif (structKeyExists(form,"delete") or structKeyExists(form, "delete.x")) and structKeyExists(form, "doit") and len(form.doit)>
	<cfloop index="theFile" list="#form.doit#">
		<cfif fileExists(application.maildir & "/" & theFile)>
			<cffile action="delete" file="#application.maildir#/#theFile#">
		</cfif>
	</cfloop>
</cfif>

<cfif (structKeyExists(form,"move") or structKeyExists(form,"move.x")) and structKeyExists(form, "doit") and len(form.doit)>
	<cfloop index="theFile" list="#form.doit#">
		<cfif fileExists(application.maildir & "/" & theFile)>
			<cffile action="move" source="#application.maildir#/#theFile#" destination="#application.spooldir#/#thefile#">
		</cfif>
	</cfloop>
</cfif>

<!--- TODO: fix line ending issues as this only works on a Windows Box --->
<cfif structKeyExists(form,"server") and structKeyExists(form, "doit") and len(form.doit)>
	<cfloop index="theFile" list="#form.doit#">
		<cfif fileExists(application.maildir & "/" & theFile)>
			<cffile action="read" file="#application.maildir#/#theFile#" variable="vMail">

			<cfset vMail = ListRest(vMail,chr(13))>
			<cfset vMail = "server:  " & form.zServer & vMail>
						
			<cffile action="write" file="#application.spooldir#/#theFile#" output="#vMail#">
			<cffile action="delete" file="#application.maildir#/#theFile#">
		</cfif>
	</cfloop>
</cfif>

<!--- TODO: fix line ending issues as this only works on a Windows Box --->
<cfif structKeyExists(form,"redirect") and structKeyExists(form, "doit") and len(form.doit)>
	<cfloop index="theFile" list="#form.doit#">
		<cfif fileExists(application.maildir & "/" & theFile) and Len(Form.zRedirect) GT 0>
			<cffile action="read" file="#application.maildir#/#theFile#" variable="vMail">

			<cfset vPos1    = ListContainsNoCase(vMail, "to:  ",chr(13))>
			<cfset vTO      = ListGetAt(vMail,vPos1,chr(13))>
			<cfset vPos2    = ListContainsNoCase(vMail, "subject:  ",chr(13))>
			<cfset vSubject = ListGetAt(vMail,vPos2,chr(13))>

			<cfset vTO      = ReplaceNoCase(vTO,"to:  ","")>
			<cfset vTO      = Replace(vTO,chr(10),"")>
			
			<cfset vNewTO   = chr(10) & "to:  " & form.zRedirect>
			<cfset vNewSubj = vSubject & " [" & HTMLEditFormat(vTo) & "]">
			
			<cfset vMail = ListSetAt(vMail,vPos1,vNewTO,chr(13))>
			<cfset vMail = ListSetAt(vMail,vPos2,vNewSubj,chr(13))>
						
			<cffile action="write" file="#application.maildir#/#theFile#" output="#vMail#">
		</cfif>
	</cfloop>
</cfif>

<cfparam name="url.start" default="1">

<cfif not isNumeric(url.start) or url.start lte 0 or url.start neq round(url.start)>
	<cfset url.start = 1>
</cfif>

<cfdirectory action="list" name="qMail" directory="#application.maildir#" filter="*.cfmail" sort="datelastmodified desc">

<cfoutput>
<!--- 
//	Author:		Steve 'Cutter' Blades (no.junk at comcast.net)
//	Revision:	Add js scripting for a 'Select All' type checkbox
//				Aside from the below javascript the following line are required:
//				on the 'Select All' checkbox input element you will need and
//				onclick event of 'toggleCheckboxes(this,document.forms.#formname#.#checkfields#)',
//				and on the checkbox fields (all of the same id/name) you will need
//				an onclick event of 'uncheckSelectAllBox(document.forms.#formname#.#selectallfieldname#,this)
 --->
<script language="javascript" type="text/javascript">
	// Functions for checking and unchecking all checkboxes passed by name
	function toggleCheckboxes(checkItFldObj, fldObj){
		if (checkItFldObj.checked){
			checkAll(fldObj);
		} else {
			uncheckAll(fldObj);
		}
	}
	
	// Function to check all fields
	function checkAll(field){
		//alert(field.length);
		if (!field.length){
			field.checked = true;
		} else {
			for (i = 0; i < field.length; i++)
				field[i].checked = true ;
		}
	}
	
	// Function to uncheck all fields
	function uncheckAll(field){
		//alert(field.length);
		if (!field.length){
			field.checked = false;
		} else {
			for (i = 0; i < field.length; i++)
				field[i].checked = false ;
		}
	}
	
	// Function to uncheck the 'Select All' checkbox if an item is unchecked
	function uncheckSelectAllBox(checkItFldObj,fldObj){
		if ((fldObj.checked == false) && (checkItFldObj.checked == true))
			checkItFldObj.checked = false;
	}

	//added 6/27/06 by Todd Sharp - function to refresh the bottom iframe.  
	//this is called onclick of the two submit btns below
	function refreshBottom(){
		parent.document.getElementById('bottom').src='bottom.cfm';
	}

	function doHide(vElement)
	{
		var oRef = document.getElementById(vElement)
		switch(oRef.style.display)
		{
			case 'none':
				oRef.style.display = 'block';
			break;
	
			case 'block':
				oRef.style.display = 'none';
			break;
	
			default:
			break;
		}
	}
	function doPerPage(oRef)
	{
		var oPage = document.getElementById('PerPage')
		oRef.href = oRef.href + "&PerPage=" + oPage.value;
	}
	function doDelete(id) {
		var dID = document.getElementById('delete_id');
		dID.value = id;
		document.MailRecords.submit();
	}
</script>

<style>
##gradient-style {
font-family:"Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
font-size:12px;
width:94%;
text-align:left;
border-collapse:collapse;
margin:20px;
}

##gradient-style th {
font-size:13px;
font-weight:normal;
background:##b9c9fe url("images/gradhead.png") repeat-x;
border-top:2px solid ##d3ddff;
border-bottom:1px solid ##fff;
color:##039;
padding:8px;
}

##gradient-style td {
border-bottom:1px solid ##fff;
color:##669;
border-top:1px solid ##fff;
background:##e8edff url("images/gradback.png") repeat-x;
padding:8px;
}

##gradient-style tfoot tr td {
background:##e8edff;
font-size:12px;
color:##99c;
}

##gradient-style tbody tr:hover td {
background:##d0dafd url("images/gradhover.png") repeat-x;
color:##339;
}

tr {
border-color:inherit;
display:table-row;
vertical-align:inherit;
}
td, p {
	font-family: Arial;
	font-size: 11px;
}
th {
	font-family: Arial;
	font-size: 11px;
	font-weight: bold;
}
.rowA {
	background-color: ##e2fee6;
}
.rowB {
	background-color: ##ffffff;
}
.header {
	background-color: ##B9C9FE;
	border-bottom:10px solid white;
	font-weight:13px;
	padding:8px;
}
td a {
	color: black;
}
.box {
	background-color:##ffffcc;
	border: 1px solid ##cccccc;
	padding: 0px 2px;
}
##hBox {
	position: absolute;
	left: 15px;
	top: 50px;
	background-color: white;
	border: 2px solid black;
	padding: 10px;
	text-align: right;
}
##mailbar {
	position: relative;
	margin: 0px 0px 5px 0px;
	padding-left:10px;
	width:94%;
}
##mButtons {
	float: left;
	padding-left:12px;
	margin-top:8px;
}
##pageCount {
	float: right;
	text-align: right;
	font-family: Arial;
	font-size: small;
	padding-right:60px;
	margin-top:8px;
}
</style>

<cfoutput>
	<form action="top.cfm" method="post" name="mailStatus">
		<input type="Hidden" name="start" value="#url.start#"
	<div id="mailbar">
		<div id="mButtons">
		<input type="Image" name="reload" onClick="refreshBottom();" src="images/reload.png" value="reload" alt="reload" title="reload"> 
		<cfif qMail.recordCount>
		<img src="images/pixel.gif">
		<input type="Image" name="delete"  src="images/delete.png" onClick="refreshBottom();" value="delete" alt="delete email" title="delete email">
		<img src="images/pixel.gif">
		<input type="Image" name="move"    src="images/respool.png" onClick="refreshBottom();" value="move" alt="reprocess email" title="reprocess email">
		<!---
		<img src="images/sep.jpg">
		<input type="Image" name="server"  src="images/server.jpg" value="server" onClick="refreshBottom();" alt="Change EMail Server" title="change email server">
		<input type="Image" name="redirect" src="images/redirect.jpg" value="redirect" alt="redirect email" title="redirect email">
		<img src="images/show.jpg" onclick="doHide('hBox');" alt="get server / redirect info" title="get server / redirect info">
		--->
		</cfif>
		</div>
		<div ID="hBox" style="display:none;">
		server: <input type="Text" name="zServer"  value="username:password@server:port" maxlength="80" size="70" class="box"><br>
		redirect: <input type="Text" name="zRedirect" value="name@email.com" maxlength="80" size="70" class="box">
		</div>
</cfoutput>

<cfif url.Start GT qMail.recordCount>
	<cfset url.start = qMail.recordCount - application.perpage>
	
	<cfif url.start LTE 0>
		<cfset url.start = 1>
	</cfif>
</cfif>



	<div id="pageCount">
		queue as of <b>#DateFormat(now(),"d-mmm-yyyy")# #TimeFormat(now(),"H:mm:ss")#</b><br>
		<cfif qMail.recordCount and qMail.recordCount GT application.perpage>
			<cfif url.start gt 1>
				<a href="top.cfm?start=#url.start-application.perpage#" onclick="doPerPage(this)">Previous</a>
			<cfelse>
				Previous
			</cfif>
			/
			<cfif url.start + application.perpage lt qMail.recordCount>
				<a href="top.cfm?start=#url.start+application.perpage#" onclick="doPerPage(this)">Next</a>
			<cfelse>
				Next
			</cfif>
			#url.start# - #min(url.start+application.perpage, qMail.recordcount)# of #qMail.recordcount# emails &nbsp;&nbsp;&nbsp;
		<cfelseif qMail.recordCount GT 0>
			#url.start# - #min(url.start+application.perpage, qMail.recordcount)# emails
		</cfif>
		<cfif qMail.recordCount GT 0>
			<select name="zPerPage" id="PerPage">
			<cfloop index="x" list="5,10,15,20,25,50,75,100">
				<cfif x EQ application.perpage>
					<option value="#x#" selected>#x#</option>
				<cfelse>
					<option value="#x#">#x#</option>
				</cfif>	
			</cfloop>
			</select>
		</cfif>
	</div>
	<div style="clear:both;"></div>
</div>

<form action="top.cfm" method="post" name="mailRecords">
<input type="Hidden" name="start" value="#url.start#">
<input type="Hidden" name="delete_id" id="delete_id" value="">
<table width="98%" cellspacing=0 cellpadding=3 border=0 id="gradient-style">
<thead>
	<tr class="header">
		<th class="norightborder">
			<cfif qMail.recordcount gt 1>
				<input type="checkbox" name="checkit" id="checkit" onclick="toggleCheckboxes(this,document.forms.mailStatus.doit);" />
				All
			<cfelse>
				&nbsp;&nbsp;
			</cfif>
		</th>	
		<th>Subject</th>
		<th>Sender</th>
		<th>To</th>
		<th>Size</th>
		<th>Date</th>
	</tr>
</thead>
</cfoutput>

<cfif qMail.recordCount>

	<tbody>
	<cfoutput query="qMail" startrow="#url.start#" maxrows="#application.perpage#">
	<cfset info = getMail(filename=name, isMailBodyDesired=false)><!--- body can be huge, and isn't needed for list of emails --->
		<cfif currentRow mod 2>
			<cfset vClass = "class=""rowA""">
		<cfelse>
			<cfset vClass = "class=""rowB""">
		</cfif>
		<tr #vClass#>
			<!--- Cutter 01.25.06: Split 'Subject' column in two to separate checkboxes from message subjects --->
			<td class="norightborder" style="text-align:left">
				<!--- Cutter 01.25.06: Add onclick function call to check 'Select All' box --->
				<input type="checkbox" name="doit" id="doit" value="#name#" <cfif qMail.recordcount gt 1>onClick="uncheckSelectAllBox(document.forms.mailStatus.checkit,this)"</cfif> />
				<!--- add delete button to delete messages individually --->
				<input type="Image" name="delete_message"  src="images/delete_mail.png" onClick="doDelete('#name#');" value="delete" alt="delete message" title="delete message" />
			</td>
			<td onclick="parent.bottom.location='bottom.cfm?mail=#urlEncodedFormat(name)#';"><a href="bottom.cfm?mail=#urlEncodedFormat(name)#" target="bottom"><cfif structKeyExists(info,"subject") and len(info.subject)>#info.subject#<cfelse>n/a</cfif></a></td>
			<td onclick="parent.bottom.location='bottom.cfm?mail=#urlEncodedFormat(name)#';"><cfif structKeyExists(info, "sender") and len(info.sender)>#info.sender#<cfelse>n/a</cfif></td>
			<td onclick="parent.bottom.location='bottom.cfm?mail=#urlEncodedFormat(name)#';"><cfif structKeyExists(info,"to") and len(info.to)>#info.to#<cfelse>n/a</cfif></td>
			<td onclick="parent.bottom.location='bottom.cfm?mail=#urlEncodedFormat(name)#';">#fncFileSize(size)#</td>
			<td onclick="parent.bottom.location='bottom.cfm?mail=#urlEncodedFormat(name)#';"><cfif structKeyExists(info, "sent") and isDate(info.sent)>#dateFormat(info.sent)# #timeFormat(info.sent)#<cfelse>n/a</cfif></td>
		</tr>
	</cfoutput>
	</tbody>
<cfelse>

	<cfoutput>
	<tr>
		<td colspan="6">Sorry, but there is no mail in the undelivered folder.</td>
	</tr>
	</cfoutput>
	
</cfif>

<cfoutput>
</table>
</form>
</cfoutput>


<cfoutput>
</form>
</cfoutput>
