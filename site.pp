# /etc/puppetlabs/code/environments/production/manifests/site.pp

class common {
  # Create necessary groups
  group { 'users':
    ensure => present,
    gid    => 1004,
  }

  # Create the 'developers' group
  group { 'developers':
    ensure   => 'present',
    gid      => 1009,
    provider => 'groupadd',
  }

# Ensure the sudo package is installed
  package { 'sudo':
    ensure => installed,
  }

  # Ensure the 'sudo' group exists (for sudo access)
  group { 'sudo':
    ensure   => 'present',
  }

# Define users with their UID, home directories, and groups
$users = {
  'bob'   => { uid => 1005, home => '/home/bob', groups => ['users', 'sudo'] },
  'janet' => { uid => 1006, home => '/home/janet', groups => ['users', 'developers', 'sudo'] },
  'alice' => { uid => 1007, home => '/home/alice', groups => ['users', 'sudo'] },
  'tim'   => { uid => 1008, home => '/home/tim', groups => ['users', 'developers', 'sudo'] },
}


# Create users with default settings, including sudo and other groups
create_resources('user', $users, {
  ensure   => 'present',
  gid      => 1004,   # Primary group 'users'
  provider => 'useradd',
  shell    => '/bin/bash',
})

file { '/etc/sudoers.d/sudo_group':
    ensure  => file,
    content => "%sudo ALL=(ALL) NOPASSWD: ALL\n",
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    require => Package['sudo'],
  }
}


# Define apt_update class
class apt_update {
  exec { 'apt_update':
    command => '/usr/bin/apt-get update',
    refreshonly => true,
  }
}

node 'storage-1.openstacklocal', 'storage-2.openstacklocal' {
  include common # Implementing common configuration

  include apt_update #execute 'apt-get update'
 
  package { glusterfs-server:
    ensure  => installed,
    require => Exec['apt_update'],
  }
}
node 'dev-1.openstacklocal', 'dev-2.openstacklocal' {
  include common # Implementing common configuration

  include apt_update #execute 'apt-get update'
  
  package { ['emacs', 'jed', 'git']:
    ensure  => installed,
    require => Exec['apt_update'],
  }
}

node 'compile-1.openstacklocal', 'compile-2.openstacklocal' {
  include common # Implementing common configuration

  include apt_update #execute 'apt-get update'

  package { ['gcc', 'make', 'binutils']:
    ensure  => installed,
    require => Exec['apt_update'],
  }
}
node 'test1.openstacklocal','puppetmaster.openstacklocal' {
  include common # Implementing common configuration

  package { ['ca-certificates', 'curl']:
    ensure => installed,
  }
  # Ensure the keyrings directory exists
  file {'/etc/apt/keyrings':
    ensure => directory,
    mode => '755', 
  }

  # Download the Docker GPG key
  exec { 'download_docker_gpg_key':
    command => '/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc',
    creates => '/etc/apt/keyrings/docker.asc',
    require => File['/etc/apt/keyrings'],
  }

  # Generate the Docker repository list file
  exec { 'generate_docker_list':
command => "/usr/bin/echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${facts['os']['distro']['codename']} stable' > /etc/apt/sources.list.d/docker.list",
    creates => '/etc/apt/sources.list.d/docker.list',
    require => Exec['download_docker_gpg_key'],
  }
#  file { '/etc/apt/sources.list.d/docker.list':
#    ensure  => file,
#    content => "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\n",
#    require => File['/etc/apt/keyrings/docker.asc'],
#  }

  exec { 'update_apt':
    command => '/usr/bin/apt-get update',
    refreshonly => true,
    subscribe   => Exec['generate_docker_list'],
  }

  package { ['docker-ce', 'docker-ce-cli', 'containerd.io', 'docker-buildx-plugin', 'docker-compose-plugin']:
    ensure  => installed,
    require => Exec['update_apt'],
  }

  group { 'docker':
    ensure => present,
  }
  user { 'ubuntu':
    ensure  => present,
    groups  => ['docker'],
    require => Group['docker'],
  }


service { 'docker.service':
  ensure   => 'running',
  enable   => 'true',
  provider => 'systemd',
}
}

node default {
  include common
}
