# == Define: postfix::map_file
#
# Populate a map file and create the associated postfix lookup table
#
define postfix::map_file (
  $filename = "$postfix::params::configuration_dir/$name",
  $content
) {
 file { $filename:
   ensure => $ensure,
   content => $content,
   notify  => Exec["postmap_$name"],
 }

 exec { "postmap_$name" :
   command     => "postmap ${filename}",
   path        => "/usr/sbin",
   refreshonly => true,
 }
}
