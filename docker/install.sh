#!/bin/sh -x

cd /root

mv /tmp/spec .
mv /tmp/.ashenv .
mv /tmp/exe .
mv /tmp/etc-paths /etc/paths

chmod +x exe/path_helper
chmod +x spec/shell_spec.sh

./exe/path_helper --setup --no-lib --quiet
mv /tmp/etc-paths /etc/paths

cp -R spec/fixtures/moredirs/* ~/.config/paths
