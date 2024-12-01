#!/bin/bash

#Variables_globales
main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c(){
  echo -e "\n\n ${redColour} [!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

function helpPanel(){
  echo -e "${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualiza los ficheros en busca de nuevas máquinas.${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de máquina.${endColour}" 
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por una dirección IP.${endColour}" 
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar las máquinas por una dificultad.${endColour}" 
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar las máquinas por el sistema operativo.${endColour}" 
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar las máquinas por el la skill que requiere.${endColour}" 
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener el link de la resolución de la máquina.${endColour}" 
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Muestra este panel de ayuda.${endColour}\n"
}

function updateFiles(){
  tput civis
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si existen actualizaciones.${endColour}"
  if [ ! -f bundle.js ]; then 
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones.${endColour}"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios para la actualización...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados y actualizados.${endColour}"
    else
      curl -s $main_url > bundle_temp.js
      js-beautify bundle_temp.js | sponge bundle_temp.js
      md5_tmp_value=$(md5sum bundle_temp.js | awk '{print $1}')
      md5_original_value=$(md5sum bundle.js | awk '{print $1}')
      if [ "$md5_tmp_value" == "$md5_original_value" ]; then
        echo -e "${yellowColour}[+]${endColour} ${grayColour}Todos los archivos estaban al día.${endColour}"
        rm bundle_temp.js
        else
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones.${endColour}"
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Actualizando los ficheros necesarios...${endColour}"
          rm bundle.js && mv bundle_temp.js bundle.js
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados y actualizados.${endColour}"
      fi
  fi
  tput cnorm
}

function searchMachine(){
  machinesName="$1"
  listName="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
  if [ "$listName" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando los propiedades de la máquina${endColour}${blueColour} $machinesName${endColour}${grayColour}:${endColour}\n"
    listName="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
    listIp="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "ip:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
    listSO="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "so:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
    listDifficulty="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "dificultad:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
    listSkills="$(cat bundle.js | awk "/name: \"Tentacle\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "skills:" | tr -d ',' | tr -d '"' | awk '{print substr($0, index($0,$2))}')"
    listLike="$(cat bundle.js | awk "/name: \"Tentacle\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "like:" | tr -d ',' | tr -d '"' | awk '{print substr($0, index($0,$2))}')"
    listActiveDirectory="$(cat bundle.js | awk "/name: \"$machinesName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | grep "activeDirectory:" | awk '{print substr($0, index($0,$2))}' | tr -d ',' | tr -d '"')"

    echo -e "${yellowColour}[+]${endColour} ${grayColour}Nombre: ${blueColour}$listName${endColour}${endColour}"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}IP: ${blueColour}$listIp${endColour}${endColour}"
    if [ "$listSO" == "Linux" ]; then
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Sistema Operativo: ${purpleColour}$listSO${endColour}${endColour}"
    else 
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Sistema Operativo: ${greenColour}$listSO${endColour}${endColour}"
    fi
    if [ "$listDifficulty" == "Insane" -o "$listDifficulty" ==  "Difícil" ]; then
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Dificultad: ${redColour}$listDifficulty${endColour}${endColour}"

    elif [ "$listDifficulty" == "Media" ]; then
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Dificultad: ${yellowColour}$listDifficulty${endColour}${endColour}"
    else
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Dificultad: ${greenColour}$listDifficulty${endColour}${endColour}"
    fi
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Skills: ${blueColour}$listSkills${endColour}${endColour}"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Parecido: ${blueColour}$listLike${endColour}${endColour}"
    if [ "$listActiveDirectory" ]; then
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Active Directory: ${blueColour}Sí${endColour}${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}La máquina${endColour}${blueColour} $machineName ${endColour}${grayColour}no existe.${endColour}"
  fi
}

function searchIP(){
  ipAddress="$1"
  machineName=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | grep -vE "id:|sku:|ip:" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}')
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando la máquina por la IP: ${endColour}${blueColour} $ipAddress${endColour}${grayColour}:${endColour}\n"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}La IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} pertenece a la maquina:${endColour}${blueColour} $machineName ${endColour}"
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}La IP${endColour}${blueColour} $ipAddress ${endColour}${grayColour}no existe.${endColour}"
  fi
}

