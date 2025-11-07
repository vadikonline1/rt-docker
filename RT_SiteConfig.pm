Set($rtname, '$RT_RTNAME');
Set($Organization, '$RT_ORGANIZATION');
Set($WebDomain, '$RT_WEB_DOMAIN');
Set($WebPort, '$RT_WEB_PORT');
Set($WebPath, '');
Set($DatabaseUser, '$RT_DB_USER');
Set($DatabasePassword, '$RT_DB_PASSWORD');
Set($DatabaseHost, '$POSTGRES_HOST');
Set($DatabasePort, undef);
Set($DatabaseName, '$RT_DB_NAME');
Set($DatabaseAdmin, '$POSTGRES_USER');

Set($LogToSyslog, 'warning');
Set($LogToSTDERR, 'warning');

Set(%GnuPG, 'Enable' => '0');
Set(%SMIME, 'Enable' => '0');

1;
