/**
 * A test REST cfc providing some endpoints
 */
component restpath="/world"  rest="true" {

    // http://localhost:8890/rest/v1/world/countries
    remote array function getCountries()
        httpmethod="GET"
        restpath="countries" {
            var sql = "select * from countries";
            var qry = new Query( sql = sql, datasource="test_dsn", returnType: "array" );
            var qryObj = qry.execute();
            var res = qryObj.getresult();
            return res;
        }

    // http://localhost:8890/rest/v1/world/countries/2
    remote struct function getCountry(
        required string key restargsource="Path")
        httpmethod="GET"
        restpath="countries/{key}" {
            var sql = "select * from countries where countryId = #arguments.key#";
            var qry = new Query( sql = sql, datasource="test_dsn", returnType: "struct" );
            var qryObj = qry.execute();
            var res = qryObj.getresult();
            return res;
        }

    // http://localhost:8890/rest/v1/world/cities
    remote array function getCities()
        httpmethod="GET"
        restpath="cities" {
            var sql = "select * from cities";
            var qry = new Query( sql = sql, datasource="test_dsn", returnType: "array" );
            var qryObj = qry.execute();
            var res = qryObj.getresult();
            return res;
        }

    // http://localhost:8890/rest/v1/world/cities/3
    remote struct function getCity(
        required string key restargsource="Path")
        httpmethod="GET"
        restpath="cities/{key}" {
            var sql = "select * from cities where cityId = #arguments.key#";
            var qry = new Query( sql = sql, datasource="test_dsn", returnType: "struct" );
            var qryObj = qry.execute();
            var res = qryObj.getresult();
            return res;
        }

    // http://localhost:8890/rest/v1/world/times
    remote array function getAllCityTimes()
        httpmethod="GET"
        restpath="times" {
            var sql = "Select countries.countryName, cities.cityName, cities.tzid from countries left JOIN cities on countries.countryId = cities.countryId";
            var qry = new Query( sql = sql, datasource="test_dsn", returnType: "array" );
            var qryObj = qry.execute();
            var res = qryObj.getresult();

            // For each city, calculate its local time now
            // and set it with an ISO8601 date format
            res.each( function(el, idx, arr) {
              var t = now().dateTimeFormat('ISO8601', el.tzid);
              el['currentTime'] = t;
            })

            return res;
        }
}