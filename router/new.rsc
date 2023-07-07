###############################################################################
# Topic:		Using RouterOS to VLAN your network
# Example:		Switch with a separate router (RoaS)
# Web:			https://forum.mikrotik.com/viewtopic.php?t=143620
# RouterOS:		6.43.12
# Date:			Mar 28, 2019
# Notes:		Start with a reset (/system reset-configuration)
# Thanks:		mkx, sindy
###############################################################################

#######################################
# Naming
#######################################

# name the device being configured
/system identity
set name="Box G-27"

/system clock
set time-zone-name=America/New_York


#######################################
# VLAN Overview
#######################################

# 10 = TRUST [BLUE in example]
# 20 = GUEST [GREEN in example]
# 30 = SECURITY [RED in example]
# 40 = IOT
# 50 = DMZ
# 60 = LAB_GEN
# 70 = LAB_STOR
# 80 = LAB_K8S1
# 200 = BASE (MGMT) VLAN


#######################################
# Bridge
#######################################

# create one bridge, set VLAN mode off while we configure
/interface bridge
add admin-mac=C4:AD:34:FD:30:F8 name=BR1 protocol-mode=none vlan-filtering=no


#######################################
#
# -- Trunk Ports --
#
#######################################

# ingress behavior
/interface bridge port

# Trunk. Leave pvid set to default of 1
/interface bridge port
add bridge=BR1 disabled=yes interface=ether2
add bridge=BR1 interface=ether3
add bridge=BR1 interface=ether4
add bridge=BR1 interface=ether5
add bridge=BR1 interface=ether6
add bridge=BR1 interface=ether7
add bridge=BR1 interface=ether8
add bridge=BR1 interface=ether9
add bridge=BR1 interface=ether10
add bridge=BR1 interface=sfp1

# egress behavior
/interface bridge vlan

# Trunk. These need IP Services (L3), so add Bridge as member
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=10
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=20
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=30
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=40
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=50
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=60
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=70
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=80
add bridge=BR1 tagged=BR1,ether1,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10 vlan-ids=200

#######################################
# IP Addressing & Routing
#######################################

# LAN facing router's IP address on the BASE_VLAN
/interface vlan add interface=BR1 name=BASE_VLAN vlan-id=200
/ip address add address=192.168.0.1/24 interface=BASE_VLAN

# DNS server, set to cache for LAN
/ip dns set allow-remote-requests=yes servers="9.9.9.9"

# WAN DHCP
/ip dhcp-client add interface=ether2 add-default-route=yes default-route-distance=1 use-peer-dns=yes use-peer-ntp=yes dhcp-options=hostname,clientid comment=WAN

#######################################
# IP Services
#######################################

# TRUST VLAN interface creation, IP assignment, and DHCP service
#/interface vlan add interface=BR1 name=TRUST_VLAN vlan-id=10
#/ip address add interface=TRUST_VLAN address=10.15.31.1/24
#/ip pool add name=TRUST_POOL ranges=10.15.31.10-10.15.31.200
#/ip dhcp-server add address-pool=TRUST_POOL interface=TRUST_VLAN name=TRUST_DHCP disabled=no
#/ip dhcp-server network add address=10.15.31.0/24 dns-server=192.168.0.1 gateway=10.15.31.1

# GUEST VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=GUEST_VLAN vlan-id=20
/ip address add interface=GUEST_VLAN address=10.15.32.1/24
/ip pool add name=GUEST_POOL ranges=10.15.32.10-10.15.32.200
/ip dhcp-server add address-pool=GUEST_POOL interface=GUEST_VLAN name=GUEST_DHCP disabled=no
/ip dhcp-server network add address=10.15.32.0/24 dns-server=192.168.0.1 gateway=10.15.32.1

# SECURITY VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=SECURITY_VLAN vlan-id=30
/ip address add interface=SECURITY_VLAN address=10.15.33.1/24
/ip pool add name=SECURITY_POOL ranges=10.15.33.2-10.15.33.254
/ip dhcp-server add address-pool=SECURITY_POOL interface=SECURITY_VLAN name=SECURITY_DHCP disabled=no
/ip dhcp-server network add address=10.15.33.0/24 dns-server=192.168.0.1 gateway=10.15.33.1

# IOT VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=IOT_VLAN vlan-id=40
/ip address add interface=IOT_VLAN address=10.15.34.1/24
/ip pool add name=IOT_POOL ranges=10.15.34.10-10.15.34.200
/ip dhcp-server add address-pool=IOT_POOL interface=IOT_VLAN name=IOT_DHCP disabled=no
/ip dhcp-server network add address=10.15.34.0/24 dns-server=192.168.0.1 gateway=10.15.34.1

