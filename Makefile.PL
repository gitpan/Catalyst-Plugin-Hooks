use inc::Module::Install;

name('Catalyst-Plugin-Hooks');
abstract('Hooks to Catalyst');
author('Berik Visschers');
version_from('lib/Catalyst/Plugin/Hooks.pm');
license('perl');

include('ExtUtils::AutoInstall');

requires( Catalyst => '5.7' );

catalyst_files();

#install_script( glob('script/*.pl') );
auto_install();
&WriteAll;

