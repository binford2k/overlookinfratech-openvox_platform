# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include openvox_platform::foreman
class openvox_platform::foreman (
  String[1]               $version,
  String[1]               $initial_admin_username,
  String[1]               $initial_admin_first_name,
  String[1]               $initial_admin_last_name,
  Optional[Stdlib::Email] $initial_admin_email,
  Boolean                 $puppetdb,
) {
  assert_private()
  unless $facts['os']['architecture'] in ['x86_64', 'amd64'] {
    fail('The Foreman does not support this architecture')
  }
  $supported = {
    'RedHat' => ['9'],
    'CentOS' => ['9'],
    'Debian' => ['11', '12'],
    'Ubuntu' => ['22.04'],
  }
  unless $facts['os']['release']['major'] in $supported[$facts['os']['name']] {
    #todo: we need better platform support!
    fail('The Foreman does not support this platform')
  }

  class {'redis':
    manage_repo    => true, # these params only do things on the appropriate platforms
    redis_apt_repo => true, # Debian, without ppa_repo set
  }
  require redis
  require openvox_platform::postgresql
  require openvox_platform::selinux

  include openvox_platform::foreman::support

  class { 'foreman::repo':
    repo => $version,
  }
  Foreman::Repos['foreman'] -> Package <| tag == 'foreman' |>

  class { 'foreman':
    logging_type        => 'journald',
    rails_cache_store   => {
      'type'    => 'redis',
      'urls'    => ['localhost:6379/0'],
      'options' => {
        'compress'  => 'true',
        'namespace' => 'foreman',
      },
    },
    initial_admin_username   => $initial_admin_username,
    initial_admin_first_name => $initial_admin_first_name,
    initial_admin_last_name  => $initial_admin_last_name,
    initial_admin_email      => $initial_admin_email,
  }

  include foreman::cli
  include foreman::cli::puppet
  include foreman::plugin::puppet

  if $puppetdb {
    include foreman::plugin::puppetdb
  }

  class { 'foreman_proxy':
    puppet              => true,
    puppetca            => true,
    tftp                => false,
    dhcp                => false,
    dns                 => false,
    bmc                 => false,
    realm               => false,
  }

  # include foreman::plugin::hdm
  # include foreman::plugin::tasks
  # include foreman::plugin::hooks
  # include foreman::plugin::openscap
  # include foreman::plugin::default_host_group
}
