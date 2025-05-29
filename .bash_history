sudo apt update -y
vi harden.sh
ls
rm harden.sh 
sudo apt install -y ansible
mkdir ~/cis_hardening && cd ~/cis_hardening
vi cis_hardening.yml
ls
ansible-playbook cis_hardening.yml
cat /etc/sysctl.conf
auditctl -l
sudo -i
ls
cd cis_hardening/
ls
pwd
[ubuntu]
51.20.43.179 ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/cis_hardening/rsa-ubuntu.pem
ls
vi cis_hardening.yml 
sudo -i
