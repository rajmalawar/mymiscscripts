source en_setup.sh
java -jar -XX:+UseG1GC server.jar server ${CONFIG_ENV}-config.yml
