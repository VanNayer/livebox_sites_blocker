# livebox_sites_blocker

## Making easier to block websites on a Livebox; trying to fix the poor UI.
Let's say you want to block lemonde because you are tired of journalism...

Into the file run_me.sh, add a pair like this one :
```
# le monde
site_ids+=("lemonde")
site_ips+=("199.232.170.217")
```

Then open a terminal, go to your repo
```
chmod +x ./run_me.sh
./run_me.sh <livebox_admin_password>
```

ps: to find all the IPs used by a website, nslookup is your friend:
```
nslookup www.lemonde.fr
```