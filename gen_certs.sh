#!/usr/bin/env bash
set -e

CERT="priv/stunnel.pem"
KEY="priv/stunnel.key"


cat << EOF 
//////////////////////////////////////////
////        //////////////////////////////
///  ////////  ////  ////    ////      ///
//      //////    ////  ////  //  ////  //
/  ////////  ////  //  ////  //  ////  ///
        //  ////  ////    ////  ////  ////
//////////////////////////////////////////
//////////////////////////////////////////

EOF

clean()
{
    echo "[!] Cleaning"
    rm -v "$CERT"
    rm -v "$KEY"
}

gen()
{
    openssl req -new -x509 -nodes -out "$CERT" -keyout "$KEY" -days 365
}
    
if [[ ! -e "$CERT" ]]
then
    echo "[!] Certificate and key not found."
    sleep 0.3
    echo "[!] Generating…"
    gen

else
    PS3="=> "
    echo "[+] Found a certificate and a key. Wyd?"
    select var in 'Generate a new pair of cert/keys' 'Use the already existing ones'
    do
        case $REPLY in
            "1") clean ; gen ; break;;
            "2") break;;
        esac
    done
fi

