#-------------------------------------------------------------------------------------------
#fgc0109 2015.11.15                                                                          
#-------------------------------------------------------------------------------------------
dividing="================================================================================" 
commandPath="steamcmd"
commandFile="./steamcmd.sh"

gamesPath="Steam/steamapps/common/Don't Starve Together Dedicated Server/bin64"
gamesFile="./dontstarve_dedicated_server_nullrenderer_x64"
#-------------------------------------------------------------------------------------------
function FilesDelete()
{
	echo -e "\033[32m[提示] 选择要删除的存档 [1-9]\033[0m"
	read input_filedelete

	if [ -d ".klei" ]; then
		cd ".klei"
		if [ -d "DoNotStarveServer_$input_filedelete" ]; then 
			sudo rm -r DoNotStarveServer_$input_filedelete/Cluster_1/Master/save
			echo -e "\033[33m[提示] 存档 DoNotStarveServer_$input_filedelete 已删除\033[0m"
		fi
		if [ -d "DoNotStarveCaves_$input_filedelete" ]; then
			sudo rm -r DoNotStarveCaves_$input_filedelete/Cluster_1/Master/save
			echo -e "\033[33m[提示] 存档 DoNotStarveCaves_$input_filedelete 已删除\033[0m"
		fi
		cd "../"
	fi
}
#-------------------------------------------------------------------------------------------
function FilesBackup()
{
	echo -e "\033[32m[提示] 选择要备份的存档 [1-5]\033[0m"
	read input_filebackup

	if [ -d ".klei" ]; then
		cd ".klei"
		if [ -d "DoNotStarveServer_$input_filebackup" ]; then
			sudo tar -zcf DoNotStarveServer_$input_filebackup.tar.gz DoNotStarveServer_$input_filebackup
			echo -e "\033[33m[提示] 存档 DoNotStarveServer_$input_filebackup 已备份\033[0m"
		fi
		if [ -d "DoNotStarveCaves_$input_filebackup" ]; then
			sudo tar -zcf DoNotStarveCaves_$input_filebackup.tar.gz DoNotStarveCaves_$input_filebackup
			echo -e "\033[33m[提示] 存档 DoNotStarveCaves_$input_filebackup 已备份\033[0m" 
		fi
		cd "../"
	fi
}
#-------------------------------------------------------------------------------------------
function FilesRecovery()
{
	echo -e "\033[32m[提示] 选择要恢复的存档 [1-5]\033[0m"
	read input_filerecovery

	if [ -d ".klei" ]; then
		cd ".klei"
		if [ -f "DoNotStarveServer_$input_filerecovery.tar.gz" ]; then
			if [ -d "DoNotStarveServer_$input_filerecovery" ]; then
				sudo rm -r DoNotStarveServer_$input_filerecovery
			fi
			sudo tar -zxf DoNotStarveServer_$input_filerecovery.tar.gz DoNotStarveServer_$input_filerecovery
			echo -e "\033[33m[提示] 存档 DoNotStarveServer_$input_filerecovery 已恢复\033[0m"
		else
			echo -e "\033[31m[注意] 备份文件 DoNotStarveServer_$input_filerecovery 未找到\033[0m"
		fi
		
		if [ -f "DoNotStarveCaves_$input_filerecovery.tar.gz" ]; then
			if [ -d "DoNotStarveCaves_$input_filerecovery" ]; then
				sudo rm -r DoNotStarveCaves_$input_filerecovery
			fi
			sudo tar -zxf DoNotStarveCaves_$input_filerecovery.tar.gz DoNotStarveCaves_$input_filerecovery
			echo -e "\033[33m[提示] 存档 DoNotStarveCaves_$input_filerecovery 已恢复\033[0m"
		else
			echo -e "\033[31m[注意] 备份文件 DoNotStarveCaves_$input_filerecovery 未找到\033[0m"
		fi
		cd "../"
	else
		echo -e "\033[31m[注意] Main Archive Folder Not Found\033[0m"
	fi
}
#-------------------------------------------------------------------------------------------
function SystemPrepsDetail()
{
	echo -e "\033[33m[提示] System Library Install\033[0m"                                
	sudo apt-get update
	sudo apt-get install screen
	sudo apt-get install lib32gcc1
	sudo apt-get install lib32stdc++6
	sudo apt-get install libcurl4-gnutls-dev:i386
	echo -e "\033[33m[提示] 运行库安装已完成\033[0m"
	echo "$dividing"
}
#-------------------------------------------------------------------------------------------
function SystemPreps()
{
	echo -e "\033[33m[提示] 运行库检测...\033[0m"                                 
	sudo apt-get update 																							1>/dev/null
	sudo apt-get install screen 																					1>/dev/null
	sudo apt-get install lib32gcc1 																					1>/dev/null
	sudo apt-get install lib32stdc++6 																				1>/dev/null
	sudo apt-get install libcurl4-gnutls-dev:i386 																	1>/dev/null
	echo -e "\033[33m[提示] 运行库准备就绪...\033[0m"
	echo "$dividing"
}
#-------------------------------------------------------------------------------------------
function CommandPreps()
{
	echo -e "\033[33m[提示] Steam Command Line Files Preparing\033[0m"
	
	if [ ! -d "$commandPath" ]; then
		mkdir "$commandPath"
	fi
	cd "$commandPath"
	
	wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz	   									1>/dev/null
	tar -xvzf steamcmd_linux.tar.gz                                                									1>/dev/null
	rm -f steamcmd_linux.tar.gz                                                    									1>/dev/null

	echo -e "\033[33m[提示] Steam Command Line Files Prepare Finished\033[0m"
	echo "$dividing"
}                                                                                           
#-------------------------------------------------------------------------------------------
function ServerStart()
{  
	echo -e "\033[32m[提示] 启动 [1.地面] [2.洞穴]\033[0m"
	read input_mode 
	echo -e "\033[32m[提示] 存档位 [1-9]\033[0m"
	read input_save 
	
	cd "$gamesPath"
	case $input_mode in  
		1)
			# 更新下载mod列表
			cd ../mods
			a=`sed -n "/workshop/p" /root/.klei/DoNotStarveServer_"$input_save"/Cluster_1/Master/modoverrides.lua|cut -d= -f1|sed "s/[^0-9]//g"`
			echo "--"`date +"%Y-%m-%d %H:%M:%S"`": DoNotStarveServer_"$input_save""  >> dedicated_server_mods_setup.lua
			for i in $a
			do
				echo "ServerModSetup("$i")" >> dedicated_server_mods_setup.lua
			done
			cd -

			sudo screen -S "DST Server" "$gamesFile" -conf_dir DoNotStarveServer_"$input_save";;
		2)
			# 更新下载mod列表
			cd ../mods
			a=`sed -n "/workshop/p" /root/.klei/DoNotStarveCaves_"$input_save"/Cluster_1/Master/modoverrides.lua|cut -d= -f1|sed "s/[^0-9]//g"`
			rm dedicated_server_mods_setup.lua
			echo "--"`date +"%Y-%m-%d %H:%M:%S"`": DoNotStarveCaves_"$input_save""  >> dedicated_server_mods_setup.lua
			for i in $a
			do
				echo "ServerModSetup("$i")" >> dedicated_server_mods_setup.lua
			done
			cd -
			
			sudo screen -S "DST Server" "$gamesFile" -conf_dir DoNotStarveCaves_"$input_save";;
		*)
			echo -e "\033[31m[注意] Illegal Command,Please Check\033[0m" ;;
	esac
	
	echo "$dividing"
	#"$gamesFile"
}
#-------------------------------------------------------------------------------------------
function ServerPreps()                                                                      
{                                                                                           
	echo -e "\033[33m[提示] Preparing Server Files\033[0m"                                  
	if [ ! -d "$commandPath" ]; then                                                        
		echo -e "\033[31m[注意] Steam Command Line Not Found\033[0m"
		CommandPreps
	else
		echo -e "\033[33m[提示] Steam Command Line Found\033[0m"
		cd "$commandPath"
	fi
	
	echo -e "\033[32m[提示] 更新 [1.地面] [2.洞穴]\033[0m"
	read input_game
  
	case $input_game in  
		1)
			"$commandFile" +login anonymous +app_update 343050 validate +quit;;
		2)
			"$commandFile" +login anonymous +app_update 343050 -beta cavesbeta validate +quit;;
		*)
			echo -e "\033[31m[注意] Illegal Command,Please Check\033[0m" ;;
	esac
	
	cd "../"
	echo "$dividing"
	ServerStart
}
#-------------------------------------------------------------------------------------------
clear
echo "$dividing"

if [ ! -d "$gamesPath" ]; then
	echo -e "\033[31m[注意] Server Files Not Found\033[0m" 
	echo "$dividing"
	SystemPrepsDetail
	ServerPreps                                                                             
else                                                                                        
	echo -e "\033[32m[提示] Server Files Found\033[0m"
	echo "$dividing"
	echo -e "\033[33m[提示] Choose An Action To Perform\033[0m"
	
	echo -e "\033[32m[提示] 所需运行库 [0.检测]\033[0m"
	echo -e "\033[32m[提示] Game Server [1.启动]  [2.更新]  [3.关闭]\033[0m"
	echo -e "\033[32m[提示] Save Files  [7.备份] [8.恢复][9.删除]\033[0m"
	read input_update 
  
	case $input_update in
		0)
			SystemPreps;;
			#SystemPrepsDetail;;
		1)
			ServerStart;;
		2)
			ServerPreps;;
		3)
			sudo killall screen;;
		7)
			FilesBackup;;
		8)
			FilesRecovery;;
		9)
			FilesDelete;;
	esac	                                                                   
fi                                                                                          