# DMZ VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= DMZ_VLAN vlan-id=50
/ip address add interface=DMZ_VLAN address=10.15.35.1/24
/ip pool add name=DMZ_VLAN ranges=10.15.35.10-10.15.35.200
/ip dhcp-server add address-pool=DMZ_VLAN interface=DMZ_VLAN name=DMZ_VLAN disabled=no
/ip dhcp-server network add address=10.15.35.0/24 dns-server=192.168.0.1 gateway=10.15.35.1

# LAB_GEN VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= LAB_GEN_VLAN vlan-id=60
/ip address add interface=LAB_GEN_VLAN address=10.15.36.1/24
/ip pool add name=LAB_GEN_VLAN ranges=10.15.36.10-10.15.36.100
/ip dhcp-server add address-pool=LAB_GEN_VLAN interface=LAB_GEN_VLAN name=LAB_GEN_VLAN disabled=no
/ip dhcp-server network add address=10.15.36.0/24 dns-server=192.168.0.1 gateway=10.15.36.1

# LAB_STOR VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= LAB_STOR_VLAN vlan-id=70
/ip address add interface=LAB_STOR_VLAN address=10.15.37.1/24
/ip pool add name=LAB_STOR_VLAN ranges=10.15.37.10-10.15.37.100
/ip dhcp-server add address-pool=LAB_STOR_VLAN interface=LAB_STOR_VLAN name=LAB_STOR_VLAN disabled=no
/ip dhcp-server network add address=10.15.37.0/24 dns-server=192.168.0.1 gateway=10.15.37.1

# LAB_K8S VLAN interface creation and IP assignment
/interface vlan add interface=BR1 name= LAB_K8S_VLAN vlan-id=80
/ip address add interface=LAB_K8S_VLAN address=10.15.38.1/24

# Optional: Create a DHCP instance for BASE_VLAN. Convenience feature for an admin.
/ip pool add name=BASE_POOL ranges=192.168.0.10-192.168.0.254
/ip dhcp-server add address-pool=BASE_POOL interface=BASE_VLAN name=BASE_DHCP disabled=no
/ip dhcp-server network add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1


#######################################
# Firewalling & NAT
# A good firewall for WAN. Up to you
# about how you want LAN to behave.
#######################################

##################
# Address Lists
##################

/ip firewall address-list
add address=0.0.0.0/8 comment="RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="multicast" list=no_forward_ipv4
add address=255.255.255.255 comment="RFC6890" list=no_forward_ipv4

/ip firewall address-list
add address=127.0.0.0/8 comment="RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="RFC6890 documentation" list=bad_ipv4
add address=198.51.100.0/24 comment="RFC6890 documentation" list=bad_ipv4
add address=203.0.113.0/24 comment="RFC6890 documentation" list=bad_ipv4
add address=240.0.0.0/4 comment="RFC6890 reserved" list=bad_ipv4

/ip firewall address-list
add address=0.0.0.0/8 comment="RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="RFC6890 benchmark" list=not_global_ipv4
add address=255.255.255.255 comment="RFC6890" list=not_global_ipv4

/ip firewall address-list
add address=224.0.0.0/4 comment="multicast" list=bad_src_ipv4
add address=255.255.255.255 comment="RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="RFC6890" list=bad_dst_ipv4

/ipv6 firewall address-list
add address=fe80::/10 comment="RFC6890 Linked-Scoped Unicast" list=no_forward_ipv6
add address=ff00::/8 comment="multicast" list=no_forward_ipv6
add address=::1/128 comment="RFC6890 lo" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="RFC6890 IPv4 mapped" list=bad_ipv6
add address=2001::/23 comment="RFC6890" list=bad_ipv6
add address=2001:db8::/32 comment="RFC6890 documentation" list=bad_ipv6
add address=2001:10::/28 comment="RFC6890 orchid" list=bad_ipv6
add address=::/96 comment="ipv4 compat" list=bad_ipv6
add address=100::/64 comment="RFC6890 Discard-only" list=not_global_ipv6
add address=2001::/32 comment="RFC6890 TEREDO" list=not_global_ipv6
add address=2001:2::/48 comment="RFC6890 Benchmark" list=not_global_ipv6
add address=fc00::/7 comment="RFC6890 Unique-Local" list=not_global_ipv6
add address=::/128 comment="unspecified" list=bad_dst_ipv6
add address=::/128 comment="unspecified" list=bad_src_ipv6
add address=ff00::/8 comment="multicast" list=bad_src_ipv6

# Use MikroTik's "list" feature for easy rule matchmaking.

/interface list add name=WAN
/interface list add name=VLAN
/interface list add name=LAN
/interface list add name=BASE

