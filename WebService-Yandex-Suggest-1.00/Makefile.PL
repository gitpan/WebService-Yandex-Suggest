use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'WebService::Yandex::Suggest',
    'VERSION_FROM' => 'lib/WebService/Yandex/Suggest.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
	LWP::UserAgent => 0,
    },
);
