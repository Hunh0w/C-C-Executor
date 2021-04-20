#!/bin/bash

##############################

function stop {
  exit 0
}

function C_compile {
  local output=$(sed 's|\.\w*$||' <<< $1)
  $2 $1 -o $output
  if [[ ! -f $output ]]; then return; fi
  chmod +x $output
  execute $output
}

function execute {
  if [[ ! -f $1 ]]; then
    echo "Le fichier $1 n'existe pas"
    return
  fi
  ./$1
  if [[ -f $1 ]] && $remove; then rm $1; fi
}

function install_prompt {
  if [[ -z $1 ]]; then return; fi
  read -p "Voulez-vous installer $1 ? [OoYy/Nn] : " -n 1 -r reply
  echo -e -n "\n"
  if [[ $reply =~ ^[YyOo]$ ]]; then apt install $1; fi
  echo -e -n "\n"
}

##############################

code=0
$(gcc -v &> /dev/null)
if [[ $? == 127 ]]; then echo -e "GCC est introuvable ! /!\\"; ((code|=1)); fi
$(g++ -v &> /dev/null)
if [[ $? == 127 ]]; then echo -e "G++ est introuvable ! /!\\"; ((code|=2)); fi
if [[ $code != 0 ]]; then
  if [[ $(($code&1)) != 0 ]]; then install_prompt "gcc"; fi
  if [[ $(($code&2)) != 0 ]]; then install_prompt "g++"; fi
fi

if [[ -z $1 ]]; then
  echo "Veuillez préciser un fichier à compiler et exécuter"
  stop
fi
if [[ ! -f $1 ]]; then
  echo "Ce fichier n'existe pas : '$1'"
  stop
fi

remove=true
for arg in $@; do
  if [[ -z $arg ]]; then continue; fi
  if [[ $arg == "-r" ]]; then remove=false; echo "rem false"; fi
done

format=$(sed 's|.*\.||' <<< $1)
if [[ $format =~ ^[Cc][Pp]{2}$ ]]; then
  C_compile $1 "g++"
elif [[ $format =~ ^[Cc]$ ]]; then
  C_compile $1 "gcc"
else
  echo "Ce format n'est pas encore reconnu"
fi
