pacman -Sy --noconfirm hyperv

for x in hv_fcopy_daemon hv_kvp_daemon hv_vss_daemon; do sudo systemctl enable $x && sudo systemctl start $x; done
