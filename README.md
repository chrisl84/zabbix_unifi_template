# Zabbix UniFi Template

Shell script to poll the UniFi Controller API for the WiFi Experience. The script is called by the Zabbix Agent and then returned to the Zabbix Server.

# Installation
Place the shell script and conf file in the configuration directory of the Zabbix Agent. 

Change the permissions so that the zabbix user can read the userparameter_unifi.conf file and read/execute the shell script.

Edit the zabbix_agent.conf file and modify the Include the user_parameter_unifi.conf file
Include=/etc/zabbix/userparameter_unifi.conf

Save and exit.

Restart the agent.

Add a template on the Zabbix Server that polls the agent to execute the script at desired interval.

A more thorough description can be found at :
https://www.labeightyfour.com/2019/04/29/monitor-unifi-controller-values-using-zabbix-server-and-custom-templates/ 

