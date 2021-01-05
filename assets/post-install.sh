#!/bin/bash
###############################################################################
##                                                                           ##
## Auteur : José GIL                                                         ##
##                                                                           ## 
## Synopsis : Script d’installation et de configuration automatique d'un     ##
##            serveur LAMP (Apache, MariaDB, PHP et phpMyAdmin) avec les     ##
##            dernières versions.                                            ##
##                                                                           ##
## Date : 18/10/2020                                                         ##
##                                                                           ##
## Scénario :                                                                ##
##      1. Mise à jour des paquets et du système si besoin                   ##
##      2. Installation de Apache, MariaDB, et PHP                           ##
##      3. Installation de phpMyAdmin                                        ##
##      4. Import des sources de GSB Appli frais                             ##
##      5. Import de la base de données de GSB Appli frais                   ##
##      6. Génération des données de tests (jeu d'essai)                     ##
##                                                                           ##
###############################################################################

# Test pour savoir si exécute le script en tant que root, sinon sudo !
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# Sortir du script en cas d'erreur
set -e

# Variables 
FICHIER_DE_LOG="`echo $HOME`/post-install.log"
MOT_DE_PASSE_ADMIN_MARIADB="P@ssw0rdMariaDB"
MOT_DE_PASSE_PMA="motdepasse"

# Création du fichier de log
if [ ! -f $FICHIER_DE_LOG ]
then
    touch $FICHIER_DE_LOG
fi

# Fonction pour l'affichage écran et la journalisation dans un fichier de log
suiviInstallation() 
{
    echo "# $1"
	${SUDO} echo "# $1" &>>$FICHIER_DE_LOG
    ${SUDO} bash -c 'echo "#####" `date +"%d-%m-%Y %T"` "$1"' &>>$FICHIER_DE_LOG
}

# Fonction qui gère l'affichage d'un message de réussite
toutEstOK()
{
    echo -e "  '--> \e[32mOK\e[0m"
}

# Fonction qui gère l'affichage d'un message d'erreur et l'arrêt du script en cas de problème
erreurOnSort()
{
    echo -e "\e[41m" `${SUDO} tail -1 $FICHIER_DE_LOG` "\e[0m"
    echo -e "  '--> \e[31mUne erreur s'est produite\e[0m, consultez le fichier \e[93m$FICHIER_DE_LOG\e[0m pour plus d'informations"
    exit 1
}

