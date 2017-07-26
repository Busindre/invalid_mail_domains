#!/usr/bin/env bash
# Script to find invalid email addresses in the postfix logs (maillog). The script extracts the domains with some denied delivery.
# Dig is used to query the domain MX records. If the MX record does not exist, the port 25 is scanned with nmap. 
# If the MX record is not found and the server does not have port 25 open, any email address belonging to the domain is 100% invalid.
# The script should be used with stdin, not indicating the path to the logs. Please take a look at the examples.
#
# Examples of use.
# ssh root@X.X.X.X "zcat /var/log/maillog*" | invalid_mail_server.sh
# cat /var/log/maillog | /home/user/invalid_mail_server.sh
# invalid_mail_server.sh  <<< "Jul 02 22:17:12 www-op postfix/smtp[1355]: 3769A224C78: to=<cacas@gmail.de>, relay=mail.perform-sports.es[188.40.83.148]:25, delay=268661, delays=268459/0.01/0.07/201, dsn=4.3.5, status=deferred (host mail.perform-sports.es[188.40.83.148] said: 451 4.3.5 Server configuration problem (in reply to RCPT TO command))" 

[ -t 0 ] && { echo "Input expected from stdin."; exit 1; }
dns=("8.8.4.4" "8.8.8.8" "208.67.222.222" "208.67.220.220" "8.26.56.26" "8.20.247.20") # DNS Servers to Randomize DNS Requests.
extract=$(grep "status=deferred"|sed -e "s/^.*[[:space:]]\+to=<[^[:space:]]\+@\([^[:space:]>]\+\).*$/\1/"|sort|uniq) # Extract domains.
for fqdn_domain in $extract; do
        (dig @${dns[$RANDOM % ${#dns[@]} ]} +noall +answer "$fqdn_domain" MX|grep MX &>/dev/null) || (nmap -Pn -p 25 "$fqdn_domain" 2>/dev/null | grep "tcp open" &>/dev/null || false) # If MX records are not found, port 25 of the domain is scanned.
        if [ $? -eq 1 ]; then
                echo "$fqdn_domain"
        fi
done
