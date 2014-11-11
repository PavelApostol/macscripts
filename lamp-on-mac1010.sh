#!/bin/bash
# version 1.1 for MacOS 10.9
# created by Pavel Belyaev 2014
if [ `id -u` -gt 0 ]; then 
echo "Запустите скрипт от имени суперпользователя, для этого введите sudo имя_скрипта";
exit;
fi

echo "
#######################################################
# данный скрипт развернет LAMP сервер на вашем MacOS! #
# автор скрипта не отвечает ни за что, данный скрипт  #
# работает на MacOS 10.9 и только на ненастроенной    #
# системе, если вы модифицировали конфиги Apache или  #
# PHP, то для вас этот скрипт неактуален!!!!          #
#######################################################

"
read -s -p "Для продолжения нажми любую кнопку, для завершения нажми ctrl+c" -n 1
echo ;

Acnf='/etc/apache2/httpd.conf';
My_tmp=`pwd`'/tmp_install_lamp'
echo "Временная папка: "$My_tmp
mkdir $My_tmp 
cd $My_tmp§
echo "
#########################
# Устанавливаем MYSQL! ##
#########################
"
#curl -L -O http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.16-osx10.7-x86.dmg
#if [ ! -f ./mysql*dmg ]; then echo "Ошибка загрузки файла mysql!!!"; exit; fi
#mkdir mysql
#hdiutil attach -mountpoint ./mysql/ mysql*dmg
#find ./mysql -name "*.pkg" -exec installer -pkg {} -target / \;
#cp -r ./mysql/MySQL.prefPane/ /Library/PreferencePanes/MySQL.prefPane
#killall System\ Preferences
#hdiutil detach ./mysql
#rm -r ./mysql
#rm mysql*dmg
export PATH="/usr/local/mysql/bin:$PATH"
echo 'export PATH="/usr/local/mysql/bin:$PATH"' >> /etc/bashrc
/usr/local/mysql/support-files/mysql.server start

#задать пароль mysql root
#read -p "Введите пароль пользователя MYSQL для root: " mysql_p
#echo "Введенный пароль ".$mysql_p


mysqladmin -u root password "$mysql_p"
echo "
##############################
# Устанавливаем PhpMyAdmin! ##
##############################
"
curl -L -o 'phpmyadmin.zip' http://sourceforge.net/projects/phpmyadmin/files/latest/download
if [ ! -f ./phpmyadmin.zip ]; then echo "Ошибка загрузки файла mysql!!!"; exit; fi
unzip ./phpmyadmin.zip && rm ./phpmyadmin.zip
mv phpMyAdmin* phpmyadmin
rm -r /usr/local/phpmyadmin/*
mkdir -p /usr/local/phpmyadmin
mv phpmyadmin/ /usr/local/phpmyadmin/www

echo 'Alias /phpmyadmin /usr/local/phpmyadmin/www
<Directory /usr/local/phpmyadmin/www>
        Options FollowSymLinks
        DirectoryIndex index.php
        Options Indexes
        Order allow,deny
        Allow from all
        <IfModule mod_php5.c>
                AddType application/x-httpd-php .php
                php_flag track_vars On
        </IfModule>
</Directory>
<Directory /usr/local/phpmyadmin/www/libraries>
    Order Deny,Allow
    Deny from All
</Directory>
<Directory /usr/local/phpmyadmin/www/lib>
    Order Deny,Allow
    Deny from All
</Directory>' > /usr/local/phpmyadmin/apache.conf
cp /usr/local/phpmyadmin/www/config.sample.inc.php /usr/local/phpmyadmin/www/config.inc.php
echo "
##############################
#  Конфигурируем Apache!    ##
##############################
"
echo -n "Создаем резервную копию http.conf ";
cp $Acnf $Acnf".back"

sed -ie 's/#LoadModule php5_module/LoadModule php5_module/g' $Acnf
sed -ie 's/DirectoryIndex index.html/DirectoryIndex index.php index.htm index.html/g' $Acnf
sed -ie '/<Directory "\/Library.*/,/<\/Directory>/ d' $Acnf
sed -ie 's|Include /private/etc/apache2/other/*.conf|#Include /private/etc/apache2/other/*.conf|g' $Acnf

echo '
NameVirtualHost *:80

<Directory /www>
        Options FollowSymLinks
        Options Indexes
        AllowOverride All
        Order allow,deny
        Allow from all
        AddType application/x-httpd-php .php
</Directory>' >> $Acnf


#sed -e '/#.*$/ d' $Acnf
echo 'Include /etc/apache2/sites-enabled/*' >> $Acnf
echo 'Include /usr/local/phpmyadmin/apache.conf' >> $Acnf
mkdir -p /www/localhost
chmod -R 777 /www
mkdir -p /etc/apache2/sites-enabled/
echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /www/localhost/


<Directory /www/localhost>
        Options FollowSymLinks
        Options Indexes
        AllowOverride All
        Order allow,deny
        Allow from all
</Directory>
</VirtualHost>
' > /etc/apache2/sites-enabled/100-default 
echo '<?php echo "Hello World!"; ?>' > /www/localhost/index.php


echo "
##############################
#     Конфигурируем PHP!    ##
##############################
"
cp /etc/php.ini.default /etc/php.ini
sed -ie "s/pdo_mysql.default_socket.*$/pdo_mysql.default_socket = \/tmp\/mysql.sock/g" /etc/php.ini
sed -ie "s/mysql.default_socket.*$/mysql.default_socket = \/tmp\/mysql.sock/g" /etc/php.ini
sed -ie "s/mysqli.default_socket.*$/mysqli.default_socket = \/tmp\/mysql.sock/g" /etc/php.ini
sed -ie "s/short_open_tag.*$/short_open_tag = On/g" /etc/php.ini
sed -ie "s/mysql.default_port.*$/mysql.default_port = 3306/g" /etc/php.ini


killall -9 httpd
apachectl restart
/usr/local/mysql/support-files/mysql.server stop
/usr/local/mysql/support-files/mysql.server start
cd ../
rm -r $My_tmp



