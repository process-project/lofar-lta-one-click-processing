#!/bin/bash
#sv start lofarapi || exit 1
cd /home/ltacat_UC2
#caddy reload --config /home/ltacat_UC2/Caddyfile --adapter caddyfile
#caddy stop
caddy run --config /home/ltacat_UC2/Caddyfile2 --adapter caddyfile

