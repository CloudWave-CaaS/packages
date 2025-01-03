#!/bin/bash
#This Source Code Form is subject to the terms of the Mozilla
#Public License, v. 2.0. If a copy of the MPL was not distributed
#with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

check_py_ver(){
	if [ "$1" ]; then
		if [ -f "$1" ]; then
			PYVER=$($1 --version 2>&1)
			PYV=$(echo $PYVER | sed 's/.* \([0-9]\).\([0-9]*\).*/\1\2/')
			if [ "$PYV" -ge "36" ] || [ "$PYV" -eq "27" ]; then
				echo "$PYVER"				
				return 0
			fi
		fi
	fi
	return 1
}

if [ "$1" = "-pypath" ]; then
	PYPTH=$2
	check_py_ver $PYPTH
	if [ "$?" = "1" ]; then
		echo "Error: Missing or Invalid Python. Required version 3.6+ or 2.7. Try to use -pypath <path>"
		exit 1
	fi
else
	PYPTH=$(which "python3" 2>/dev/null)
	check_py_ver $PYPTH
	if [ "$?" = "1" ]; then
		PYPTH=$(which "python2.7" 2>/dev/null)
		check_py_ver $PYPTH
		if [ "$?" = "1" ]; then
			echo "Error: Missing or Invalid Python. Required version 3.6+ or 2.7. Try to use -pypath <path>"
			exit 1
		fi
	fi
fi

echo "Extracting file ..."
SKIP=`awk '/^__TARFILE_BEGIN__/ { print NR + 1; exit 0; }' $0`
APPDT=$(date +"%Y%m%d%H%M%S")
PATH_INSTALL="/tmp/dwagent_install$APPDT"
THIS=`readlink -f $0`
rm -r -f $PATH_INSTALL
mkdir $PATH_INSTALL
cd $PATH_INSTALL
tail -n +$SKIP $THIS | tar -x
chown $(id -u):$(id -g) $PATH_INSTALL -R
echo "Running installer ..."
export PYTHONIOENCODING=utf-8
$PYPTH installer.py $@
echo "Removing temp directory ..."
rm -r -f $PATH_INSTALL
exit 0
__TARFILE_BEGIN__
cacerts.pem
