#!/bin/bash
echo Starting Apache 2
systemctl restart apache2
chown -R www-data:www-data uploads
if [ $DATABASE_URL != "" ]; then
sed -i "s/databaseurl/$DATABASE_URL/" config.php
fi
tail -f /var/log/apache2/error.log