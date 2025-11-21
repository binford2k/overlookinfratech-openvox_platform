# @summary Manages an OpenVox platform primary server
#
# The default parameters of this class will manage a primary OpenVox server with
# Foreman and OpenVoxDB. You may also choose to disable `foreman` to get a non-GUI
# server
#
# @param foreman
#   Whether or not to configure Foreman on this node.
# @param puppetdb
#   Whether or not to configure OpenVoxDB on this node.
# @param reports
#   A comma-separated list of report processors to enable. The `foreman` and
#   `puppetdb` processors are added to this list when appropriate.
# @param server_jvm_min_heap_size
# @param server_jvm_max_heap_size
# @param server_multithreaded
#   Run the OpenVox server in multithreaded mode. This will increase performance
#   but has a small risk of triggering non-threadsafe code in module plugins.
# @param postgresql_version
#   Choose the pgsql version you'd like. If the selected version is available from
#   your distro, it will be preferred. If you've selected a newer version then it
#   will come from vendor repositories.
# @param postgresql_backup
#   Configure a regular database backup. These will be saved as psql tarballs
#   in `/etc/openvox_platform/pg_backup` by default.
# @param postgresql_manage_package_repo
#   Enable the vendor package repo so you can use newer (non-EOL) versions.
# @param postgresql_password_encryption
#   This defaults to `scram-sha-256` which is the upstream default since version
#   14. If needed, you may revert to `md5`.
# @param foreman_version
#   Choose the Foreman version to install. Note that installing older versions may
#   not be fully supported.
# @param foreman_initial_admin_username
# @param foreman_initial_admin_first_name
# @param foreman_initial_admin_last_name
# @param foreman_initial_admin_email
#
# @example
#   include openvox_platform::profile::primary
#
class openvox_platform::profile::primary (
  Optional[Boolean]       $foreman = undef,
  Optional[Boolean]       $puppetdb = undef,
  Optional[String[1]]     $reports = undef,
  Optional[String]        $jvm_min_heap_size = undef,
  Optional[String]        $jvm_max_heap_size = undef,
  Optional[Boolean]       $multithreaded = undef,
  Optional[String[1]]     $postgresql_version = undef,
  Optional[Boolean]       $postgresql_backup = undef,
  Optional[Boolean]       $postgresql_manage_package_repo = undef,
  Optional[String[1]]     $postgresql_password_encryption = undef,
  Optional[String[1]]     $foreman_version = undef,
  Optional[String[1]]     $foreman_initial_admin_username = undef,
  Optional[String[1]]     $foreman_initial_admin_first_name = undef,
  Optional[String[1]]     $foreman_initial_admin_last_name = undef,
  Optional[Stdlib::Email] $foreman_initial_admin_email = undef,
) {
  include openvox_platform::files
  include openvox_platform::network

  class { 'openvox_platform::openvox':
    server                   => true,
    foreman                  => $foreman,
    puppetdb                 => $puppetdb,
    reports                  => $reports,
    server_jvm_min_heap_size => $jvm_min_heap_size,
    server_jvm_max_heap_size => $jvm_max_heap_size,
    server_multithreaded     => $multithreaded,
  }

  if $foreman or $puppetdb {
    include openvox_platform::postgresql
  }

  if $foreman {
    include openvox_platform::foreman
  }

  if $puppetdb {
    if versioncmp($postgresql_version, '11') < 0 {
      fail("OpenVoxDB requires PostgreSQL version 11 or greater.")
    }
    include openvox_platform::openvox::db
  }

  if lookup('openvox_platform::openvoxdb') {
    # This exports a haproxy record. This has no effect unless you also stand up
    # an `openvox_platform::load_balancer` to use them.
    @@haproxy::balancermember { $facts['networking']['fqdn']:
      listening_service => 'openvox00',
      server_names      => $facts['networking']['hostname'],
      ipaddresses       => $facts['networking']['ip'],
      ports             => [8140],
      options           => 'check',
    }
  }
}
