# 2024-01-18 09:22:01 by RouterOS 7.13
# software id = RF1W-SNY1
#
# model = RB3011UiAS
# serial number = B88E0B7BD0B5
/interface bridge
add admin-mac=C4:AD:34:FD:30:F8 auto-mac=no comment="Bridge used for LAN" name=LAN_BRIDGE port-cost-mode=short
/interface ethernet
set [ find default-name=ether1 ] disabled=yes
set [ find default-name=ether2 ] comment="Cable Modem"
set [ find default-name=ether3 ] comment="Asus WiFi"
set [ find default-name=ether4 ] comment="Hue Bridge"
set [ find default-name=ether5 ] comment=Desk1
/interface vlan
add comment="VLAN for Guest Network" interface=LAN_BRIDGE name=GUEST_VLAN_10 vlan-id=10
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip pool
add name=DHCP_LAN_POOL ranges=10.15.31.10-10.15.31.200
add name=jubilee ranges=10.15.32.10-10.15.32.100
add name=dhcp_pool2 ranges=10.0.1.2-10.0.1.254
/ip dhcp-server
add address-pool=DHCP_LAN_POOL interface=LAN_BRIDGE name=DHCP_LAN
add address-pool=dhcp_pool2 interface=GUEST_VLAN_10 name=GUEST_DHCP
/port
set 0 name=serial0
/interface bridge port
add bridge=LAN_BRIDGE comment=defconf disabled=yes interface=ether2 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether3 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether4 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether5 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether6 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether7 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether8 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether9 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=ether10 internal-path-cost=10 path-cost=10
add bridge=LAN_BRIDGE comment=defconf interface=sfp1 internal-path-cost=10 path-cost=10
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=LAN_BRIDGE list=LAN
add comment=defconf interface=ether2 list=WAN
/ip address
add address=10.15.31.1/24 comment=LAN_SUBNET interface=LAN_BRIDGE network=10.15.31.0
add address=10.0.1.1/24 comment=GUEST_SUBNET interface=GUEST_VLAN_10 network=10.0.1.0
/ip dhcp-client
add comment=defconf interface=ether2
/ip dhcp-server lease
add address=10.15.31.23 client-id=1:d8:a0:11:8a:79:78 mac-address=D8:A0:11:8A:79:78 server=DHCP_LAN
add address=10.15.31.96 client-id=1:d8:a0:11:8a:8b:48 mac-address=D8:A0:11:8A:8B:48 server=DHCP_LAN
/ip dhcp-server network
add address=10.0.1.0/24 dns-server=1.1.1.1 gateway=10.0.1.1
add address=10.15.31.0/24 comment=defconf dns-server=9.9.9.9,1.1.1.1 gateway=10.15.31.1
/ip dns
set allow-remote-requests=yes servers=9.9.9.9
/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=no_forward_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=no_forward_ipv4
add address=127.0.0.0/8 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=198.51.100.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=203.0.113.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=240.0.0.0/4 comment="defconf: RFC6890 reserved" list=bad_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="defconf: RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="defconf: RFC6890 benchmark" list=not_global_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=not_global_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=bad_src_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="defconf: RFC6890" list=bad_dst_ipv4
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP after RAW" protocol=icmp
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward comment="defconf: drop bad forward IPs" src-address-list=no_forward_ipv4
add action=drop chain=forward comment="defconf: drop bad forward IPs" dst-address-list=no_forward_ipv4
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN
/ip firewall raw
add action=accept chain=prerouting comment="defconf: enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="defconf: accept DHCP discover" dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=udp src-address=0.0.0.0 src-port=68
add action=drop chain=prerouting comment="defconf: drop bogon IP's" src-address-list=bad_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" dst-address-list=bad_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" src-address-list=bad_src_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" dst-address-list=bad_dst_ipv4
add action=drop chain=prerouting comment="defconf: drop non global from WAN" in-interface-list=WAN src-address-list=not_global_ipv4
add action=drop chain=prerouting comment="defconf: drop forward to local lan from WAN" dst-address=10.15.31.0/24 in-interface-list=WAN
add action=drop chain=prerouting comment="defconf: drop local if not from default IP range" in-interface-list=LAN src-address=!10.15.31.0/24
add action=drop chain=prerouting comment="defconf: drop bad UDP" port=0 protocol=udp
add action=jump chain=prerouting comment="defconf: jump to ICMP chain" jump-target=icmp4 protocol=icmp
add action=jump chain=prerouting comment="defconf: jump to TCP chain" jump-target=bad_tcp protocol=tcp
add action=accept chain=prerouting comment="defconf: accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment="defconf: accept everything else from WAN" in-interface-list=WAN
add action=drop chain=prerouting comment="defconf: drop the rest"
add action=drop chain=bad_tcp comment="defconf: TCP flag filter" protocol=tcp tcp-flags=!fin,!syn,!rst,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,syn
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,urg
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=syn,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=rst,urg
add action=drop chain=bad_tcp comment="defconf: TCP port 0 drop" port=0 protocol=tcp
add action=accept chain=icmp4 comment="defconf: echo reply" icmp-options=0:0 limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="defconf: net unreachable" icmp-options=3:0 protocol=icmp
add action=accept chain=icmp4 comment="defconf: host unreachable" icmp-options=3:1 protocol=icmp
add action=accept chain=icmp4 comment="defconf: protocol unreachable" icmp-options=3:2 protocol=icmp
add action=accept chain=icmp4 comment="defconf: port unreachable" icmp-options=3:3 protocol=icmp
add action=accept chain=icmp4 comment="defconf: fragmentation needed" icmp-options=3:4 protocol=icmp
add action=accept chain=icmp4 comment="defconf: echo" icmp-options=8:0 limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="defconf: time exceeded " icmp-options=11:0-255 protocol=icmp
add action=drop chain=icmp4 comment="defconf: drop other icmp" protocol=icmp
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh address=10.15.31.0/24
set www-ssl address=10.15.31.0/24 disabled=no
set winbox address=10.15.31.0/24
/ip ssh
set always-allow-password-login=yes strong-crypto=yes
/ipv6 firewall address-list
add address=fe80::/10 comment="defconf: RFC6890 Linked-Scoped Unicast" list=no_forward_ipv6
add address=ff00::/8 comment="defconf: multicast" list=no_forward_ipv6
add address=::1/128 comment="defconf: RFC6890 lo" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: RFC6890 IPv4 mapped" list=bad_ipv6
add address=2001::/23 comment="defconf: RFC6890" list=bad_ipv6
add address=2001:db8::/32 comment="defconf: RFC6890 documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: RFC6890 orchid" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: RFC6890 Discard-only" list=not_global_ipv6
add address=2001::/32 comment="defconf: RFC6890 TEREDO" list=not_global_ipv6
add address=2001:2::/48 comment="defconf: RFC6890 Benchmark" list=not_global_ipv6
add address=fc00::/7 comment="defconf: RFC6890 Unique-Local" list=not_global_ipv6
add address=::/128 comment="defconf: unspecified" list=bad_dst_ipv6
add address=::/128 comment="defconf: unspecified" list=bad_src_ipv6
add address=ff00::/8 comment="defconf: multicast" list=bad_src_ipv6
/ipv6 firewall filter
add action=accept chain=input comment="defconf: accept ICMPv6 after RAW" protocol=icmpv6
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=accept chain=input comment="defconf: accept UDP traceroute" port=33434-33534 protocol=udp
add action=accept chain=input comment="defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/16
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="defconf: accept IPSec AH" protocol=ipsec-ah
add action=accept chain=input comment="defconf: accept IPSec ESP" protocol=ipsec-esp
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop bad forward IPs" src-address-list=no_forward_ipv6
add action=drop chain=forward comment="defconf: drop bad forward IPs" dst-address-list=no_forward_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6 after RAW" protocol=icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept AH" protocol=ipsec-ah
add action=accept chain=forward comment="defconf: accept ESP" protocol=ipsec-esp
add action=accept chain=forward comment="defconf: accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
/ipv6 firewall raw
add action=accept chain=prerouting comment="defconf: enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="defconf: RFC4291, section 2.7.1" dst-address=ff02::1:ff00:0/104 icmp-options=135 protocol=icmpv6 src-address=::/128
add action=drop chain=prerouting comment="defconf: drop bogon IP's" src-address-list=bad_ipv6
add action=drop chain=prerouting comment="defconf: drop bogon IP's" dst-address-list=bad_ipv6
add action=drop chain=prerouting comment="defconf: drop packets with bad SRC ipv6" src-address-list=bad_src_ipv6
add action=drop chain=prerouting comment="defconf: drop packets with bad dst ipv6" dst-address-list=bad_dst_ipv6
add action=drop chain=prerouting comment="defconf: drop non global from WAN" in-interface-list=WAN src-address-list=not_global_ipv6
add action=jump chain=prerouting comment="defconf: jump to ICMPv6 chain" jump-target=icmp6 protocol=icmpv6
add action=accept chain=prerouting comment="defconf: accept local multicast scope" dst-address=ff02::/16
add action=drop chain=prerouting comment="defconf: drop other multicast destinations" dst-address=ff00::/8
add action=accept chain=prerouting comment="defconf: accept everything else from WAN" in-interface-list=WAN
add action=accept chain=prerouting comment="defconf: accept everything else from LAN" in-interface-list=LAN
add action=drop chain=prerouting comment="defconf: drop the rest"
add action=accept chain=icmp6 comment="defconf: rfc4890 drop ll if hop-limit!=255" dst-address=fe80::/10 hop-limit=not-equal:255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: dst unreachable" icmp-options=1:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: packet too big" icmp-options=2:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: limit exceeded" icmp-options=3:0-1 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: bad header" icmp-options=4:0-2 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: Mobile home agent address discovery" icmp-options=144:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: Mobile home agent address discovery" icmp-options=145:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: Mobile prefix solic" icmp-options=146:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: Mobile prefix advert" icmp-options=147:0-255 protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: echo request limit 5,10" icmp-options=128:0-255 limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: echo reply limit 5,10" icmp-options=129:0-255 limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 router solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=133:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 router advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=134:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 neighbor solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=135:0-255 in-interface-list=LAN limit=5,10:packet protocol=icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 neighbor advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=136:0-255 in-interface-list=LAN limit=5,10:packet protocol=\
    icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 inverse ND solic limit 5,10 only LAN" hop-limit=equal:255 icmp-options=141:0-255 in-interface-list=LAN limit=5,10:packet protocol=\
    icmpv6
add action=accept chain=icmp6 comment="defconf: rfc4890 inverse ND advert limit 5,10 only LAN" hop-limit=equal:255 icmp-options=142:0-255 in-interface-list=LAN limit=5,10:packet protocol=\
    icmpv6
add action=drop chain=icmp6 comment="defconf: drop other icmp" protocol=icmpv6
/ipv6 nd
set [ find default=yes ] interface=LAN_BRIDGE
/system clock
set time-zone-name=America/New_York
/system identity
set name="Box G-27"
/system note
set show-at-login=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
