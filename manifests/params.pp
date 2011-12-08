# Class: postfix::params
#
# This class manage the postfix parameters for different OS
class postfix::params {
	
	$ensure_mode = $postfix::lastversion ? {
		true => latest,
		default => present
	}
	info ("postfix ensure mode = $ensure_mode")
	
	$package_name		= [ "postfix" ]

	case $::operatingsystem {
		/(Ubuntu|Debian)/: {
			$service_name		= "postfix"
		}
		default: {
			fail ("The ${module_name} module is not supported on $::operatingsystem")
		}
	}
}
