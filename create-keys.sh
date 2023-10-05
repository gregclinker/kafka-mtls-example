#!/bin/bash

# generate root key & root CA
echo "create root"
openssl genrsa -out root.key
openssl req -new -x509 -key root.key -out root.crt -subj "/C=GB/L=London/O=Essexboy Ltd/OU=devops/CN=EssexboyRoot"
chmod 600 root.key
chmod 644 root.crt

# import root CA into truststore
echo "create server truststore and add root cert"
keytool -import -trustcacerts -keystore kafka.server.truststore.jks -storepass changeit -noprompt -alias root -file root.crt

# import root CA into truststore
echo "create client truststore and add root cert"
keytool -import -trustcacerts -keystore kafka.client.truststore.jks -storepass changeit -noprompt -alias root -file root.crt

# create server keystore, export the cert, sign it, import root CA
echo "create server keystore and sign"
keytool -keystore kafka.server.keystore.jks -storepass changeit -alias essexboy-server-1 -validity 365 -genkey -keyalg RSA -ext SAN=DNS:kafka.essexboy.com -dname "CN=Essexboy1"
keytool -keystore kafka.server.keystore.jks -storepass changeit -alias essexboy-server-1 -certreq -file kafka.unsigned.crt
openssl x509 -req -CA root.crt -CAkey root.key -in kafka.unsigned.crt -out kafka.signed.crt -days 365 -CAcreateserial
keytool -keystore kafka.server.keystore.jks -storepass changeit -alias root -import -file root.crt -noprompt
keytool -keystore kafka.server.keystore.jks -storepass changeit -alias essexboy-server-1 -import -file kafka.signed.crt -noprompt

# create client 1 keystore, export the cert, sign it, import root CA
echo "create client 1 keystore and sign"
keytool -keystore kafka.client1.keystore.jks -storepass changeit -alias essexboy-client-1 -validity 365 -genkey -keyalg RSA -ext SAN=DNS:kafka.essexboy.com -dname "CN=Essexboy1"
keytool -keystore kafka.client1.keystore.jks -storepass changeit -alias essexboy-client-1 -certreq -file kafka.unsigned.crt
openssl x509 -req -CA root.crt -CAkey root.key -in kafka.unsigned.crt -out kafka.signed.crt -days 365 -CAcreateserial
keytool -keystore kafka.client1.keystore.jks -storepass changeit -alias root -import -file root.crt -noprompt
keytool -keystore kafka.client1.keystore.jks -storepass changeit -alias essexboy-client-1 -import -file kafka.signed.crt -noprompt

# create client 2 keystore, export the cert, sign it, import root CA WILL NOT WORK BECAUSE IT HAS THE WRONG CN
echo "create client 2 keystore and sign"
keytool -keystore kafka.client2.keystore.jks -storepass changeit -alias essexboy-client-2 -validity 365 -genkey -keyalg RSA -ext SAN=DNS:kafka.essexboy.com -dname "CN=Essexboy2"
keytool -keystore kafka.client2.keystore.jks -storepass changeit -alias essexboy-client-2 -certreq -file kafka.unsigned.crt
openssl x509 -req -CA root.crt -CAkey root.key -in kafka.unsigned.crt -out kafka.signed.crt -days 365 -CAcreateserial
keytool -keystore kafka.client2.keystore.jks -storepass changeit -alias root -import -file root.crt -noprompt
keytool -keystore kafka.client2.keystore.jks -storepass changeit -alias essexboy-client-2 -import -file kafka.signed.crt -noprompt

echo ""
echo "server keystore"
keytool -list -keystore kafka.server.keystore.jks -storepass changeit

echo ""
echo "client 1 keystore"
keytool -list -keystore kafka.client1.keystore.jks -storepass changeit

echo ""
echo "client 2 keystore"
keytool -list -keystore kafka.client2.keystore.jks -storepass changeit

rm kafka.unsigned.crt kafka.signed.crt root.srl root.crt root.key
mv *.jks secrets
