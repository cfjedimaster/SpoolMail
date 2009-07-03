<cffunction name="getMail" output="false" returnType="struct" hint="Parses a mail file for info.">
	<cfargument name="fileName" type="string" required="true" />
	<cfargument name="isMailBodyDesired" type="boolean" default="true" hint="If True, returns only the message metadata (typically for list display) rather than always including the entire message body" />
	
	<cfset var result = structNew() />
	<cfset var mail = "" />
	<cfset var pos = "" />
	<cfset var line = "" />
	<cfset var bodyType = "">

	<!--- 
		Check cache first. Normally I'd never directly address the app scope in a UDF. So sue me.
	--->
	<cfif structKeyExists(application.fileCache, arguments.fileName) AND NOT arguments.isMailBodyDesired><!--- cache now holds only email meta-data; email body is read when requested, and *only* when requested --->
		<cfreturn application.fileCache[arguments.fileName]>
	</cfif>
	
	<!--- read in file --->
	<cffile action="read" file="#application.maildir#/#arguments.filename#" variable="mail">

	<!--- ==================== start parsing ==================== --->

	<cfset result.filename = arguments.filename>
	<cfset result.sent = fileLastModified(application.maildir & '/' & arguments.filename)>

	<!--- parse SERVER: --->
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

	<cfset pos = reFindNoCase("(?m)^replyto: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.replyto = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>

	<cfset pos = reFindNoCase("(?m)^failto: (.*?)\n", mail, 1, 1)>
	<cfif pos.len[1] is not 0>
		<cfset result.failto = trim(mid(mail, pos.pos[2], pos.len[2]))>
	</cfif>
	
	<!--- parse files: --->
	<cfset result.attachments = arrayNew(1)>
	<cfset pos = reFindNoCase("(?m)^file: (.*?)\n", mail, 1, 1)>
	<cfloop condition="pos.len[1] is not 0">
		<cfif pos.len[1] is not 0>
			<cfset arrayAppend(result.attachments,trim(mid(mail, pos.pos[2], pos.len[2])))>
		</cfif>
		<cfset pos = reFindNoCase("(?m)^file: (.*?)\n", mail, pos.pos[2]+pos.len[2], 1)>
	</cfloop>

	<!--- parse BODY: --->
	<cfset result.body = "">
	<cfif arguments.isMailBodyDesired><!--- only include the (possibly sizable!) email body if desired (during view, not list) --->
		<cfif findNoCase("bodypart-start:  text/plain;",mail) and findNoCase("bodypart-start:  text/html;",mail)>
			<cfset result.type = "multipart">
		<cfelseif findNoCase("type:  text/html", mail)>
			<cfset result.type = "html">
		<cfelse>
			<cfset result.type = "text">
		</cfif>
		<cfif result.type EQ "multipart">
			<cfset result.html = createObject("java", "java.lang.StringBuffer").init()>
			<cfset result.plain = createObject("java", "java.lang.StringBuffer").init()>
			<cfset bodyType = "plain">
			<cfloop index="line" list="#mail#" delimiters="#chr(10)##chr(13)#">
				<cfif findNoCase("body: ", line) is 1>
					<cfset result[bodyType].append(replaceNoCase(line, "body: ", "") & chr(10) )>
				<cfelseif findNoCase("bodypart-start:  text/plain;",line)>
					<cfset bodyType = "plain">
				<cfelse>
					<cfset bodyType = "html">
				</cfif>
			</cfloop>
		<cfelse>
			<cfset result.body = createObject("java", "java.lang.StringBuffer").init()>
			<!--- body is all lines with body: in front. So we will do it the slow way. --->
			<cfloop index="line" list="#mail#" delimiters="#chr(10)##chr(13)#">
				<cfif findNoCase("body: ", line) is 1>
					<cfset result.body.append(replaceNoCase(line, "body: ", "") & chr(10) )>
				</cfif>
			</cfloop>
		</cfif>
	<cfelse>
		<cfset application.fileCache[arguments.fileName] = result><!--- only add this to the cache if we're not asked for the message body (this keeps the cache much smaller, while only impacting multiple reads of the same message, not a common need) --->
	</cfif>	
	
	<cfreturn result>
</cffunction>

<!--- private / helper functions --->

<cffunction name="fncFileSize" access="private" returntype="string" output="false">
	<cfargument name="size" type="numeric" required="true" />

	<cfscript>
		var str = '';
		
		if (arguments.size GTE 1048576) {
			str = arguments.size \ 1048576 & " Mb";
		} else if (arguments.size GTE 1024) {
			str = arguments.size \ 1024 & " Kb";
		} else {
			str =  arguments.size & " b";
		}
		
		return str;
	</cfscript>
</cffunction>


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
		// Calculate adjustments for timezone and daylight-savings time
		var _Offset = ((GetTimeZoneInfo().utcHourOffset)+1)*-3600;
		_File.init(JavaCast("string", arguments.filename));
		// Date is returned as number of seconds since 1-1-1970
		return DateAdd('s', (Round(_File.lastModified()/1000))+_Offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
	}
	
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
			objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", arguments.string, nextMatch, true);
			if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
				outString = outString & Mid(arguments.string, nextMatch, objMatch.pos[1] - nextMatch);
			} else {
				outString = outString & Mid(arguments.string, nextMatch, Len(arguments.string));
			}
			nextMatch = objMatch.pos[1] + objMatch.len[1];
			if (ArrayLen(objMatch.pos) GT 1) {
				// If the preceding character is an @, assume this is an e-mail address
				// (for addresses like admin@ftp.cdrom.com)
				if (Compare(Mid(arguments.string, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
					thisURL = Mid(arguments.string, objMatch.pos[1], objMatch.len[1]);
					thisLink = "<A HREF=""";
					switch (LCase(Mid(arguments.string, objMatch.pos[2], objMatch.len[2]))) {
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
					outString = outString & Mid(arguments.string, objMatch.pos[1], objMatch.len[1]);
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
	
/**
 * Replaces oldSubString with newSubString from a specified starting position while ignoring case.
 * 
 * @param theString 	 The string to modify. (Required)
 * @param oldSubString 	  The substring to replace. (Required)
 * @param newSubString 	 The substring to use as a replacement. (Required)
 * @param startIndex 	 Where to start replacing in the string. (Required)
 * @param theScope 	  Number of replacements to make. Default is "ONE". Value can be "ONE" or "ALL." (Optional)
 * @return Returns a string. 
 * @author Shawn Seley (shawnse@aol.com) 
 * @version 1, June 26, 2002 
 */
function ReplaceAtNoCase(theString, oldSubString, newSubString, startIndex){
	var targetString  = "";
	var preString     = "";

	var theScope      = "ONE";
	if(ArrayLen(Arguments) GTE 5) theScope    = Arguments[5];

	if (startIndex LTE Len(theString)) {
		targetString = Right(theString, Len(theString)-startIndex+1);
		if (startIndex GT 1) preString = Left(theString, startIndex-1);
		return preString & ReplaceNoCase(targetString, oldSubString, newSubString, theScope);
	} else {
		return theString;
	}
}
	
</cfscript>
