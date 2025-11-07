Set($rtname, $ENV{'RT_RTNAME'});
Set($Organization, $ENV{'RT_ORGANIZATION'});
Set($WebDomain, $ENV{'RT_WEB_DOMAIN'});
Set($WebPort, $ENV{'RT_WEB_PORT'});
Set($WebPath, '');

Set($DatabaseUser, $ENV{'POSTGRES_USER'});
Set($DatabasePassword, $ENV{'POSTGRES_PASSWORD'});
Set($DatabaseHost, $ENV{'POSTGRES_HOST'});
Set($DatabasePort, undef);
Set($DatabaseName, $ENV{'POSTGRES_DB'});
Set($DatabaseAdmin, $ENV{'POSTGRES_USER'});

Set($LogToSyslog, 'warning');
Set($LogToSTDERR, 'warning');

Set(%GnuPG, 'Enable' => 0);
Set(%SMIME, 'Enable' => 0);
1;
