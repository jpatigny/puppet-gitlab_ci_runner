# @summary Manages the package of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::install (
  $package_name   = $gitlab_ci_runner::package_name,
  $package_ensure = $gitlab_ci_runner::package_ensure,
) {
  assert_private()
  if $facts['os']['family'] != 'windows' {
    case $gitlab_ci_runner::install_method {
      'repo': {
        package { $package_name:
          ensure => $package_ensure,
        }
      }
      'binary': {
        $_package_ensure = $package_ensure ? {
          'installed' => 'present',
          default  => $package_ensure,
        }
        archive { $gitlab_ci_runner::binary_path:
          ensure  => $_package_ensure,
          source  => $gitlab_ci_runner::binary_source,
          extract => false,
          creates => $gitlab_ci_runner::binary_path,
        }
        file { $gitlab_ci_runner::binary_path:
          ensure => file,
          mode   => '0755',
        }
        if $gitlab_ci_runner::manage_user {
          group { $gitlab_ci_runner::group:
            ensure => present,
          }
          user { $gitlab_ci_runner::user:
            ensure => present,
            gid    => $gitlab_ci_runner::group,
          }
        }
      }
      default: {
        fail("Unsupported install method: ${gitlab_ci_runner::install_method}")
      }
    }
  } else {
    case $gitlab_ci_runner::install_method {
      'binary': {
        file { $gitlab_ci_runner::install_path :
          ensure => directory
        }
        file { "${gitlab_ci_runner::install_path}/${gitlab_ci_runner::binary}" :
          ensure => file,
          source => $gitlab_ci_runner::binary_source,
          require => File[$gitlab_ci_runner::install_path]
        }          
      }
      default: {
        fail("Unsupported install method for windows: ${gitlab_ci_runner::install_method}")
      }
    }
  }
}
