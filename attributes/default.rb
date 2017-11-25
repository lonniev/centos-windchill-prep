default['centos-windchill-prep'] =
{
  'images_repo' => 'https://storage.googleapis.com/windchill/',
  'base_images' => %w( 2101 60171 60379 60418 60898 ),
  'base_sums' => %w(
    0c8e184340a1b90d1aa72e8fe0e95f16
    6c52a80c664e92ab5b29f0413b94d320
    4d818d22fcff3d322f200551e1abbe61
    8a35cfd4af138e3d3f56822b9b035110
    aabf56d6210aae642279e8d7b0ceea61
  ),
  'revised_images' => %w( 60318 60419 60702 60703 60757 60800 ),
  'revised_sums' => %w(
    a5d91bd311b706e306c116af600a46bc
    fabec152f1b6792323b01f89d30bca39
    9a95ac245971c742af5f06fd1d47864d
    661f7770c0981b383e02936b355adcd5
    45173216a33e9aa6577664ab9ea123b3
    e211a4c4800cffd22f53b3d547009fab
  ),
  'psi_cd' => '60702',
  'version' => '110',
  'datecode' => 'M030',
  'java_pkg' => 'java-1.8.0-openjdk-devel'
}
