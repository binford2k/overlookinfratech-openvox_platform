# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include openvox_platform::profile::load_balancer::compiler
class openvox_platform::profile::load_balancer::compiler {
  include haproxy
  haproxy::listen { 'openvox00':
    ipaddress        => $facts['networking']['ip'],
    ports            => [8140],
  }
}
