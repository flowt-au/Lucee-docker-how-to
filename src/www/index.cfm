<h3>Hello from Lucee Docker How To</h3>

<h4>Lucee version: <cfoutput>#Server.lucee.version#</cfoutput></h4>

<p>The locale is: <cfoutput>#getLocale()#</cfoutput></p>

<cfset tzInfo = GetTimeZoneInfo()/>

<p>The time now in location <cfoutput>#tzInfo.id# is: #dateTimeFormat(now(), "long")# (#tzInfo.name#)</cfoutput></p>

<cfscript>
	sql = "select * from countries";
	qry = new Query( sql = sql, datasource="test_dsn" );
	qryObj = qry.execute();
  writedump(qryObj.getresult());

	sql = "select * from cities";
	qry = new Query( sql = sql, datasource="test_dsn" );
	qryObj = qry.execute();
  writedump(qryObj.getresult());
</cfscript>
