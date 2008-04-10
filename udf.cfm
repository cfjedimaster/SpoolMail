<cfscript>
/**
 * Returns the date the file was last modified.
 * 
 * @param filename 	 Name of the file. (Required)
 * @return Returns a date. 
 * @author Jesse Houwing (j.houwing@student.utwente.nl) 
 * @version 1, November 15, 2002 
 */
function fileLastModified(filename){
	var _File =  createObject("java","java.io.File");
	// Calculate adjustments fot timezone and daylightsavindtime
	var _Offset = ((GetTimeZoneInfo().utcHourOffset)+1)*-3600;
	_File.init(JavaCast("string", filename));
	// Date is returned as number of seconds since 1-1-1970
	return DateAdd('s', (Round(_File.lastModified()/1000))+_Offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
}
</cfscript>

<cfscript>
/**
 * This function takes URLs in a text string and turns them into links.
 * Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
 * Version 3 Updated to allow for ;
 * 
 * @param string 	 Text to parse. (Required)
 * @param target 	 Optional target for links. Defaults to "". (Optional)
 * @param paragraph 	 Optionally add paragraphFormat to returned string. (Optional)
 * @return Returns a string. 
 * @author Joel Mueller (jmueller@swiftk.com) 
 * @version 3, August 11, 2004 
 */
function ActivateURL(string) {
	var nextMatch = 1;
	var objMatch = "";
	var outstring = "";
	var thisURL = "";
	var thisLink = "";
	var	target = IIf(arrayLen(arguments) gte 2, "arguments[2]", DE(""));
	var paragraph = IIf(arrayLen(arguments) gte 3, "arguments[3]", DE("false"));
	
	do {
		objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", string, nextMatch, true);
		if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
			outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
		} else {
			outString = outString & Mid(String, nextMatch, Len(string));
		}
		nextMatch = objMatch.pos[1] + objMatch.len[1];
		if (ArrayLen(objMatch.pos) GT 1) {
			// If the preceding character is an @, assume this is an e-mail address
			// (for addresses like admin@ftp.cdrom.com)
			if (Compare(Mid(String, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
				thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
				thisLink = "<A HREF=""";
				switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
					case "www.": {
						thisLink = thisLink & "http://";
						break;
					}
					case "ftp.": {
						thisLink = thisLink & "ftp://";
						break;
					}
				}
				thisLink = thisLink & thisURL & """";
				if (Len(Target) GT 0) {
					thisLink = thisLink & " TARGET=""" & Target & """";
				}
				thisLink = thisLink & ">" & thisURL & "</A>";
				outString = outString & thisLink;
				// String = Replace(String, thisURL, thisLink);
				// nextMatch = nextMatch + Len(thisURL);
			} else {
				outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
			}
		}
	} while (nextMatch GT 0);
		
	// Now turn e-mail addresses into mailto: links.
	outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
		
	if (paragraph) {
		outString = ParagraphFormat(outString);
	}
	return outString;
}
</cfscript>

<cffunction name="getMail" output="false" returnType="struct" hint="Parses a mail file for info.">
	<cfargument name="fileName" type="string" required="true">
	<cfset var result = structNew()>
	<cfset var mail = "">
	<cfset var pos = "">
	<cfset var line = "">
	<cfset var bodyType = ""><!--- SF --->
		
	<!--- 
		Check cache first. Normall I'd never directly address the app scope in a UDF. So sue me.
	<cfif structKeyExists(application.fileCache, arguments.fileName)>
		<cfreturn application.fileCache[arguments.fileName]>
	</cfif>
	--->
	
	<!--- read in file --->
	<cffile action="read" file="#application.maildir#/#arguments.filename#" variable="mail">

	<!--- ==================== start parsing ==================== --->

	<cfset result.filename = arguments.filename>
	
	<cfset result.attachments = arrayNew(1)>

	<!--- parse FROM: --->
	<cfset pos = reFindNoCase("(?m)^server: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.server = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<!--- parse FROM: --->
	<cfset pos = reFindNoCase("(?m)^from: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.sender = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<!--- parse TO: --->
	<cfset pos = reFindNoCase("(?m)^to: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.to = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<!--- parse CC: --->
	<cfset pos = reFindNoCase("(?m)^cc: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.cc = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<!--- parse BCC: --->
	<cfset pos = reFindNoCase("(?m)^bcc: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.bcc = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>


	<!--- parse SUBJECT: --->
	<cfset pos = reFindNoCase("(?m)^subject: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.subject = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<!--- parse file: --->
	<cfset pos = reFindNoCase("(?m)^file: (.*?)\n", mail, 1, 1)>
	<cfloop condition="pos.len[1] is not 0">
		<cfif pos.len[1] is not 0>
			<cfset arrayAppend(result.attachments,trim(mid(mail, pos.pos[2], pos.len[2])))>
		</cfif>
		<cfset pos = reFindNoCase("(?m)^file: (.*?)\n", mail, pos.pos[2]+pos.len[2], 1)>
	</cfloop>

	<!--- SF: Is this multi-part? --->
	<cfif findNoCase("bodypart-start:  text/plain;",mail) and findNoCase("bodypart-start:  text/html;",mail)>
		<cfset result.type = "multipart">
		<cfset result.body = "">
		<cfset result.html = "">
		<cfset result.plain = "">
		<cfset bodyType = "plain">
		<cfloop index="line" list="#mail#" delimiters="#chr(10)##chr(13)#">
			<cfif findNoCase("body: ", line) is 1>
				<cfset result[bodyType] = result[bodyType] & replaceNoCase(line, "body: ", "") & chr(10)>
			<cfelseif findNoCase("bodypart-start:  text/plain;",line)>
				<cfset bodyType = "plain">
			<cfelse>
				<cfset bodyType = "html">
			</cfif>
		</cfloop>
	<cfelse>
		<!--- body is all lines with body: in front. So we will do it the slow way. --->
		<cfset result.body = "">
		<cfloop index="line" list="#mail#" delimiters="#chr(10)##chr(13)#">
			<cfif findNoCase("body: ", line) is 1>
				<cfset result.body = result.body & replaceNoCase(line, "body: ", "") & chr(10)>
			</cfif>
		</cfloop>
		<!--- find type--->
		<cfif findNoCase("type:  text/html", mail)>
			<cfset result.type = "html">
		<cfelse>
			<cfset result.type = "text">
		</cfif>
	</cfif>
	
	<cfset result.sent = fileLastModified("#application.maildir#/#arguments.filename#")>
	
	
	
	<cfset application.fileCache[arguments.fileName] = result>

	
	<cfreturn result>
</cffunction>

<cffunction name="fncFileSize" returnType="string" output="false">
<cfargument name="size" required="true">
<cfscript>
if ((size gte 1024) and (size lt 1048576)) {
	return round(size / 1024) & "Kb";
} else if (size gte 1048576) {
	return decimalFormat(size/1048576) & "Mb";
} else {
	return "#size# b";
}
</cfscript>
</cffunction>
