# /opt/rt6/etc/RT_SiteConfig.pm

Set($rtname, $ENV{'RT_RTNAME'});
Set($Organization, $ENV{'RT_ORG_NAME'});
Set($WebDomain, $ENV{'RT_WEB_DOMAIN'});
Set($WebPort, $ENV{'RT_WEB_PORT'});
Set($WebPath, $ENV{'RT_WEB_PATH'});

Set($DatabaseType, $ENV{'RT_DB_TYPE'});
Set($DatabaseUser, $ENV{'RT_DB_USER'});
Set($DatabasePassword, $ENV{'RT_DB_PASS'});
Set($DatabaseHost, $ENV{'RT_DB_HOST'});
Set($DatabasePort, $ENV{'RT_DB_PORT'});
Set($DatabaseName, $ENV{'RT_DB_NAME'});
Set($DatabaseAdmin, $ENV{'RT_DB_ADMIN'});

Set($LogToSyslog, 'warning');
Set($LogToSTDERR, 'warning');

Set(%GnuPG, 'Enable' => '0');
Set(%SMIME, 'Enable' => '0');

1;
