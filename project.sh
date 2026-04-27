#!/bin/bash

if test "$EUID" -ne 0 
then
whiptail --msgbox "run with sudo" 8 30
exit
fi

pause(){
read -p "press enter to continue..."
}

add_user(){
username=$(whiptail --inputbox "enter username" 8 30 3>&1 1>&2 2>&3)
[ -z "$username" ] && return
password=$(whiptail --passwordbox "enter password" 8 30 3>&1 1>&2 2>&3)

useradd -m "$username"
echo "$username:$password" | chpasswd

whiptail --msgbox "user added" 8 30
}

modify_user(){
username=$(whiptail --inputbox "enter username" 8 30 3>&1 1>&2 2>&3)

choice=$(whiptail --menu "modify user" 15 50 7 \
  "1" "home directory" \
  "2" "primary group" \
  "3" "add to group" \
  "4" "change username" \
  "5" "shell" \
  "6" "uid" \
  "7" "back" 3>&1 1>&2 2>&3)

case $choice in
    1)
      path=$(whiptail --inputbox "new home" 8 40 3>&1 1>&2 2>&3)
      usermod -d "$path" "$username"
      ;;
    2)
      group=$(whiptail --inputbox "group" 8 40 3>&1 1>&2 2>&3)
      usermod -g "$group" "$username"
      ;;
    3)
      group=$(whiptail --inputbox "group" 8 40 3>&1 1>&2 2>&3)
      usermod -aG "$group" "$username"
      ;;
    4)
      newname=$(whiptail --inputbox "new username" 8 40 3>&1 1>&2 2>&3)
      usermod -l "$newname" "$username"
      ;;
    5)
      shell=$(whiptail --inputbox "shell" 8 40 3>&1 1>&2 2>&3)
      usermod -s "$shell" "$username"
      ;;
    6)
      uid=$(whiptail --inputbox "uid" 8 40 3>&1 1>&2 2>&3)
      usermod -u "$uid" "$username"
      ;;
esac
}

delete_user(){
username=$(whiptail --inputbox "username" 8 30 3>&1 1>&2 2>&3)
userdel -r "$username"
whiptail --msgbox "user deleted" 8 30
}

list_users(){
users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
whiptail --msgbox "$users" 20 50
}

disable_user(){
username=$(whiptail --inputbox "username" 8 30 3>&1 1>&2 2>&3)
usermod -L "$username"
}

enable_user(){
username=$(whiptail --inputbox "username" 8 30 3>&1 1>&2 2>&3)
usermod -U "$username"
}

change_password(){
username=$(whiptail --inputbox "username" 8 30 3>&1 1>&2 2>&3)
password=$(whiptail --passwordbox "new password" 8 30 3>&1 1>&2 2>&3)
echo "$username:$password" | chpasswd
}

add_group(){
name=$(whiptail --inputbox "group name" 8 30 3>&1 1>&2 2>&3)
groupadd "$name"
}

modify_group(){
group=$(whiptail --inputbox "group name" 8 30 3>&1 1>&2 2>&3)

choice=$(whiptail --menu "modify group" 15 50 3 \
  "1" "change name" \
  "2" "change gid" \
  "3" "back" 3>&1 1>&2 2>&3)

case $choice in
    1)
      newname=$(whiptail --inputbox "new name" 8 40 3>&1 1>&2 2>&3)
      groupmod -n "$newname" "$group"
      ;;
    2)
      gid=$(whiptail --inputbox "new gid" 8 40 3>&1 1>&2 2>&3)
      groupmod -g "$gid" "$group"
      ;;
  esac
}

delete_group(){
name=$(whiptail --inputbox "group name" 8 30 3>&1 1>&2 2>&3)
groupdel "$name"
}

list_groups(){
groups=$(awk -F: '$3 >= 1000 {print $1}' /etc/group)
whiptail --msgbox "$groups" 20 50
}

about(){
whiptail --msgbox "linux user manager (bash version)" 10 40
}

while true
do
choice=$(whiptail --menu "main menu" 20 60 13 \
  "1" "add user" \
  "2" "modify user" \
  "3" "delete user" \
  "4" "list users" \
  "5" "add group" \
  "6" "modify group" \
  "7" "delete group" \
  "8" "list groups" \
  "9" "disable user" \
  "10" "enable user" \
  "11" "change password" \
  "12" "about" \
  "13" "exit" 3>&1 1>&2 2>&3)

case $choice in
    1) add_user ;;
    2) modify_user ;;
    3) delete_user ;;
    4) list_users ;;
    5) add_group ;;
    6) modify_group ;;
    7) delete_group ;;
    8) list_groups ;;
    9) disable_user ;;
    10) enable_user ;;
    11) change_password ;;
    12) about ;;
    13) exit ;;
  esac
done
