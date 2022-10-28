mkdir -p $D$systemd_system_unitdir/obmc-host-startmin@${0}.target.wants
LINK="$D$systemd_system_unitdir/obmc-host-startmin@{0}.target.wants/ampere-trst-wa.service"
TARGET="../ampere-trst-wa.service"
ln -s $TARGET $LINK
