# @summary Manages the package of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::install (
  $package_name   = $gitlab_ci_runner::package_name,
  $package_ensure = $gitlab_ci_runner::package_ensure,
) {
  assert_private()

  case $gitlab_ci_runner::install_method {
    'repo': {
      case $facts['os']['family'] {
        'windows': {
          package { $package_name:
            ensure          => $package_ensure,
            provider        => 'chocolatey',
          }
        }
        default: {
          package { $package_name:
            ensure   => $package_ensure,
          }
        }
      }
    }
    'binary': {
      if $facts['os']['family'] == "RedHat" {
        file { "${gitlab_ci_runner::install_path}/${gitlab_ci_runner::binary}":
          ensure  => file,
          source  => $gitlab_ci_runner::binary_source,
          mode    => '0755',
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
      if $facts['os']['family'] == "windows" {
        file { "${gitlab_ci_runner::install_path}/${gitlab_ci_runner::binary}":
          ensure  => file,
          source  => $gitlab_ci_runner::binary_source,
        }
      }
    }
    default: {
      fail("Unsupported install method: ${gitlab_ci_runner::install_method}")
    }
  }
}
