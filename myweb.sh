#!/bin/bash
# myweb by Pavel Belyaev 2014
# Данный скрипт поможет в случае отключения автозапуска mysql и apache
if [ `id -u` -gt 0 ]; then 
echo "Запустите скрипт от имени супергероя, для этого введите sudo имя_скрипта";
exit;
fi

export PATH=$PATH:/usr/local/mysql/support-files/


startsrv ()
{
	echo "Запускаем web-сервер!!!"
	apachectl start
	/usr/local/mysql/support-files/mysql.server start
}

stopsrv ()
{
	echo "Останавливаем web-сервер"
	apachectl stop
	/usr/local/mysql/support-files/mysql.server stop
}

case $1 in
"start")startsrv;;
"stop")stopsrv;;
*)echo "Юзай start или stop!!!";;
esac
