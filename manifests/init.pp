# Class: postfix
#
# This module manages postfix, our defacto MTA
#
# Requires:
#   $postfix_type must be set for systems that are not your basic mail client
#
class postfix {

    $root_mail = "root"
    $postmaster_mail = "root"

    include postfix::client
    
    package {
        "postfix": ;
    } # package

    file {
        "/etc/mailname":
            require => Package["postfix"],
            notify  => Service["postfix"],
		    owner   => root,
		    group   => root,            
            content => "$::fqdn\n";
        "/etc/postfix/aliases":
            require => Package["postfix"],
		    owner   => root,
		    group   => root,            
            content => template("postfix/aliases.erb");
            #notify  => Exec["postalias"];
        "/etc/aliases":
            ensure  => link,
		    owner   => root,
		    group   => root,            
            target  => "/etc/postfix/aliases";
        "/etc/postfix/roleaccount_exceptions":
            source  => "puppet:///modules/postfix/roleaccount_exceptions",
		    owner   => root,
		    group   => root,            
            require => Package["postfix"],
            notify  => Exec["postmap-roleaccount_exceptions"];
    } # file

    exec {
        "postmap-roleaccount_exceptions":
            command     => "/usr/sbin/postmap /etc/postfix/roleaccount_exceptions",
		    user   => root,
		    group   => root,            
            require     => File["/etc/postfix/roleaccount_exceptions"],
            refreshonly => true;
    } # exec

    service { "postfix":
        ensure  => running,
        enable  => true,
        require => Package["postfix"], ;
    } # service

    # Definition: postfix::post_files
    #
    # setup postfix with a custom main.cf and master.cf 
    #
    # Actions:
    #   setup postfix with a custom main.cf and master.cf
    #
    # Sample Usage:
    #   post_files { "client": }
    #
    define post_files() {
        File {
            require => Package["postfix"],
            notify  => Service["postfix"],
		    owner   => root,
		    group   => root,                        
        }

        file { 
            "/etc/postfix/master.cf":
                source => [ "puppet:///modules/postfix/$name/master.cf-$::operatingsystem", "puppet:///modules/postfix/$name/master.cf" ],
			    owner   => root,
			    group   => root,                            
                links  => follow;
            "/etc/postfix/main.cf":
			    owner   => root,
			    group   => root,                       
                content => template("postfix/$name/main.cf.erb");
        } # file
    } # define post_files

    # Definition: postfix::postalias    
    #
    # postalias will run postalias on your alias file. If you do not specify one
    # the default of /etc/postfix/aliases is used.
    #
    # Parameters:
    #   $aliasfile - path to an alias file, defaults to /etc/postfix/aliases
    #
    # Requires:
    #   a file{} of your aliases already defined
    #
    # Sample Usage:
    #   postalias { "client": }
    #
    define postalias($aliasfile = undef) {
        # if aliasfile is unspecified, use /etc/postfix/aliases
        if $aliasfile {
            $myaliasfile = $aliasfile
        } else {
            $myaliasfile = "/etc/postfix/aliases"
        }

        exec { "postalias-$name":
            command     => "/usr/sbin/postalias $myaliasfile",
            require     => [ Package["postfix"], File["$myaliasfile"]],
		    user   => root,
		    group   => root,                        
        } # exec
    } # define postalias

} # class postfix

# Class: postfix::client
#
# generic class for all clients
#
class postfix::client inherits postfix {
    post_files { "client": }
    postalias { "client": }

    # this file is only present for client config
    file { "/etc/postfix/sender_regexp":
        require => Package["postfix"],
        notify  => Service["postfix"],
	    owner   => root,
	    group   => root,                    
        content => template("postfix/client-sender_regexp.erb"),
    }
} # class postfix::client

#
# pflogsumm - gives us mail stats
#
class postfix::pflogsumm inherits postfix {

    package { "postfix-pflogsumm": }

    cron { "pflogsumm_daily":
        command => "/usr/sbin/pflogsumm -d yesterday /var/log/maillog 2>&1 |/bin/mail -s \"[Daily mail stats for `uname -n`]\" root",
        user    => "root",
        hour    => "0",
        minute  => "10",
        require => Package["postfix-pflogsumm", "postfix"],
    } # cron
} # class postfix::pflogsumm
