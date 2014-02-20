#!/bin/bash
#config
d_prefix=".loc"
vh_prefix="200-"
default_vh_file="000-default"
d_www="/www"
s_h="start auto web"
e_h="end auto web"
hf="/etc/hosts"
sites_enabled_path="/etc/apache2/sites-enabled"
#end-config

rm $sites_enabled_path/$vh_prefix* #удаляем vhost конфиги пользовательских сайтов
sed -ie "/\#$s_h/,/\#$e_h/ d" $hf #удаляем из файла hosts строки, созданные раннее скриптом
echo '#'$s_h>>$hf;cd $d_www
ls -d */|sed -e '/^.*localhost.*$/ d;s|/$||g'|while read l;do           
echo "127.0.0.1 $l$d_prefix">>$hf
sed -e "/ServerName.*\$/d;/ServerAlias.*\$/d;s|DocumentRoot.*|DocumentRoot $d_www/$l|;s|<Directory.*|<Directory $d_www/$l>|" "$sites_enabled_path/$default_vh_file" | sed -e "/<V.*/ a\ 
ServerName $l$d_prefix
"|sed -e "/ServerName.*\$/ a\ 
ServerAlias www.$l$d_prefix" > "$sites_enabled_path/$vh_prefix$l$d_prefix"
done
echo '#'$e_h>>$hf
