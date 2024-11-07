# @summary Manages the service of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::service (
  $package_name = $gitlab_ci_runner::package_name,
) {
  assert_private()

  if $facts['os']['family'] == 'Suse' {
    exec { "${gitlab_ci_runner::binary_path} install -u ${gitlab_ci_runner::user}":
      creates => '/etc/systemd/system/gitlab-runner.service',
    }
  }
  if $facts['os']['family'] == 'windows' {
    $install_path = join(split($gitlab_ci_runner::binary_path, '/')[0, 1], '/')
    registry::service { $package_name:
      ensure       => present,
      display_name => $package_name,
      description  => $package_name,
      command      => "${gitlab_ci_runner::binary_path} run --working-directory ${install_path} --config ${install_path}/config.toml --service ${package_name} --syslog",
      start        => 'automatic',
      notify       => Service[$package_name]
    }
  } 
  service { $package_name:
    ensure => running,
    enable => true,
  }
}
