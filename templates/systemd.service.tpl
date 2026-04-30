[Unit]
Description={{service_name}}
[Service]
WorkingDirectory={{workdir}}/current
ExecStart=/usr/bin/java -jar app.jar
Restart=always
[Install]
WantedBy=multi-user.target