# Mise à jour de la liste des paquets et mise à jour de l'installation si besoin (2 opérations)
suiviInstallation "Mise à jour de la liste des paquets et mise à jour de l'installation si besoin (2 opérations)" 
${SUDO} apt-get -y update &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort 
${SUDO} apt-get -y upgrade &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Installation des prérequis pour l'installation de paquets issus de dépôts personnalisés
suiviInstallation "Installation des prérequis pour l'installation de paquets issus de dépôts personnalisés"
${SUDO} apt-get -y install apt-transport-https lsb-release ca-certificates curl &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Import des clés de signature des paquets sury.org/php (mainteneur dernière version de PHP/Debian)
suiviInstallation "Import des clés de signature des paquets sury.org/php (mainteneur dernière version de PHP/Debian)"
${SUDO} wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Ajout du dépôt dans nos sources d'installation
suiviInstallation "Ajout du dépôt dans nos sources d'installation"
${SUDO} bash -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Mise à jour de la liste des paquets et mise à jour de l'installation si besoin (2 opérations)
suiviInstallation "Mise à jour de la liste des paquets et mise à jour de l'installation si besoin (2 opérations)" 
${SUDO} apt-get -y update &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort 
${SUDO} apt-get -y upgrade &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Installation des services Apache, MariaDB et PHP
suiviInstallation "Installation des services Apache, MariaDB et PHP"
${SUDO} apt-get -y install apache2 mariadb-server php libapache2-mod-php php-mysql &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Création d'un compte admin pour l'administration de MariaDB
suiviInstallation "Création d'un compte admin pour l'administration de MariaDB"
${SUDO} mariadb -u root -e "CREATE USER admin@'%'; GRANT ALL PRIVILEGES ON *.* to admin@'%' IDENTIFIED BY '$MOT_DE_PASSE_ADMIN_MARIADB' WITH GRANT OPTION; FLUSH PRIVILEGES;" &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Installation de phpMyAdmin
suiviInstallation "Téléchargement de l'archive sur phpmyadmin.net"
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Décompression de l'archive"
tar -xzf phpMyAdmin-latest-all-languages.tar.gz --one-top-level=phpmyadmin --strip-components=1 &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Placement de phpMyAdmin dans le répertoire d'hébergement"
${SUDO} mv phpmyadmin /var/www/html/ &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Création de la base phpmyadmin pour les besoins interne de phpmyadmin (2 opérations)"
${SUDO} mariadb -u root -e "CREATE DATABASE phpmyadmin DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL ON phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY '$MOT_DE_PASSE_PMA'; FLUSH PRIVILEGES;" &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
mysql -u admin -p${MOT_DE_PASSE_ADMIN_MARIADB} < /var/www/html/phpmyadmin/sql/create_tables.sql &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Modification du fichier config.inc.php (24 opérations)"
${SUDO} mv /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/^\$cfg\['blowfish_secret'] = '';/\$cfg\['blowfish_secret'] = 'IL_FAUT_32_CARACTERES_AZERTYUIOP';/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['controluser'] = 'pma'/\$cfg\['Servers']\[\$i]\['controluser'] = 'phpmyadmin'/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['controlpass'] = 'pmapass'/\$cfg\['Servers']\[\$i]\['controlpass'] = '$MOT_DE_PASSE_PMA'/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['pmadb']/\$cfg\['Servers']\[\$i]\['pmadb']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['bookmarktable']/\$cfg\['Servers']\[\$i]\['bookmarktable']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['relation']/\$cfg\['Servers']\[\$i]\['relation']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['table_info']/\$cfg\['Servers']\[\$i]\['table_info']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['table_coords']/\$cfg\['Servers']\[\$i]\['table_coords']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['pdf_pages']/\$cfg\['Servers']\[\$i]\['pdf_pages']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['column_info']/\$cfg\['Servers']\[\$i]\['column_info']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['history']/\$cfg\['Servers']\[\$i]\['history']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['table_uiprefs']/\$cfg\['Servers']\[\$i]\['table_uiprefs']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['tracking']/\$cfg\['Servers']\[\$i]\['tracking']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['userconfig']/\$cfg\['Servers']\[\$i]\['userconfig']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['recent']/\$cfg\['Servers']\[\$i]\['recent']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['favorite']/\$cfg\['Servers']\[\$i]\['favorite']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['users']/\$cfg\['Servers']\[\$i]\['users']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['usergroups']/\$cfg\['Servers']\[\$i]\['usergroups']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['navigationhiding']/\$cfg\['Servers']\[\$i]\['navigationhiding']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['savedsearches']/\$cfg\['Servers']\[\$i]\['savedsearches']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['central_columns']/\$cfg\['Servers']\[\$i]\['central_columns']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['designer_settings']/\$cfg\['Servers']\[\$i]\['designer_settings']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} sed -i -e "s/\/\/ \$cfg\['Servers']\[\$i]\['export_templates']/\$cfg\['Servers']\[\$i]\['export_templates']/" /var/www/html/phpmyadmin/config.inc.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Création du répertoire pour les templates temporaires de phpmyadmin (2 opérations)"
${SUDO} mkdir /var/www/html/phpmyadmin/tmp &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} chown -R www-data:www-data /var/www/html/phpmyadmin/tmp &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
suiviInstallation "Installation des extensions php- pour phpmyadmin (2 opérations, 6 extensions supplémentaires)"
# Voir la doc officielle : https://docs.phpmyadmin.net/fr/latest/require.html#php
${SUDO} apt-get -y install php-json php-mbstring php-zip php-gd php-xml php-curl &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} service apache2 reload &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Importation des datas dans le SGBD
suiviInstallation "Importation des datas dans le SGBD"
wget http://gil83.fr/si7/gsb_restore.sql &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
mysql -u admin -p${MOT_DE_PASSE_ADMIN_MARIADB} < gsb_restore.sql &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Génération du jeu d'essai
suiviInstallation "Génération du jeu d'essai"
cd /var/www/html/tests/gendatas/
${SUDO} sed -i -e "s/'root', ''/'userGsb', 'secret'/" majGSB.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort
${SUDO} php majGSB.php &>>$FICHIER_DE_LOG && toutEstOK || erreurOnSort

# Fin
suiviInstallation "Le serveur est prêt !"

# TODO ;-)
# suiviInstallation "Connectez-vous à l'adresse http://${IP}/" && exit 0

