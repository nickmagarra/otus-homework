# Lesson 2: MDADM

## Content discription

  - **Vagrantfile_no_mdadm** - Vagrantfile that creates new disks and attachs them to VM, installing mdadm and some other tools. 
  - **Vagrantfile_mdadm** - Vagrantfile that makes everything above and then creates raids, partitions, filesystems on it and adds mountpoints to fstab.
  - **mdadm_config.sh** - Bash script for manual executing on VM created with ***Vagrantfile_no_mdadm*** that makes all tasts listed in ***mdadm_config.sh***

## Basic Vagrantfile tuning

Basic vagrantfile from repository was modified to resolve problems with attaching new disks to VM.  
Original version works fine only once, after adding new disk in config and restarting VM virtualbox was trying to create controller and fails with error.  
I've added simple check is disk with name ***sata1.vdi*** exists in folder with Vagrantfile. After that you can add new disk config block in variable section and run **`vagrant reload --provision`** and new disk will appear in system.  
Also in I've added **`lsblk`** to SHELL block to see result in console while VM is starting.
  
#### Old disk create/attach block:
  
```ruby
      box.vm.provider :virtualbox do |vb|
            	vb.customize ["modifyvm", :id, "--memory", "1024"]
                needsController = false
                boxconfig[:disks].each do |dname, dconf|
                     unless File.exist?(dconf[:dfile])
                         vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                         needsController =  true
                     end
                end
  
                if needsController == true
                     vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                     boxconfig[:disks].each do |dname, dconf|
                         vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                     end
                end
      end
```
  
#### New disk create/attach block:
  
```ruby
     box.vm.provider :virtualbox do |vb|
                  vb.customize ["modifyvm", :id, "--memory", "1024"]
  
                  unless File.exist?('./sata1.vdi')
                       vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                  end
  
                  boxconfig[:disks].each do |dname, dconf|
                       unless File.exist?(dconf[:dfile])
                            vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                            vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                       end
                  end
      end
```
