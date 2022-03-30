[preview]: https://raw.githubusercontent.com/DyonR/docker-templates/master/Screenshots/jackettvpn/jackettvpn-mainpage.png "Jackett Preview"

# Jackett and OpenVPN
Docker container which runs the latest headless Jackett Server while connecting to OpenVPN with iptables killswitch to prevent IP leakage when the tunnel goes down.

![alt text][preview]

## Docker Features
* Base: balenalib/raspberrypi4-64-debian - Latest
* Latest Jackett
* Selectively enable or disable OpenVPN support
* IP tables kill switch to prevent IP leaking when VPN connection fails
* Specify name servers to add to container
* Configure UID and GID for config files and blackhole for Jackett

# Run container from Docker registry
The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -v /your/downloads/path/:/blackhole \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.0.0/24" \
              -e "NAME_SERVERS=1.1.1.1,1.0.0.1" \
              -p 9117:9117 \
              b34rdtek/jackettopenvpn
```

# Variables, Volumes, and Ports
## Environment Variables
| Variable | Required | Function | Example |
|----------|----------|----------|----------|
|`VPN_ENABLED`| Yes | Enable VPN? (yes/no) Default:yes|`VPN_ENABLED=yes`|
|`VPN_USERNAME`| No | If username and password provided, configures ovpn file automatically |`VPN_USERNAME=ad8f64c02a2de`|
|`VPN_PASSWORD`| No | If username and password provided, configures ovpn file automatically |`VPN_PASSWORD=ac98df79ed7fb`|
|`LAN_NETWORK`| Yes | Local Network with CIDR notation |`LAN_NETWORK=192.168.0.0/24`|
|`NAME_SERVERS`| No | Comma delimited name servers |`NAME_SERVERS=1.1.1.1,1.0.0.1`|
|`PUID`| No | UID applied to config files and blackhole |`PUID=99`|
|`PGID`| No | GID applied to config files and blackhole |`PGID=100`|
|`UMASK`| No | |`UMASK=002`|
|`WEBUI_PORT`| No | Sets the port of the Jackett server in the ServerConfig.json, needs to match the **exposed port** in the Dockerfile  |`WEBUI_PORT=9117`|

## Volumes
| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | Jackett and OpenVPN config files | `/your/config/path/:/config`|
| `blackhole` | No | Default blackhole path for saving magnet links | `/your/blackhole/path/:/blackhole`|

## Ports
| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `9117` | TCP | Yes | Jackett WebUI | `9117:9117`|

# Access the WebUI
Access http://IPADDRESS:PORT from a browser on the same network. (for example: http://192.168.0.90:9117)

## Default Info
API Keys are randomly generated the first time that Jackett starts up. There is no Web UI password configured. This can be done manually from the Web UI

| Credential | Default Value |
|----------|----------|
|`API Key`| Randomly generated |
|`WebUI Password`| No password |

# How to use OpenVPN
The container will fail to boot if `VPN_ENABLED` is set to yes or empty and a .ovpn is not present in the /config/openvpn directory. Drop a .ovpn file from your VPN provider into /config/openvpn and start the container again. You may need to edit the ovpn configuration file to load your VPN credentials from a file by setting `auth-user-pass`.

**Note:** The script will use the first ovpn file it finds in the /config/openvpn directory. Adding multiple ovpn files will not start multiple VPN connections.

## Example auth-user-pass option
`auth-user-pass credentials.conf`

## Example credentials.conf
```
username
password
```

## PUID/PGID
User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```

# Issues
If you are having issues with this container please submit an issue on GitHub.
Please provide logs, docker version and other information that can simplify reproducing the issue.
Using the latest stable verison of Docker is always recommended. Support for older version is on a best-effort basis.

# Building the container yourself
To build this container, clone the repository and cd into it.

## Build it:
```
$ cd /repo/location/jackettvpn
$ docker build -t jackettvpn .
```
## Run it:
```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -v /your/blackhole/path/:/blackhole \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.0.0/24" \
              -e "NAME_SERVERS=1.1.1.1,1.0.0.1" \
              -p 9117:9117 \
              b34rdtek/jackettopenvpn
```
