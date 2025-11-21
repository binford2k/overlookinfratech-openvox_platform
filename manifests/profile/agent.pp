# @summary Manages an OpenVox platform agent node
#
# The default parameters of this class will manage an OpenVox agent.
#
# @param reports
#   A comma-separated list of report processors to enable. The `foreman` and
#   `puppetdb` processors are added to this list when appropriate. This parameter
#   only makes sense when running in serverless mode.
#
# @example
#   include openvox_platform::profile::agent
#
class openvox_platform::profile::agent (
  Optional[String[1]] $server_hostname = undef,
  Optional[String[1]] $reports         = undef,
) {
  include openvox_platform::files
  include openvox_platform::network

  class { 'openvox_platform::openvox':
    server_hostname          => $server_hostname,
    server                   => false,
    foreman                  => false,
    puppetdb                 => false,
    reports                  => $reports,
  }
}
