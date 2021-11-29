#!/bin/bash
echo Starting Apache 2
systemctl restart apache2
chown -R www-data:www-data uploads
/etc/init.d/mysql start
mysql < simple_lamp.sql

tail -f /dev/null