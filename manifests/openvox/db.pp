# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include openvox_platform::openvox::db
class openvox_platform::openvox::db {
  assert_private()

  require openvox_platform::postgresql
  include postgresql::server::contrib

  class { 'puppetdb':
    puppetdb_package => 'openvoxdb',
    manage_dbserver  => false,
    manage_firewall  => false,
  }

  class { 'puppet::server::puppetdb':
    server           => $facts['networking']['fqdn'],
    terminus_package => openvoxdb-termini,
  }

  postgresql::server::extension { 'pg_trgm':
    database => 'puppetdb',
    require  => Postgresql::Server::Db['puppetdb'],
    before   => Service['puppetdb'],
  }

  contain puppetdb
  contain puppet::server::puppetdb
}
