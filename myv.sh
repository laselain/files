#!/bin/bash

# myv.sh (Batch Shell Script for rploader.sh)                 
# Made by Peter Suh
# 2022.04.18                      

##### INCLUDES #########################################################################################################
source myfunc.h # my.sh / myv.sh common use 
########################################################################################################################
                                                                                        
mshellgz="my.sh.gz"
mshtarfile="https://raw.githubusercontent.com/PeterSuh-Q3/tinycore-redpill/main/my.sh.gz"

# ==============================================================================                                        
# Color Function                                                                                                        
# ==============================================================================                                        
cecho () {                                                                                                              
#    if [ -n "$3" ]                                                                                                      
#    then                                                                                                                
#        case "$3" in                                                                                                    
#            black  | bk) bgcolor="40";;                                                                                 
#            red    |  r) bgcolor="41";;                                                                                 
#            green  |  g) bgcolor="42";;                                                                                 
#            yellow |  y) bgcolor="43";;                                                                                 
#            blue   |  b) bgcolor="44";;                                                                                 
#            purple |  p) bgcolor="45";;                                                                                 
#            cyan   |  c) bgcolor="46";;                                                                                 
#            gray   | gr) bgcolor="47";;                                                                                 
#        esac                                                                                                            
#    else                                                                                                                
        bgcolor="0"                                                                                                     
#    fi                                                                                                                  
    code="\033["                                                                                                        
    case "$1" in                                                                                                        
        black  | bk) color="${code}${bgcolor};30m";;                                                                    
        red    |  r) color="${code}${bgcolor};31m";;                                                                    
        green  |  g) color="${code}${bgcolor};32m";;                                                                    
        yellow |  y) color="${code}${bgcolor};33m";;                                                                    
        blue   |  b) color="${code}${bgcolor};34m";;                                                                    
        purple |  p) color="${code}${bgcolor};35m";;                                                                    
        cyan   |  c) color="${code}${bgcolor};36m";;                                                                    
        gray   | gr) color="${code}${bgcolor};37m";;                                                                    
    esac                                                                                                                
                                                                                                                        
    text="$color$2${code}0m"                                                                                            
    echo -e "$text"                                                                                                     
}            

# Function EXDRIVER_FN
# Made by FOXBI
# 2022.04.14
# ==============================================================================
# Extension Driver Function
# ==============================================================================
function EXDRIVER_FN() {

    # ==============================================================================
    # Clear extension & install extension driver
    # ==============================================================================
    echo
    cecho c "Delete extension file..."
    sudo rm -rf ./redpill-load/custom/extensions/*
    echo
#    cecho c "Update ext-manager..."
#    ./redpill-load/ext-manager.sh update

    echo    
    cecho r "Add to Driver Repository..."
    echo
    READ_YN "Do you want Add Driver? Y/N :  "
    ICHK=$Y_N
    while [ "$ICHK" == "y" ] || [ "$ICHK" == "Y" ]
    do
        ICNT=
        JCNT=
        IRRAY=()
        while read LINE_I;
        do
            ICNT=$(($ICNT + 1))
            JCNT=$(($ICNT%5))
            if [ "$JCNT" -eq "0" ]
            then
                IRRAY+=("$ICNT) $LINE_I\ln");
            else
                IRRAY+=("$ICNT) $LINE_I\lt");
            fi
        done < <(curl --no-progress-meter https://github.com/PeterSuh-Q3/rp-ext | grep "raw.githubusercontent.com" | awk '{print $2}' | awk -F= '{print $2}' | sed "s/\"//g" | awk -F/ '{print $7}')
            echo ""
            echo -e " ${IRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t\t/g'
            echo ""
            read -n100 -p " -> Select Number Enter (To select multiple, separate them with , ): " I_O
            echo ""
            I_OCHK=`echo $I_O | grep , | wc -l`
            if [ "$I_OCHK" -gt "0" ]
            then
                while read LINE_J;
                do
                    j=$((LINE_J - 1))
                    IEXT=`echo "${IRRAY[$j]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`

		    if [ $TARGET_REVISION == "42218" ] ; then
                        ./rploader.sh ext ${TARGET_PLATFORM}-7.0.1-${TARGET_REVISION}-JUN add https://raw.githubusercontent.com/PeterSuh-Q3/rp-ext/master/$IEXT/rpext-index.json    
		    else
	    		./rploader.sh ext ${TARGET_PLATFORM}-7.1.1-${TARGET_REVISION} add https://raw.githubusercontent.com/PeterSuh-Q3/rp-ext/master/$IEXT/rpext-index.json
	    	    fi

                done < <(echo $I_O | tr ',' '\n')
            else
                I_O=$(($I_O - 1))
                for (( i = 0; i < $ICNT; i++)); do
                    if [ "$I_O" == $i ]
                    then
                        export IEXT=`echo "${IRRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                    fi
                done

		if [ $TARGET_REVISION == "42218" ] ; then
		    ./rploader.sh ext ${TARGET_PLATFORM}-7.0.1-${TARGET_REVISION}-JUN add https://raw.githubusercontent.com/PeterSuh-Q3/rp-ext/master/$IEXT/rpext-index.json    
    	        else
		    ./rploader.sh ext ${TARGET_PLATFORM}-7.1.1-${TARGET_REVISION} add https://raw.githubusercontent.com/PeterSuh-Q3/rp-ext/master/$IEXT/rpext-index.json
	        fi
		
            fi
        echo
        READ_YN "Do you want add driver? Y/N :  "
        ICHK=$Y_N
    done
}

checkinternet() {

    echo -n "Checking Internet Access -> "
    curl -L https://github.com/about.html -O 2>&1 >/dev/null

    if [ $? -eq 0 ]; then
        echo "OK"
    else
        cecho g "Error: No internet found, or github.com is not accessible"
        exit 99
    fi

}

checkinternet
getlatestmshell

if [ $# -lt 1 ]; then
    showhelp
    exit 99
fi

getvars "$1"

curl --location --progress-bar "https://github.com/PeterSuh-Q3/tinycore-redpill/raw/main/custom_config.json" -O
curl --location --progress-bar "https://github.com/PeterSuh-Q3/tinycore-redpill/raw/main/custom_config_jun.json" -O	
curl --location --progress-bar "https://github.com/PeterSuh-Q3/rp-ext/raw/main/rpext-index.json" -O

cecho y "Adding Ext in progress..."                                                                                                                                     
                                                                                                                                                                        
EXDRIVER_FN

if [ ! -f my.sh ]; then
    echo "my.sh file not found, trying to download"
    curl --location "https://github.com/PeterSuh-Q3/tinycore-redpill/raw/main/my.sh.gz" --output my.sh.gz
    tar -zxvf my.sh.gz
fi


cecho g "Call my.sh now..."
./my.sh $@ frmyv

exit 0
