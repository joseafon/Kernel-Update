#|/bin/sh

clear

OS_VERSION=$(hostnamectl | grep "Operating System" | awk '{print $5}')

echo "
+-------------------------+
|                         |
|      KERNEL UPDATE      |
|                         |
+-------------------------+
"
sleep 2

echo

echo " Checking kernel version"
sleep 2
echo
 
uname -r

sleep 2

echo
echo "Insatalling elrepo repositorie"
sleep 2
echo

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

if [ $OS_VERSION = 7 ]
then
    rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
fi

if [ $OS_VERSION = 8 ]
then
    rpm -Uvh https://www.elrepo.org/elrepo-release-8.1-1.el8.elrepo.noarch.rpm
fi

sleep 2
clear

echo "Downloading kernel"
sleep 2
echo
yum --enablerepo=elrepo-kernel install -y kernel-ml

line=$(sed -n '/GRUB_DEFAULT/=' /etc/default/grub)
sed -i ''$line'd' /etc/default/grub
sed -i ''$line'i\GRUB_DEFAULT=0\' /etc/default/grub

clear

echo
grub2-mkconfig -o /boot/grub2/grub.cfg

clear

if [ -d /sys/firmware/efi ]
then
    yum install -y mokutil > /dev/null 2>&1
    echo "Import secure boot key"
    sleep 2
    mokutil --import /etc/pki/elrepo/SECURE-BOOT-KEY-elrepo.org.der

    echo "
+--------------------------------------------------------+
|                                                        |
|                   AFTER OF REBOOT                      |
|                                                        |
+--------------------------------------------------------+
|                                                        |
| Select Enroll MOK                                      |
|                                                        |
| Select View key 0                                      |
|                                                        |
| Press the Esc key when you are finished                |
|                                                        |
| Select Continue                                        |
|                                                        |
| Enter the password you used for importing the key      |
|                                                        |
| It will ask Enrol the key(s)?---> Select Yes           |
|                                                        |
| Press a key to reboot system. The key is now enrolled  |
|                                                        |
+--------------------------------------------------------+
"
    echo "For more information visit: http://elrepo.org/tiki/SecureBootKey"
    echo
    echo "Push enter to reboot"
    read foo
    reboot

else
    echo "reboot system"
    sleep 2
    reboot

fi