function getYoutubeLink(){
  machineName="$1"
  linkYoutube="$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep "youtube" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"
  if [ "$linkYoutube" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando la URL para la máquina:${endColour}${blueColour} $machineName${endColour}${grayColour}${endColour}"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Enlace:${endColour}${redColour}$linkYoutube${endColour}"
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}La máquina${endColour}${blueColour} $machineName ${endColour}${grayColour}no existe.${endColour}"
  fi
}

function searchDifficulty(){
  difficulty="$1"
  nameMachines="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)"
  if [ "$nameMachines" ]; then
    if [ "$difficulty" == "Insane" -o "$difficulty" == "Difícil"  ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas con la dificultad${endColour}${redColour} $difficulty${endColour}${grayColour}:${endColour}"
      echo -e "\n${blueColour}$nameMachines ${endColour}"
    elif [ "$difficulty" == "Media" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas con la dificultad${endColour}${yellowColour} $difficulty${endColour}${grayColour}:${endColour}"
      echo -e "\n${blueColour}$nameMachines ${endColour}"
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas con la dificultad${endColour}${greenColour} $difficulty${endColour}${grayColour}:${endColour}"
      echo -e "\n${blueColour}$nameMachines ${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}La dificultad indicada ${endColour}${redColour}$difficulty${endColour}${grayColour} es incorrecta.${endColour}"
  fi
}

function searchOS(){
  os="$1"
  nameMachines="$(cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"
  if [ "$nameMachines" ]; then
    if [ "$os" == "Linux" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas con sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${greenColour} $os${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}El sistema operativo ${endColour}${redColour}$os ${endColour}${grayColour}no existe.${endColour}"
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"
  nameMachines="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"
  if [ "$nameMachines" ]; then
    if [ "$os" == "Linux" ] && [ "$difficulty" == "Insane" -o "$difficulty" == "Difícil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${redColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    elif [ "$os" == "Linux" ] && [ "$difficulty" == "Media" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${yellowColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    elif [ "$os" == "Linux" ] && [ "$difficulty" == "Fácil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${greenColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    elif [ "$os" == "Windows" ] && [ "$difficulty" == "Insane" -o "$difficulty" == "Difícil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${greenColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${redColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    elif [ "$os" == "Windows" ] && [ "$difficulty" == "Media" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${greenColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${yellowColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquina con sistema operativo${endColour}${greenColour} $os${endColour}${grayColour} y con la dificultad ${endColour}${greenColour}$difficulty${endColour}${grayColour}:${endColour}"
      echo -e "${blueColour}$nameMachines${endColour}"
    fi 
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}El sistema operativo ${endColour}${redColour}$os${endColour}${grayColour} o la dificultad ${redColour}$difficulty ${endColour}${grayColour}no existe.${endColour}"
  fi
}

function searchSkills(){
  skill="$1"
  nameMachines="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$nameMachines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas con la skill${endColour}${turquoiseColour} $skill${endColour}${grayColour}:${endColour}"
    echo -e "${blueColour}$nameMachines${endColour}"
  else
    echo -e "\n${redColour}[!] ERROR:${endColour} ${grayColour}No se ha encontrado la Skill${endColour}${redColour} $skill${endColour}"
  fi
}

# Ctrl + C
trap ctrl_c INT

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Indicadores

declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let chivato_difficulty+=1; let parameter_counter+=5;;
    o) os="$OPTARG"; let chivato_os=+1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchOS $os
elif [ $parameter_counter -eq 7 ]; then
  searchSkills "$skill"
elif [ $chivato_os -eq 1 ] && [ $chivato_difficulty -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi

