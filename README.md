# livebox_sites_blocker
Making easier to block websites on a Livebox; trying to fix the poor UI.



Let's say you want to block lemonde because you are tired of journalism...


Open a terminal,

nslookup www.lemonde.fr

Into the file run_me.sh, add a pair like this one :
+++
# le monde
site_ids+=("lemonde")
site_ips+=("199.232.170.217")
+++

Open a terminal, go to your directory
chmod +x ./run_me.sh
Usage: ./run_me.sh <livebox_admin_password>