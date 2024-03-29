###############################################################################
# Adapted from: https://forum.mikrotik.com/viewtopic.php?t=143620
###############################################################################

#######################################
# Naming
#######################################

# name the device being configured
/system identity set name="Box G-27"

/system clock
set time-zone-name=America/New_York

/system ntp client 
set servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org
set mode=unicast
set enabled=yes

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
# Interface Lists
#######################################

/interface list
add name=ALL_VLAN
add name=WAN
add name=LAN

#######################################
#
# -- Turn Off POE --
#
#######################################

/interface ethernet
set [ find default-name=ether1 ] poe-out=off

#######################################
#
# -- Trunk Ports --
#
#######################################

# ingress behavior
/interface bridge port

# Purple Trunk. Leave pvid set to default of 1
add bridge=BR1 interface=ether1
add bridge=BR1 interface=ether2 disabled=yes
add bridge=BR1 interface=ether3
add bridge=BR1 interface=ether4
add bridge=BR1 interface=ether5
add bridge=BR1 interface=ether6
add bridge=BR1 interface=ether7
add bridge=BR1 interface=ether8
add bridge=BR1 interface=ether9 comment="Mikrotik Switch"
add bridge=BR1 interface=ether10
add bridge=BR1 interface=sfp1

# egress behavior
/interface bridge vlan

# Purple Trunk. These need IP Services (L3), so add Bridge as member
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
/ip address add address=192.168.0.1/24 interface=BASE_VLAN  comment="Management VLAN"

# DNS server, set to cache for LAN
/ip dns set allow-remote-requests=yes servers="9.9.9.9"

#######################################
# IP Services
#######################################

/ip dhcp-client add interface=ether2 add-default-route=yes default-route-distance=1 use-peer-dns=yes use-peer-ntp=yes dhcp-options=hostname,clientid comment=WAN

# TRUST VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=TRUST_VLAN vlan-id=10
/ip address add interface=TRUST_VLAN address=10.15.31.1/24  comment="TRUST VLAN"
/ip pool add name=TRUST_POOL ranges=10.15.31.10-10.15.31.200
/ip dhcp-server add address-pool=TRUST_POOL interface=TRUST_VLAN name=TRUST_DHCP disabled=no
/ip dhcp-server network add address=10.15.31.0/24 dns-server=192.168.0.1 gateway=10.15.31.1

# GUEST VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=GUEST_VLAN vlan-id=20
/ip address add interface=GUEST_VLAN address=10.15.32.1/24  comment="GUEST VLAN"
/ip pool add name=GUEST_POOL ranges=10.15.32.10-10.15.32.200
/ip dhcp-server add address-pool=GUEST_POOL interface=GUEST_VLAN name=GUEST_DHCP disabled=no
/ip dhcp-server network add address=10.15.32.0/24 dns-server=192.168.0.1 gateway=10.15.32.1

# SECURITY VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=SECURITY_VLAN vlan-id=30
/ip address add interface=SECURITY_VLAN address=10.15.33.1/24 comment="SECURITY VLAN"
/ip pool add name=SECURITY_POOL ranges=10.15.33.2-10.15.33.254
/ip dhcp-server add address-pool=SECURITY_POOL interface=SECURITY_VLAN name=SECURITY_DHCP disabled=no
/ip dhcp-server network add address=10.15.33.0/24 dns-server=192.168.0.1 gateway=10.15.33.1

# IOT VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name=IOT_VLAN vlan-id=40
/ip address add interface=IOT_VLAN address=10.15.34.1/24 comment="IOT VLAN"
/ip pool add name=IOT_POOL ranges=10.15.34.10-10.15.34.200
/ip dhcp-server add address-pool=IOT_POOL interface=IOT_VLAN name=IOT_DHCP disabled=no
/ip dhcp-server network add address=10.15.34.0/24 dns-server=192.168.0.1 gateway=10.15.34.1

# DMZ VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= DMZ_VLAN vlan-id=50
/ip address add interface=DMZ_VLAN address=10.15.35.1/24 comment="DMZ VLAN"
/ip pool add name=DMZ_VLAN ranges=10.15.35.10-10.15.35.200
/ip dhcp-server add address-pool=DMZ_VLAN interface=DMZ_VLAN name=DMZ_VLAN disabled=no
/ip dhcp-server network add address=10.15.35.0/24 dns-server=192.168.0.1 gateway=10.15.35.1

