# @summary Manages an OpenVox platform compiler server
#
# The default parameters of this class will manage a primary OpenVox server used
# as a secondary compiler server.
#
# @param reports
#   A comma-separated list of report processors to enable. The `foreman` and
#   `puppetdb` processors are added to this list when appropriate.
# @param server_jvm_min_heap_size
# @param server_jvm_max_heap_size
# @param server_multithreaded
#   Run the OpenVox server in multithreaded mode. This will increase performance
#   but has a small risk of triggering non-threadsafe code in module plugins.
#
# @example
#   include openvox_platform::profile::compiler
#
class openvox_platform::profile::compiler (
  Optional[String[1]] $server_hostname = undef,
  Optional[String[1]] $reports         = undef,
  String              $jvm_min_heap_size,
  String              $jvm_max_heap_size,
  Boolean             $multithreaded,
) {
  include openvox_platform::files
  include openvox_platform::network

  class { 'openvox_platform::openvox':
    server_hostname          => $server_hostname,
    server                   => true,
    foreman                  => false,
    puppetdb                 => false,
    reports                  => $reports,
    server_jvm_min_heap_size => $jvm_min_heap_size,
    server_jvm_max_heap_size => $jvm_max_heap_size,
    server_multithreaded     => $multithreaded,
  }

  if lookup('openvox_platform::openvoxdb') {
    @@haproxy::balancermember { $facts['networking']['fqdn']:
      listening_service => 'puppet00',
      server_names      => $facts['networking']['hostname'],
      ipaddresses       => $facts['networking']['ip'],
      ports             => 8140,
      options           => 'check',
    }
  }
}
