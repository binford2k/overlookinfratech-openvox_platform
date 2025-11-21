# @summary Manages the repository for installing OpenVox
#
# This will allow you to install openvox-agent, openvox-server, openvoxdb, etc.
# You *can* specify parameters for testing purposes, but the defaults should be
# accurate for production use.
#
# @example
#   include openvox_platform::openvox::repo
class openvox_platform::openvox::repo (
  Stdlib::HTTPUrl $baseurl,
  String[1]       $gpgkey,
) {
  case $facts['os']['family'] {
    'Debian': {
      include apt
      apt::source { 'openvox8-release':
        location => $baseurl,
        release  => "${facts['os']['name']}${facts['os']['release']['major']}".downcase,
        repos    => 'openvox8',
        key      => {
          'name'   => 'openvox-keyring.gpg',
          'source' => $gpgkey,
        },
      }
      apt::pin { 'openvox-release':
        priority   => 1001,
        originator => 'Vox*',
        packages   => 'openvox-agent',
      }
    }
    'RedHat': {
      include yum
      yum::gpgkey { '/etc/pki/rpm-gpg/GPG-KEY-openvox-openvox8-release':
        ensure => present,
        source => $gpgkey,
      }
      yumrepo { 'openvox8':
        ensure   => 'present',
        baseurl  => $baseurl,
        descr    => 'OpenVox 8 Repository',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => 'file:///etc/pki/rpm-gpg/GPG-KEY-openvox-openvox8-release',
      }
    }
    default: {
      fail("Operating system unsupported: ${facts['os']['name']}")
    }
  }

  # any packages declared in the puppet(db) module should be enforced after this
  Class['openvox_platform::openvox::repo'] -> Package <| tag == 'puppet' |>
  Class['openvox_platform::openvox::repo'] -> Package <| tag == 'puppetdb' |>
}
