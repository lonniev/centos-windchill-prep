default['centos-windchill-prep'] =
{
  'images_repo' => 'https://storage.googleapis.com/windchill/',
  'base_images' => %w( 2101 60702 60318 60419 60703 60757 60800 ),
  'revised_images' => %w( 60171 60379 60418 60898 ),
  'psi_cd' => '60702',
  'version' => '110',
  'datecode' => 'M030',
  'java_pkg' => 'java-1.8.0-openjdk-devel'
}