/interface list member
add interface=ether2 list=WAN
add interface=BASE_VLAN list=VLAN
add interface=TRUST_VLAN list=VLAN
add interface=GUEST_VLAN list=VLAN
add interface=SECURITY_VLAN list=VLAN
add interface=BASE_VLAN  list=BASE
add interface=BR1 list=LAN

# VLAN aware firewall. Order is important.
/ip firewall filter

add action=accept chain=forward comment="accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=fasttrack-connection chain=forward comment="fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward comment="drop bad forward IPs" src-address-list=no_forward_ipv4
add action=drop chain=forward comment="drop bad forward IPs" dst-address-list=no_forward_ipv4

##################
# INPUT CHAIN
##################
add action=accept chain=input comment="accept ICMP after RAW" protocol=icmp
add action=accept chain=input comment="accept established,related,untracked" connection-state=established,related,untracked
# Allow VLANs to access router services like DNS, Winbox. Naturally, you SHOULD make it more granular.
add chain=input action=accept in-interface-list=VLAN comment="Allow VLAN"
# Allow BASE_VLAN full access to the device for Winbox, etc.
add chain=input action=accept in-interface=BASE_VLAN comment="Allow Base_Vlan Full Access"
add chain=input action=drop comment="Drop"
#add action=drop chain=input comment="drop all not coming from LAN" in-interface-list=!LAN

##################
# FORWARD CHAIN
##################

add action=accept chain=forward comment="accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=fasttrack-connection chain=forward comment="fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="accept established,related, untracked" connection-state=established,related,untracked

# Allow all VLANs to access the Internet only, NOT each other
add chain=forward action=accept connection-state=new in-interface-list=VLAN out-interface-list=WAN comment="VLAN Internet Access only"

add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward comment="drop bad forward IPs" src-address-list=no_forward_ipv4
add action=drop chain=forward comment="drop bad forward IPs" dst-address-list=no_forward_ipv4

#add chain=forward action=drop comment="Drop"

##################
# NAT
##################
/ip firewall nat add action=masquerade chain=srcnat comment="masquerade" ipsec-policy=out,none out-interface-list=WAN

##################
# RAW
##################

/ip firewall raw
add action=accept chain=prerouting comment="enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="accept DHCP discover" dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=udp src-address=0.0.0.0 src-port=68
add action=drop chain=prerouting comment="drop bogon IP's" src-address-list=bad_ipv4
add action=drop chain=prerouting comment="drop bogon IP's" dst-address-list=bad_ipv4
add action=drop chain=prerouting comment="drop bogon IP's" src-address-list=bad_src_ipv4
add action=drop chain=prerouting comment="drop bogon IP's" dst-address-list=bad_dst_ipv4
add action=drop chain=prerouting comment="drop non global from WAN" in-interface-list=WAN src-address-list=not_global_ipv4
add action=drop chain=prerouting comment="drop forward to local lan from WAN" dst-address=10.15.31.0/24 in-interface-list=WAN
add action=drop chain=prerouting comment="drop local if not from default IP range" in-interface-list=LAN src-address=!10.15.31.0/24
add action=drop chain=prerouting comment="drop bad UDP" port=0 protocol=udp
add action=jump chain=prerouting comment="jump to ICMP chain" jump-target=icmp4 protocol=icmp
add action=jump chain=prerouting comment="jump to TCP chain" jump-target=bad_tcp protocol=tcp
add action=accept chain=prerouting comment="accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment="accept everything else from WAN" in-interface-list=WAN
add action=drop chain=prerouting comment="drop the rest"
add action=drop chain=bad_tcp comment="TCP flag filter" protocol=tcp tcp-flags=!fin,!syn,!rst,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,syn
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,urg
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=syn,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=rst,urg
add action=drop chain=bad_tcp comment="TCP port 0 drop" port=0 protocol=tcp
add action=accept chain=icmp4 comment="echo reply" icmp-options=0:0 limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="net unreachable" icmp-options=3:0 protocol=icmp
add action=accept chain=icmp4 comment="host unreachable" icmp-options=3:1 protocol=icmp
add action=accept chain=icmp4 comment="protocol unreachable" icmp-options=3:2 protocol=icmp
add action=accept chain=icmp4 comment="port unreachable" icmp-options=3:3 protocol=icmp
add action=accept chain=icmp4 comment="fragmentation needed" icmp-options=3:4 protocol=icmp
add action=accept chain=icmp4 comment="echo" icmp-options=8:0 limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="time exceeded " icmp-options=11:0-255 protocol=icmp
add action=drop chain=icmp4 comment="drop other icmp" protocol=icmp

/ipv6 firewall filter

######################
# INPUT CHAIN - IPv6
######################

