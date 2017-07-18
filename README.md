# Script invalid_mail_domains.sh (PostFix Logs)
Script to find invalid email addresses in the postfix logs (maillog). The script extracts the domains with some denied delivery.
Dig is used to query the domain MX records. If the MX record does not exist, the port 25 is scanned with nmap. 

If the MX record is not found and the server does not have port 25 open, any email address belonging to the domain is 100% invalid.

The script should be used with stdin, not indicating the path to the logs. Please take a look at the examples.

**Dependencies**: [dig](https://en.wikipedia.org/wiki/Dig_(command)) and [nmap](https://nmap.org/)

## Examples of use.
```bash
# Obtain and read log files in remote with ssh.
ssh root@X.X.X.X "zcat /var/log/maillog*" | invalid_mail_domains.sh

# Searching for invalid domains in local postfix logs.
cat /var/log/maillog | /home/user/invalid_mail_domains.sh

# Using stdin directly with a line from the maillog file.
invalid_mail_domains.sh  <<< "Jul 02 22:17:12 www-op postfix/smtp[1355]: 3769A224C78: to=<cacas@gmail.de>, relay=mail.perform-sports.es[188.40.83.148]:25, delay=268661, delays=268459/0.01/0.07/201, dsn=4.3.5, status=deferred (host mail.perform-sports.es[188.40.83.148] said: 451 4.3.5 Server configuration problem (in reply to RCPT TO command))" 
```
