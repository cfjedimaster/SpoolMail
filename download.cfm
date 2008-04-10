<cfif structKeyExists(url,"filename") and fileExists(url.filename) and application.allowdownload>
	<cfset downloadfilename = listLast(url.filename,"/\")>
	<cfset extension = listLast(url.filename, ".")>

	<cfswitch expression="#extension#">
	
		<cfcase value="pdf">
	
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/pdf">
		
		</cfcase>
		
		<cfcase value="doc,rtf">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/msword">		
		</cfcase>
	
		<cfcase value="ppt">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/vnd.ms-powerpoint">		
		</cfcase>
	

		<cfcase value="xls">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/application/vnd.ms-excel">		
		</cfcase>

		<cfcase value="zip">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/application/zip">		
		</cfcase>

		<cfcase value="jpg">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/jpeg">		
		</cfcase>

		<cfcase value="gif">
			<cfheader name="Content-disposition" value="attachment;filename=""#downloadfilename#""">		
			<cfcontent file="#url.fileName#" type="application/gif">		
		</cfcase>
	
		<!--- everything else --->
		<cfdefaultcase>
			<cfheader name="Content-disposition" value="attachment;filename=""#data.file#""">		
			<cfcontent file="#url.fileName#" type="application/unknown">		
		</cfdefaultcase>
			
	</cfswitch>
</cfif>	