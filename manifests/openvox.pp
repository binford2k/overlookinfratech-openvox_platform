# @summary This sets up the OpenVox primary server, with CA
#
#
# @example
#   include openvox_platform::openvox
class openvox_platform::openvox (
  Integer $port                        = 8140,
  Optional[String[1]] $server_hostname = undef,
  Boolean $server                      = true,
  Boolean $foreman                     = true,
  Boolean $puppetdb                    = true,
  Optional[String[1]] $reports         = undef,
  String $jvm_min_heap_size,
  String $jvm_max_heap_size,
  Boolean $multithreaded,
) {
  assert_private()
  include openvox_platform::openvox::repo

  # Generate a string list of all desired report processors
  $server_reports = [
    $reports,
    $puppetdb ? { true => 'puppetdb', false => undef },
    $foreman  ? { true => 'foreman',  false => undef },
  ].filter |$i| { $i }.join(',')

  # use Foreman's puppet module for the heavy lifting
  class {'puppet':
    server_port                => $port,
    agent_server_hostname      => $server_hostname,
    server_package             => 'openvox-server',
    client_package             => 'openvox-agent',
    server                     => $server,
    server_reports             => $server_reports,
    server_storeconfigs        => $puppetdb,
    server_foreman             => $foreman,
    server_jvm_min_heap_size   => $jvm_min_heap_size,
    server_jvm_max_heap_size   => $jvm_max_heap_size,
    server_multithreaded       => $multithreaded,
  }
}
