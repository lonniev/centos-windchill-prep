#
# Cookbook Name:: centos-windchill-prep
# Recipe:: default
#
# Author:: Lonnie VanZandt <lonniev@gmail.com>
# Copyright 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'digest'

# a variety of utilities and build packages that the Windchill installer will need
%w(
  wget
  less
  unzip
  xterm )
.each do |pkg|
  yum_package pkg.to_s
end

yum_package node['centos-windchill-prep']['java_pkg']

# add the Windchill user
user 'wcadmin' do
  comment 'the wcadmin System user'
  manage_home true
  shell '/bin/bash'
  password '$1$Ka5NuI06$aC0/ZmV4ocmk91n86bH.K0'
end

# add the Windchill groups
%w( wcadmin )
.each do |grp|
  group grp.to_s do
    action :create
    members 'wcadmin'
  end
end

# give ~wcadmin a useful .bash_profile
file "/home/wcadmin/.bash_profile" do
  owner 'wcadmin'
  group 'wcadmin'
  mode '0755'
  content <<~HERE
    # borrowed from https://wiki.centos.org/HowTos/Oracle12onCentos7

    TMPDIR=$TMP; export TMPDIR
    ORACLE_BASE=/home/oracle/app/oracle; export ORACLE_BASE
    ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1; export ORACLE_HOME
    ORACLE_SID=wind; export ORACLE_SID
    PATH=$ORACLE_HOME/bin:$PATH; export PATH
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/lib64; export LD_LIBRARY_PATH
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH

    WT_HOME=/opt/ptc/Windchill11_0/Windchill11_0; export WT_HOME

    export DISPLAY=:1.0
  HERE
end

# copy over the Windchill images from some accessible remote site
%w( /media /media/windchill /media/StagingDirectory )
.each do |dir|
  directory dir.to_s do
    owner 'root'
    group 'root'
    mode '0777'
    action :create
  end
end

psi_cd = node['centos-windchill-prep']['psi_cd']
version = node['centos-windchill-prep']['version']
datecode = node['centos-windchill-prep']['datecode']

revised = node['centos-windchill-prep']['revised_images'].map { |e| "MED-#{e}-CD-#{version}_#{datecode}.zip" }
base = node['centos-windchill-prep']['base_images'].map { |e| "MED-#{e}-CD-#{version}_F000.zip" }

baseSums = base.zip( node['centos-windchill-prep']['base_sums'] ).to_h
revisedSums = revised.zip( node['centos-windchill-prep']['revised_sums'] ).to_h

md5sums = baseSums.merge( revisedSums )

(base|revised)
.each do |file|
  bash "get remote #{file}" do
    cwd "/media/windchill"
    code "wget -q -O /media/windchill/#{file} #{node['centos-windchill-prep']['images_repo']}#{file}"
    user 'root'
    group 'root'

    not_if { ( File.exists?( "/media/windchill/#{file}" ) ) && ( Digest::MD5.file( "/media/windchill/#{file}" ).hexdigest == md5sums[ file ] ) }

  end

end

# now unzip the downloaded files
(base|revised)
.each do |zip|
  execute "unzip #{zip}" do
    command "unzip -q -o -d /media/StagingDirectory/#{zip.gsub( /\.zip/, "" )} /media/windchill/#{zip}"
    user 'root'
    group 'root'
  end
end

# create a convenience link to the PSI installer directory
link '/media/PSI' do
  to "/media/StagingDirectory/MED-#{psi_cd}-CD-#{version}_#{datecode}"
end
