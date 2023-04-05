FROM ubuntu:bionic
RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install tzdata
RUN apt install -y software-properties-common apt-utils net-tools telnet iputils-ping wget
RUN add-apt-repository ppa:ondrej/php > /dev/null
RUN apt-get update
RUN apt-get install -y openssh-server apache2 mysql-server mysql-client \
mongodb curl sox mpg123 sqlite3 git uuid libodbc1 unixodbc unixodbc-bin \
asterisk asterisk-core-sounds-en-wav asterisk-core-sounds-en-g722 \
asterisk-dahdi asterisk-flite asterisk-modules asterisk-mp3 asterisk-mysql \
asterisk-moh-opsound-g722 asterisk-moh-opsound-wav asterisk-opus \
asterisk-voicemail dahdi dahdi-dkms dahdi-linux libapache2-mod-security2 \
php5.6 php5.6-cgi php5.6-cli php5.6-curl php5.6-fpm php5.6-gd php5.6-mbstring \
php5.6-mysql php5.6-odbc php5.6-xml php5.6-bcmath php-pear libicu-dev gcc \
g++ make libapache2-mod-php5.6 pkg-config vim
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
#RUN chown asterisk. /var/run/asterisk
RUN chown -R asterisk. /etc/asterisk
RUN chown -R asterisk. /var/lib/asterisk
RUN chown -R asterisk. /var/log/asterisk
RUN chown -R asterisk. /var/spool/asterisk
RUN chown -R asterisk. /usr/lib/asterisk
RUN chsh -s /bin/bash asterisk
RUN rm -rf /var/www/html
RUN rm -rf /etc/asterisk/ext* /etc/asterisk/sip* /etc/asterisk/pj* /etc/asterisk/iax* /etc/asterisk/manager*
RUN sed -i 's/.!.//' /etc/asterisk/asterisk.conf
RUN sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/5.6/cgi/php.ini
RUN sed -i 's/www-data/asterisk/' /etc/apache2/envvars
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN service apache2 restart
RUN sed -i 's/ each(/ @each(/' /usr/share/php/Console/Getopt.php
RUN mkdir -p /usr/lib/odbc
WORKDIR /root
RUN wget -c https://dev.mysql.com/get/Downloads/Connector-ODBC/5.3/mysql-connector-odbc-5.3.14-linux-glibc2.12-x86-64bit.tar.gz
RUN tar xzf mysql-connector-odbc-5.3.14-linux-glibc2.12-x86-64bit.tar.gz --strip-components=2
RUN cp -rp libmyodbc5a.so /usr/lib/odbc/
RUN cp -rp libmyodbc5w.so /usr/lib/odbc/
COPY odbc.ini /etc/
COPY odbcinst.ini /etc/
RUN rm -rf /var/lib/asterisk/moh
RUN ln -s /usr/share/asterisk/moh /var/lib/asterisk/moh
RUN rm -rf /usr/share/asterisk/sounds
RUN ln -s /var/lib/asterisk/sounds /usr/share/asterisk/sounds
RUN chown -R asterisk.asterisk /usr/share/asterisk

ARG MARIADB_MYSQL_SOCKET_DIRECTORY='/var/run/mysqld'
RUN mkdir -p $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chown root:mysql $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chmod 774 $MARIADB_MYSQL_SOCKET_DIRECTORY

WORKDIR /usr/src
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz
RUN tar zxf freepbx-14.0-latest.tgz
WORKDIR /usr/src/freepbx
COPY start.sh /usr/src/freepbx/
COPY modules.txt /usr/src/freepbx
RUN sed -i 's/ > \/dev\/tty//g' installlib/installcommand.class.php
RUN chmod +x /usr/src/freepbx/start.sh
RUN ./start.sh
EXPOSE 80 443
EXPOSE 5060/udp
CMD ["/sbin/init"]