# LAB_GEN VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= LAB_GEN_VLAN vlan-id=60
/ip address add interface=LAB_GEN_VLAN address=10.15.36.1/24 comment="LAB_GEN VLAN"
/ip pool add name=LAB_GEN_VLAN ranges=10.15.36.10-10.15.36.100
/ip dhcp-server add address-pool=LAB_GEN_VLAN interface=LAB_GEN_VLAN name=LAB_GEN_VLAN disabled=no
/ip dhcp-server network add address=10.15.36.0/24 dns-server=192.168.0.1 gateway=10.15.36.1

# LAB_STOR VLAN interface creation, IP assignment, and DHCP service
/interface vlan add interface=BR1 name= LAB_STOR_VLAN vlan-id=70
/ip address add interface=LAB_STOR_VLAN address=10.15.37.1/24 comment="LAB_STOR VLAN"
/ip pool add name=LAB_STOR_VLAN ranges=10.15.37.10-10.15.37.100
/ip dhcp-server add address-pool=LAB_STOR_VLAN interface=LAB_STOR_VLAN name=LAB_STOR_VLAN disabled=no
/ip dhcp-server network add address=10.15.37.0/24 dns-server=192.168.0.1 gateway=10.15.37.1

# LAB_K8S VLAN interface creation and IP assignment
/interface vlan add interface=BR1 name= LAB_K8S_VLAN vlan-id=80
/ip address add interface=LAB_K8S_VLAN address=10.15.38.1/24  comment="LAB_K8S VLAN"

# Optional: Create a DHCP instance for BASE_VLAN. Convenience feature for an admin.
/ip pool add name=BASE_POOL ranges=192.168.0.10-192.168.0.254
/ip dhcp-server add address-pool=BASE_POOL interface=BASE_VLAN name=BASE_DHCP disabled=no
/ip dhcp-server network add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1

/interface list member
add interface=ether2 list=WAN
add interface=BR1 list=LAN
add interface=TRUST_VLAN list=ALL_VLAN
add interface=GUEST_VLAN list=ALL_VLAN
add interface=SECURITY_VLAN list=ALL_VLAN
add interface=LAB_GEN_VLAN list=ALL_VLAN
add interface=LAB_K8S_VLAN list=ALL_VLAN
add interface=LAB_STOR_VLAN list=ALL_VLAN
add interface=BASE_VLAN list=ALL_VLAN

#######################################
# Firewalling & NAT
# A good firewall for WAN. Up to you
# about how you want LAN to behave.
#######################################

##################
# Address Lists
##################

/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=no_forward_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=no_forward_ipv4

/ip firewall address-list
add address=127.0.0.0/8 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=198.51.100.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=203.0.113.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=240.0.0.0/4 comment="defconf: RFC6890 reserved" list=bad_ipv4

/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="defconf: RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="defconf: RFC6890 benchmark" list=not_global_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=not_global_ipv4

/ip firewall address-list
add address=224.0.0.0/4 comment="defconf: multicast" list=bad_src_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="defconf: RFC6890" list=bad_dst_ipv4

# VLAN aware firewall. Order is important.
/ip firewall filter

##################
# INPUT CHAIN
##################
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp

add action=accept chain=input comment="Accept DHCP requests on VLAN interfaces" dst-port=67 in-interface-list=ALL_VLAN protocol=udp src-port=68
add action=accept chain=input comment="Accept DNS requests (UDP) from VLAN interfaces" dst-port=53 in-interface-list=ALL_VLAN protocol=udp
add action=accept chain=input comment="Accept DNS requests (TCP) from VLAN interfaces" dst-port=53 in-interface-list=ALL_VLAN protocol=tcp

add action=accept chain=input comment="Accept Winbox traffic from TRUST VLAN" dst-port=8291 in-interface-list=ALL_VLAN protocol=tcp
add action=accept chain=input comment="Accept SSH traffic from TRUST VLAN" dst-port=22 in-interface-list=ALL_VLAN protocol=tcp
add action=accept chain=input comment="Accept HTTP traffic from TRUST VLAN" dst-port=8443 in-interface-list=ALL_VLAN protocol=tcp

add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN

add action=accept chain=input comment="Allow VLAN" in-interface-list=ALL_VLAN

##################
# FORWARD CHAIN
##################
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN

##################
# NAT
##################
/ip firewall nat add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN

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
#set bridge=BR1 ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=sfp1]

#######################################
# SSL Certificate for Webfig
#######################################

/certificate
add name=root-cert common-name=MyRouter days-valid=3650 key-usage=key-cert-sign,crl-sign
sign root-cert
add name=https-cert common-name=MyRouter days-valid=3650
sign ca=root-cert https-cert

#######################################
# MAC Server settings
#######################################

# Ensure only visibility and availability from BASE_VLAN, the MGMT network
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN

#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BR1 vlan-filtering=no
