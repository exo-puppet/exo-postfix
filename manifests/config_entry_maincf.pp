# == Define: postfix::config_entry_maincf
#
# update or create main.cf entry for postfix
#
define postfix::config_entry_maincf ($value = undef) {

  $key       = $name
  $key_min   = downcase($key)
  $file_path = "${postfix::params::configuration_dir}/main.cf"
  $file_name = basename($file_path)

  if $value {
    file_line { "postfix_main.cfg-${key_min}":
      ensure    => present,
      path      => $file_path,
      line      => "${key} = ${value}",
      match     => "^#? *${key} *=.*$",
      multiple  => false,
      require   => Class['postfix::install'],
      notify    => Service['postfix'],
    }
  } else {
    file_line { "postfix_main.cfg-${key_min}":
      ensure    => absent,
      path      => $file_path,
      line      => "#${key} =",
      match     => "^#? *${key} *=.*$",
      multiple  => true,
      require   => Class['postfix::install'],
      notify    => Service['postfix'],
    }
  }
}
