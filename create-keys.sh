#!/bin/bash

# generate root key & root CA
openssl genrsa -out root.key
openssl req -new -x509 -key root.key -out root.crt -subj "/C=GB/L=London/O=Essexboy Ltd/OU=devops/CN=*.*"
chmod 600 root.key
chmod 644 root.crt

# generate server key, signing request & sign request
openssl genrsa -out server.key
openssl req -new -key server.key -out server_reqout.txt -subj "/C=GB/L=London/O=Essexboy Ltd/OU=devops/CN=*.*"
openssl x509 -req -in server_reqout.txt -days 3650 -sha256 -CAcreateserial -CA root.crt -CAkey root.key -out server.crt
rm server_reqout.txt
chmod 600 server.key
chmod 644 server.crt

# generate client key, signing request & sign request
openssl genrsa -out client.key
openssl req -new -key client.key -out client_reqout.txt -subj "/C=GB/L=London/O=Essexboy Ltd/OU=devops/CN=*.*"
openssl x509 -req -in client_reqout.txt -days 3650 -sha256 -CAcreateserial -CA root.crt -CAkey root.key -out client.crt
rm client_reqout.txt
chmod 600 client.key
chmod 644 client.crt

# import root CA into truststore
keytool -import -trustcacerts -keystore kafka.truststore.jks -storepass changeit -noprompt -alias CARoot -file root.crt

# import root CA into client truststore
keytool -import -trustcacerts -keystore kafka.client.truststore.jks -storepass changeit -noprompt -alias CARoot -file root.crt

# create keystore, export the cert, sign it, import root CA, import broker certificate
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:kafka.essexboy.com -dname "CN=[*.*], OU=[devops], O=[EssexBoy Ltd], L=[London], C=[GB]"
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -certreq -file kafka.unsigned.crt
openssl x509 -req -CA root.crt -CAkey root.key -in kafka.unsigned.crt -out kafka.signed.crt -days 365 -CAcreateserial
rm kafka.unsigned.crt
keytool -keystore kafka.keystore.jks -storepass changeit -alias CARoot -import -file root.crt -noprompt
keytool -keystore kafka.keystore.jks -storepass changeit -alias localhost -import -file kafka.signed.crt -noprompt
rm kafka.signed.crt root.srl

mv *.jks secrets
rm *.crt *.key