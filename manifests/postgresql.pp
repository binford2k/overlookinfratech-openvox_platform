# @summary Configures the pgsql server for openvoxdb
#
# Sets up PostgreSQL using the upstream vendor repo and configures it with
# openvox's supported encoding/locale. It also corrects the binaries' selinux
# labeling so that local services can connect via unix socket.
#
# @example
#   include openvox_platform::postgresql
class openvox_platform::postgresql (
  String[1] $version,
  Boolean   $backup,
  Boolean   $manage_package_repo,
  String[1] $password_encryption,
) {
  assert_private()
  require openvox_platform::files

  class { 'postgresql::globals':
    version             => $version,
    manage_package_repo => $manage_package_repo,
    password_encryption => $password_encryption,
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
  }

  # don't contain it. causes apt cycles
  class { 'postgresql::server':
    listen_addresses    => '127.0.0.1',
  }

  if $backup {
    file { '/etc/openvox_platform/pg_backup':
      ensure => 'directory',
    }
    class { 'dbbackup':
      destination         => '/etc/openvox_platform/pg_backup',
      backuphistory       => 21,
      manage_dependencies => true,
    }
    contain dbbackup
  }

  include openvox_platform::selinux
}


# do we want to port any functionality from https://github.com/puppetlabs/puppetlabs-pe_databases?
# OSS and Foreman don't seem to need it as much. Is that due to something architectural
# or is it because those infras tend to be smaller?
