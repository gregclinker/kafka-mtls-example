#!/bin/bash

# generate root key & root CA
echo "create root"
openssl genrsa -out root.key
openssl req -new -x509 -key root.key -out root.crt -subj "/C=GB/L=London/O=Essexboy Ltd/OU=devops/CN=EssexboyRoot"
chmod 600 root.key
chmod 644 root.crt

# import root CA into truststore
echo "create server truststore and sign"
keytool -import -trustcacerts -keystore kafka.server.truststore.jks -storepass changeit -noprompt -alias CARoot -file root.crt

# import root CA into truststore
echo "create client truststore and sign"
keytool -import -trustcacerts -keystore kafka.client.truststore.jks -storepass changeit -noprompt -alias CARoot -file root.crt

# create keystore, export the cert, sign it, import root CA, import broker certificate
echo "create server keystore and sign"
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:kafka.essexboy.com -dname "CN=Essexboy"
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -certreq -file kafka.unsigned.crt
openssl x509 -req -CA root.crt -CAkey root.key -in kafka.unsigned.crt -out kafka.signed.crt -days 365 -CAcreateserial
keytool -keystore kafka.keystore.jks -storepass changeit -alias CARoot -import -file root.crt -noprompt
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -import -file kafka.signed.crt -noprompt
rm kafka.unsigned.crt kafka.signed.crt root.srl

mv *.jks secrets
rm *.crt *.key