#!/bin/bash
if [[ ! -e /config/Jackett ]]; then
	mkdir -p /config/Jackett
fi
chown -R ${PUID}:${PGID} /config/Jackett

# Set the rights on the /blackhole folder
chown -R ${PUID}:${PGID} /blackhole

if [[ ! -e /config/Jackett/ServerConfig.json ]]; then
	/bin/cp /etc/jackett/ServerConfig.json /config/Jackett/ServerConfig.json
	chmod 755 /config/Jackett/ServerConfig.json
fi

# Check for missing Group / PGID
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "A group with PGID $PGID already exists in /etc/passwd, nothing to do."
else
   echo "A group with PGID $PGID does not exist, adding a group called 'jackett' with PGID $PGID"
   groupadd -g $PGID jackett
fi

# Check for missing User / PUID
/bin/egrep  -i "^${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "An user with PUID $PUID already exists in /etc/passwd, nothing to do."
else
   echo "An user with PUID $PUID does not exist, adding an user called 'jackett user' with PUID $PUID"
   useradd -c "jackett user" -g $PGID -u $PUID jackett
fi

# Set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi

# Set Jackett WebUI Port
if [ ! -z "${WEBUI_PORT}" ]; then
	webui_port_exist=$(cat /config/Jackett/ServerConfig.json | grep -m 1 "  \"Port\": ${WEBUI_PORT},")
	if [[ -z "${webui_port_exist}" ]]; then
		webui_exist=$(cat /config/Jackett/ServerConfig.json | grep -m 1 '  \"Port\": ')
		if [[ ! -z "${webui_exist}" ]]; then
			# Get line number of WebUI Port
			LINE_NUM=$(grep -Fn -m 1 '  "Port":' /config/Jackett/ServerConfig.json | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@  \"Port\": ${WEBUI_PORT},@" /config/Jackett/ServerConfig.json
		else
			echo "  \"Port\": ${WEBUI_PORT}," >> /config/Jackett/ServerConfig.json
		fi
	fi
fi

echo "[info] Starting Jackett daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/jackett/jackett.init start &
chmod -R 755 /config/Jackett

sleep 1
jackettpid=$(pgrep -o -x jackett) 
echo "[info] Jackett PID: $jackettpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$jackettpid ]; then
	if [[ -e /config/Jackett/Logs/log.txt ]]; then
		chmod 775 /config/Jackett/Logs/log.txt
	fi
	sleep infinity
else
	echo "Jackett failed to start!"
fi