add action=accept chain=input comment="accept ICMPv6 after RAW" protocol=icmpv6
add action=accept chain=input comment="accept established,related,untracked" connection-state=established,related,untracked
add action=accept chain=input comment="accept UDP traceroute" port=33434-33534 protocol=udp
add action=accept chain=input comment="accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/16
add action=accept chain=input comment="accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="accept IPSec AH" protocol=ipsec-ah
add action=accept chain=input comment="accept IPSec ESP" protocol=ipsec-esp
add action=drop chain=input comment="drop all not coming from LAN" in-interface-list=!LAN

########################
# FORWARD CHAIN - IPv6
########################

add action=accept chain=forward comment="accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="drop bad forward IPs" src-address-list=no_forward_ipv6
add action=drop chain=forward comment="drop bad forward IPs" dst-address-list=no_forward_ipv6
add action=drop chain=forward comment="rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="accept ICMPv6 after RAW" protocol=icmpv6
add action=accept chain=forward comment="accept HIP" protocol=139
add action=accept chain=forward comment="accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="accept AH" protocol=ipsec-ah
add action=accept chain=forward comment="accept ESP" protocol=ipsec-esp
add action=accept chain=forward comment="accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="drop everything else not coming from LAN"
#add action=drop chain=forward comment="drop everything else not coming from LAN" in-interface-list=!LAN

########################
# RAW - IPv6
########################

/ipv6 firewall raw
add action=accept chain=prerouting comment="enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="RFC4291, section 2.7.1" dst-address=ff02::1:ff00:0/104 icmp-options=135 protocol=icmpv6 src-address=::/128
add action=drop chain=prerouting comment="drop bogon IP's" src-address-list=bad_ipv6
add action=drop chain=prerouting comment="drop bogon IP's" dst-address-list=bad_ipv6
add action=drop chain=prerouting comment="drop packets with bad SRC ipv6" src-address-list=bad_src_ipv6
add action=drop chain=prerouting comment="drop packets with bad dst ipv6" dst-address-list=bad_dst_ipv6
add action=drop chain=prerouting comment="drop non global from WAN" in-interface-list=WAN src-address-list=not_global_ipv6
add action=jump chain=prerouting comment="jump to ICMPv6 chain" jump-target=icmp6 protocol=icmpv6
add action=accept chain=prerouting comment="accept local multicast scope" dst-address=ff02::/16
add action=drop chain=prerouting comment="drop other multicast destinations" dst-address=ff00::/8
add action=accept chain=prerouting comment="accept everything else from WAN" in-interface-list=WAN
add action=accept chain=prerouting comment="accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment="accept everything else from LAN" in-interface-list=VLAN
add action=drop chain=prerouting comment="drop the rest"
add action=accept chain=icmp6 comment="rfc4890 drop ll if hop-limit!=255" dst-address=fe80::/10 hop-limit=not-equal:255 protocol=icmpv6
add action=accept chain=icmp6 comment="dst unreachable" icmp-options=1:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="packet too big" icmp-options=2:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="limit exceeded" icmp-options=3:0-1 protocol=icmpv6
add action=accept chain=icmp6 comment="bad header" icmp-options=4:0-2 protocol=icmpv6
add action=accept chain=icmp6 comment="Mobile home agent address discovery" icmp-options=144:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="Mobile home agent address discovery" icmp-options=145:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="Mobile prefix solic" icmp-options=146:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="Mobile prefix advert" icmp-options=147:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="echo request limit 5,10" icmp-options=128:0-255 limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="echo reply limit 5,10" icmp-options=129:0-255 limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 router solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=133:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 router advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=134:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 neighbor solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=135:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 neighbor advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=136:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 inverse ND solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=141:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="rfc4890 inverse ND advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=142:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=drop chain=icmp6 comment="drop other icmp" protocol=icmpv6

#######################################
# Services
#######################################

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh address=10.15.31.0/24,192.168.0.0/24
set www-ssl disabled=no

#######################################
# SSH
#######################################

/ip ssh
set always-allow-password-login=yes strong-crypto=yes

#######################################
# VLAN Security
#######################################

# Only allow packets with tags over the Trunk Ports
#/interface bridge port
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether1]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether3]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether4]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether5]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether6]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether7]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether8]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether9]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether10]
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=sfp1]


#######################################
# MAC Server settings
#######################################

# Ensure only visibility and availability from BASE_VLAN, the MGMT network
/ip neighbor discovery-settings set discover-interface-list=BASE
/tool mac-server mac-winbox set allowed-interface-list=BASE
/tool mac-server set allowed-interface-list=BASE


#######################################
# Turn on VLAN mode
#######################################
#/interface bridge set BR1 vlan-filtering=yes

