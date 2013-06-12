#!/bin/bash
# installOSCAD.sh is a script file to install OSCAD software. It is written by Yogesh Dilip Save (yogessave@gmail.com).  
# Copyright (C) 2012 Yogesh Dilip Save, FOSS Project, IIT Bombay.
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

function proxy
{
echo -n 'Login@netmon :'
read username
echo -n 'Passwd :'
stty -echo
read passwd
stty echo
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset ftp_proxy
unset FTP_PROXY
export http_proxy=http://$username:$passwd@netmon.iitb.ac.in:80
export https_proxy=http://$username:$passwd@netmon.iitb.ac.in:80
export HTTP_PROXY=http://$username:$passwd@netmon.iitb.ac.in:80
export HTTPS_PROXY=http://$username:$passwd@netmon.iitb.ac.in:80
export ftp_proxy=http://$username:$passwd@netmon.iitb.ac.in:80
export FTP_PROXY=http://$username:$passwd@netmon.iitb.ac.in:80
echo
}

function checkScilabVersion
{
  version=`$1 -version |grep scilab |cut -d '-' -f2`
  version=`echo $version | sed 's/\.//g'`
  if [ "$version" -ge "540" ]
  then
    echo "  scilab version 5.4 or above detected."
    return 0
  else
    return 1
  fi
}

function checkMetanet
{
  eval $1 -nw -f checkMetanet.sci
  RetVal=$?
  if [ $RetVal -ne 0 ]
  then
    echo "No Metanet graph library found"
    echo "Trying to install metanet library........" 
    echo -n "Do you want to set proxy for internet connection(y/n): "
    read setProxy

    if [ $setProxy = 'y' -o $setProxy = 'Y' ]
    then
      proxy
    fi
    eval $1 -nw -f installMetanet.sci
    RetVal=$?
    if [ $RetVal -ne 0 ]
    then
        echo "  Unable to install Metanet "
        echo "  Please install metanet manually. "
        echo "  To install metanet use command atomInstall(\"metanet\")"
    fi 
  fi
}

linuxVersion=`uname -m`
echo "Checking eeschema ......................"
command -v eeschema >/dev/null 2>&1
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  echo "Found eeschema."
else
  ./installModule.sh kicad 
  command -v eeschema >/dev/null 2>&1
  RetVal=$?
  if [ $RetVal -ne 0 ] 
  then 
    echo "Unable to install  Kicad"
    echo "Require eeschema but it's not installed. Aborting." >&2; exit 1; 
  fi
fi

echo "Checking pcbnew ......................"
command -v pcbnew >/dev/null 2>&1 
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  echo "Found pcbnew."
else
  echo "Require pcbnew but it's not installed. Aborting." >&2; exit 1; 
fi

echo "Checking cvpcb ......................"
command -v cvpcb >/dev/null 2>&1 
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  echo "Found cvpcb."
else
  echo "Require cvpcb but it's not installed. Aborting." >&2; exit 1; 
fi

echo "Checking ngspice ......................"
command -v ngspice >/dev/null 2>&1 
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  echo "Found ngspice."
else
  ./installModule.sh ngspice 
  command -v ngspice >/dev/null 2>&1
  RetVal=$?
  if [ $RetVal -ne 0 ] 
  then 
    echo "Unable to install  ngspice"
    echo "Require ngspice but it's not installed. Aborting." >&2; exit 1; 
  fi
fi

echo "Checking python ......................"
command -v python >/dev/null 2>&1 
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  echo "Found python."
else
  ./installModule.sh python 
  command -v python >/dev/null 2>&1
  RetVal=$?
  if [ $RetVal -ne 0 ] 
  then 
    echo "Unable to install python"
    echo "Require python but it's not installed. Aborting." >&2; exit 1; 
  fi
fi

echo "Checking python Modules......................"
./checkPythonModules.py
RetVal=$?
[ $RetVal -eq 0 ] && echo "All python modules are available"
[ $RetVal -eq 1 ] && { echo "Some python modules are not available. Kindly install them"; exit 1; }
[ $RetVal -ne 1 ] && [ $RetVal -ne 0 ] && { echo "Unable to check modules"; exit 1; } 

