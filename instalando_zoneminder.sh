!/bin/bash
HORAINICIAL=`date +%T`
#
# Vari�veis para validar o ambiente, verificando se o usu�rio e "root", vers�o do ubuntu e kernel
# op��es do comando id: -u (user), op��es do comando: lsb_release: -r (release), -s (short), 
# op�es do comando uname: -r (kernel release), op��es do comando cut: -d (delimiter), -f (fields)
# op��o do caracter: | (piper) Conecta a sa�da padr�o com a entrada padr�o de outro comando
USUARIO=`id -u`
UBUNTU=`lsb_release -rs`
KERNEL=`uname -r | cut -d'.' -f1,2`
#
# Vari�vel do caminho do Log dos Script utilizado nesse curso (VARI�VEL MELHORADA)
# op��es do comando cut: -d (delimiter), -f (fields)
# $0 (vari�vel de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variaveis para cria��o da Base de Dados do ZoneMinder
USER="root"
PASSWORD="lepo@lepo"
DATABASE="/usr/share/zoneminder/db/zm_create.sql"
GRANTALL="GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost' IDENTIFIED by 'zmpass';"
FLUSH="FLUSH PRIVILEGES;"
#
# Declarando a vari�vel de PPA do ZoneMinder
ZONEMINDER="ppa:iconnor/zoneminder-master"
#
# Verificando se o usu�rio e Root, Distribui��o e >=18.04 e o Kernel >=4.15 <IF MELHORADO)
# && = operador l�gico AND, == compara��o de string, exit 1 = A maioria dos erros comuns na execu��o
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" >= "18.04" ] && [ "$KERNEL" >= "4.15" ]
	then
		echo -e "O usu�rio e Root, continuando com o script..."
		echo -e "Distribui��o e >=18.04.x, continuando com o script..."
		echo -e "Kernel e >= 4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usu�rio n�o e Root ($USUARIO) ou Distribui��o n�o e >=18.04.x ($UBUNTU) ou Kernel n�o e >=4.15 ($KERNEL)"
		echo -e "Caso voc� n�o tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando se as depend�ncais do ZoneMinder est�o instaladas
# op��o do dpkg: -s (status), op��o do echo: -e (intepretador de escapes de barra invertida), -n (permite nova linha), \n (new line)
# || (operador l�gico OU), 2> (redirecionar de sa�da de erro STDERR), && = operador l�gico AND
echo -n "Verificando as depend�ncias, aguarde... "
	for name in apache2 mysql-server mysql-common software-properties-common
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";deps=1; }
	done
		[[ $deps -ne 1 ]] && echo "Depend�ncias.: OK" || { echo -en "\nInstale as depend�ncias acima e execute novamente este script\n";exit 1; }
		sleep 5
#		
# Script de instala��o do ZoneMinder no GNU/Linux Ubuntu Server 18.04.x
# op��o do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# op��o do comando hostname: -I (all IP address)
# op��o do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "In�cio do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instala��o do ZoneMinder no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Ap�s a instala��o do ZoneMinder acessar a URL: http://`hostname -I`/zm/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
#
echo -e "Adicionando o Reposit�rio Universal do Apt, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	add-apt-repository universe &>> $LOG
echo -e "Reposit�rio adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��o do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecess�rios, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��o do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o ZoneMinder, aguarde..."
echo
#
echo -e "Adicionando o PPA do ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��o do comando echo |: (faz a fun��o do Enter)
	echo | sudo add-apt-repository $ZONEMINDER &>> $LOG
echo -e "PPA adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando novamente as listas do Apt, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando as Configura��es do Servidor de MySQL, perssione <Enter> para continuar"
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	#[mysqld]
	#sql_mode = NO_ENGINE_SUBSTITUTION
	read
	nano /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo service mysql restart &>> $LOG
echo -e "Banco de Dados editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando as Configura��es do PHP, perssione <Enter> para continuar"
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	#Procurar: [Date]
	#date.timezone = America/Recife
	read
	nano /etc/php/7.2/apache2/php.ini
echo -e "Arquivo do PHP editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��o do comando apt: -y (yes)
	apt -y install zoneminder &>> $LOG
echo -e "ZoneMinder instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Banco de Dados do ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��o do comando mysql: -u (user), -p (password), -e (execute), < (Redirecionador de Sa�da STDOUT)
	mysql -u $USER -p$PASSWORD < $DATABASE &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Alterando as permiss�es do ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# op��es do comando chmod: -v (verbose), 740 (dono=RWX,grupo=R,outro=)
	# op��es do comando chown: -v (verbose), -R (recursive), root (dono), www-data (grupo)
	# op��es do comando usermod: -a (append), -G (group), video (grupo), www-data (user)
	chmod -v 740 /etc/zm/zm.conf &>> $LOG
	chown -v root.www-data /etc/zm/zm.conf &>> $LOG
	chown -Rv www-data.www-data /usr/share/zoneminder/ &>> $LOG
	usermod -a -G video www-data &>> $LOG
echo -e "Permiss�es alteradas com sucesso com sucesso!!!, continuando com o script..."
sleep 5
echo
#
#
echo -e "Habilitando os recursos do Apache2 para o ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	# a2enmod (Apache2 Enable Mode), a2enconf (Apache2 Enable Conf)
	a2enmod cgi &>> $LOG
	a2enmod rewrite &>> $LOG
	a2enconf zoneminder &>> $LOG
	service apache2 restart &>> $LOG
echo -e "Recurso habilitado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
#
echo -e "Criando o Servi�o do ZoneMinder, aguarde..."
	# op��o do comando: &>> (redirecionar a sa�da padr�o)
	systemctl enable zoneminder &>> $LOG
	service zoneminder start &>> $LOG
echo -e "Servi�o criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instala��o do ZoneMinder feita com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# op��o do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# op��o do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# op��o do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (vari�vel de ambiente do nome do comando)
	echo -e "Tempo gasto para execu��o do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# op��o do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1