name             'centos-windchill-prep'
maintainer       'Lonnie VanZandt'
maintainer_email 'lonniev@gmail.com'
license          'Apache 2.0'
description      'Prepares user and files for Windchill installation'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w( centos redhat fedora ).each do |os|
  supports os
end

recipe 'centos-windchill-prep::default', 'Prepares user and files for Windchill installation'
