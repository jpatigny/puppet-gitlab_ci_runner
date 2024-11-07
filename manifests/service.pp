# @summary Manages the service of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::service (
  $package_name = $gitlab_ci_runner::package_name,
) {
  assert_private()

  if $facts['os']['family'] == 'Suse' {
    exec { "${gitlab_ci_runner::install_path}/${gitlab_ci_runner::binary} install -u ${gitlab_ci_runner::user}":
      creates => '/etc/systemd/system/gitlab-runner.service',
    }
  }
  if $facts['os']['family'] == 'windows' {
    exec { 'install gitlab-runner windows service' :
      command   => "& ${gitlab_ci_runner::install_path}/${gitlab_ci_runner::binary} install -c ${gitlab_ci_runner::config_path} -d ${gitlab_ci_runner::install_path}",
      onlyif    => "if(!(Get-Service -Name 'gitlab-runner')) { exit 0 } else { exit 1 }",
      provider  => powershell,
      logoutput => true,
      notify    => Service[$package_name],
    }
  } 
  service { $package_name:
    ensure => running,
    enable => true,
  }
}
