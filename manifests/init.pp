# @summary The main OpenVox platform class
#
# This class sets default parameters for an entire OpenVox infrastructure.
# In most cases, the defaults are acceptable and you can ignore this class.
# If you choose to customize, then declare this class with any desired parameters
# before any other `openvox_platform` class on all nodes of your infrastructure.
#
# @examples
# ```
#   # Declare this on all nodes. Omit this declaration if the default meet needs.
#   class { 'openvox_platform':
#     postgresql_version   => '13',
#     server_multithreaded => false,
#     reports              => 'logs',
#   }
#
#   node 'server.example.com' {
#     include openvox_platform::profile::primary
#   }
#   node /^compiler(\d+).example.com$/ {
#     include openvox_platform::profile::compiler
#   }
#   node default {
#     include openvox_platform::profile::agent
#   }
# ```
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
#   include openvox_platform
#
class openvox_platform (
  Boolean             $foreman,
  Boolean             $puppetdb,
  Optional[String[1]] $reports,
  String              $server_jvm_min_heap_size,
  String              $server_jvm_max_heap_size,
  Boolean             $server_multithreaded,
  String[1]           $postgresql_version,
  Boolean             $postgresql_backup,
  Boolean             $postgresql_manage_package_repo,
  String[1]           $postgresql_password_encryption,
  String[1]           $foreman_version,
  String[1]           $foreman_initial_admin_username,
  String[1]           $foreman_initial_admin_first_name,
  String[1]           $foreman_initial_admin_last_name,
  Optional[String[1]] $foreman_initial_admin_email,
) {
  # Generate a string list of all desired report processors
  $server_reports = [
    $reports,
    $puppetdb ? { true => 'puppetdb', false => undef },
    $foreman  ? { true => 'foreman',  false => undef },
  ].filter |$i| { $i }.join(',')

  if versioncmp($postgresql_version, '11') < 0 {
    fail("OpenVoxDB requires PostgreSQL version 11 or greater.")
  }
}