echo "Checking scilab ......................"
command -v scilab >/dev/null 2>&1
RetVal=$?
if [ $RetVal -eq 0 ] 
then 
  scilabPATH="/usr/bin/scilab"
  echo "Found scilab."
  echo  "Checking scilab version......................"
  checkScilabVersion "$scilabPATH" 
  RetVal=$?
  if [ $RetVal -eq 0 ]
  then
    echo  "Checking Metanet ......................"
    checkMetanet "$scilabPATH"
  else
    echo -e " \e[1m Require scilab version 5.4 or above \e[0m"  
    echo -n "Do you have scilab5.4 or above? (y/n) "
    read response
    if [ $response = 'y' -o $response = 'Y' ]
    then
      echo -n "Please give path of scilab installation directory (e.g., $HOME/Downloads/scilab-5.4.0):"
      read scilabInstallDir 
      if [ -z $scilabInstallDir ]
      then 
         scilabInstallDir=$HOME/Downloads/scilab-5.4.0
      fi
      echo "Checking scilab ......................"
      command -v $scilabInstallDir/bin/scilab >/dev/null 2>&1
      RetVal=$?
      if [ $RetVal -eq 0 ]
      then
        echo "Found scilab."
        scilabPATH="$scilabInstallDir/bin/scilab"
        echo  "Checking scilab version......................"
        checkScilabVersion "$scilabInstallDir/bin/scilab" 
        RetVal=$?
        if [ $RetVal -eq 0 ]
        then
          echo  "Checking Metanet ......................"
          checkMetanet "$scilabInstallDir/bin/scilab"
        else
          echo -e " \e[1m Require scilab version 5.4 or above \e[0m"  
        fi
      else 
        echo -e " \e[1m Unable to find scilab5.4.0 or above in the specified location \e[0m"
        echo " Please re-run install_OSCAD.sh and Give correct path"
        exit 1   
      fi
    else 
      if [ $linuxVersion = "x86_64" ]
      then
        echo -e " \e[1m Please download scilab 5.4.0 for 64 bits (Linux) from http://www.scilab.org/products/scilab/download \e[0m"
      else
        echo -e " \e1m' Please download scilab 5.4.0 for 32 bits (Linux) from http://www.scilab.org/products/scilab/download '\e[0m'"
      fi
      echo " And re-run install_OSCAD.sh "
      exit 1   
    fi
  fi
else 
  echo "Require scilab version 5.4 or above"  
  echo -n "Do you have scilab5.4 or above? (y/n) "
  read response
  if [ $response = 'y' -o $response = 'Y' ]
  then
    echo -n "Please give path of scilab installation directory (e.g., $HOME/Downloads/scilab5.4.0):"
    read scilabInstallDir 
    if [ -z $scilabInstallDir ]
    then 
       scilabInstallDir=$HOME/Downloads/scilab-5.4.0
    fi
    echo "Checking scilab ......................"
    command -v $scilabInstallDir/bin/scilab >/dev/null 2>&1
    RetVal=$?
    if [ $RetVal -eq 0 ]
    then
      echo "Found scilab."
      scilabPATH="$scilabInstallDir/bin/scilab"
      echo  "Checking scilab version......................"
      checkScilabVersion "$scilabInstallDir/bin/scilab" 
      RetVal=$?
      if [ $RetVal -eq 0 ]
      then
        echo  "Checking Metanet ......................"
        checkMetanet "$scilabInstallDir/bin/scilab"
      else
        echo -e " \e[1m Require scilab version 5.4 or above \e[0m"  
      fi
    else 
      echo -e " \e[1m Unable to find scilab5.4.0 or above in the specified location \e[0m"
      echo " Please re-run install_OSCAD.sh and Give correct path"
      exit 1   
    fi
  else 
    if [ $linuxVersion = "x86_64" ]
    then
      echo -e " \e[1m Please download scilab 5.4.0 for 64 bits (Linux) from http://www.scilab.org/products/scilab/download \e[0m"
    else
      echo -e " \e1m' Please download scilab 5.4.0 for 32 bits (Linux) from http://www.scilab.org/products/scilab/download '\e[0m'"
    fi
    echo " And re-run install_OSCAD.sh "
    exit 1   
  fi
fi

echo -n "Please select installation directory (e.g., $HOME): "
read installDir 
if [ -z $installDir ]
then 
   installDir=$HOME
fi

if [ -d $installDir ]
then
  echo 'Directory found'
else
  echo 'Directory not found!'
  echo -n 'Do you want to create it?(y/n)'
  read response
  if [ $response = 'y' -o $response = 'Y' ]
  then
    if [ `mkdir -p $installDir` ]
    then 
      exit 1
    fi
  else
    echo 'Installation aborted'
    exit 1
  fi
fi
echo "Installation started..............."
tar -zxvf OSCAD.tgz -C $installDir
cp $installDir/OSCAD/setPathInstall.py $installDir/OSCAD/setPath.py
sed -i 's@set_PATH_to_OSCAD@"'$installDir'/OSCAD"@g' $installDir/OSCAD/setPath.py
cp $installDir/OSCAD/LPCSim/LPCSim/MainInstall.sci  $installDir/OSCAD/LPCSim/LPCSim/Main.sci
sed -i 's@set_PATH_to_OSCAD@"'$installDir'/OSCAD"@g' $installDir/OSCAD/LPCSim/LPCSim/Main.sci
chmod 755 $installDir/OSCAD/analysisInserter/*.py
chmod 755 $installDir/OSCAD/forntEnd/*.py
chmod 755 $installDir/OSCAD/kicadtoNgspice/*.py
chmod 755 $installDir/OSCAD/modelEditor/*.py
chmod 755 $installDir/OSCAD/subcktEditor/*.py
ln -sf $scilabPATH $installDir/OSCAD/bin/scilab54
sudo ln -sf $installDir/OSCAD/forntEnd/oscad.py /usr/bin/oscad
echo "Installation completed"

ln -sf $installDir/OSCAD/forntEnd/oscad.py $HOME/Desktop/oscad

