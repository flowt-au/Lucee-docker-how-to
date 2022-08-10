component {
  this.name = "LuceeDockerHowTo";

  this.locale = "en_AU";
  this.timezone = "Australia/Sydney";

  // You can use this as a proxy for knowing if we are on the droplet or not.
	// If the Lucee admin is enabled we are on the local dev container.
  // Not used in this tutorial, just FYI to show how to access the settings.
	this.isDev = (server.system.environment.LUCEE_ADMIN_ENABLED eq true);

  /* DSN.
    FYI: The same settings as supplied in /LuceeSettings for the DataSource:
    Note the encrypted password is the encrypted version of 'p1', and the host is 'db:3306'

    this.datasources["test_dsn"] = {
      class: 'com.mysql.cj.jdbc.Driver'
      , bundleName: 'com.mysql.cj'
      , bundleVersion: '8.0.19'
      , connectionString: 'jdbc:mysql://db:3306/test?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=3'
      , username: 'root'
      , password: "encrypted:c00ed74314a3b316ca90abbefc05d885"

      // optional settings
      , connectionLimit:100 // default:-1
      , liveTimeout:15 // default: -1; unit: minutes
      , alwaysSetTimeout:true // default: false
      , validate:false // default: false
    };
  */

  boolean function onApplicationStart() {

    // Do something ...

    return true;
  }
}