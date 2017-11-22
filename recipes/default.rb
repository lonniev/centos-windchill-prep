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

# a variety of utilities and build packages that the Windchill installer will need
%w(
  wget
  less
  unzip
  java-1.8.0-openjdk-devel
  xterm )
.each do |pkg|
  yum_package pkg.to_s
end

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

revised = %w( 60702 60318 60419 60703 60757 60800 ).map { |e| "MED-#{e}-CD-110_M030.zip" }
base = %w( 60171 60379 60418 60898 ).map { |e| "MED-#{e}-CD-110_F000.zip" }

(base|revised)
.each do |file|
  bash "get remote #{file}" do
    cwd "/media/windchill"
    code "wget -q -O /media/windchill/#{file} https://storage.googleapis.com/windchill/#{file}"
    user 'root'
    group 'root'
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
