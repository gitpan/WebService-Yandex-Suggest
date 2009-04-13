use strict;
use Test::More tests => 5;

BEGIN { use_ok 'WebService::Yandex::Suggest' }

my $suggest = WebService::Yandex::Suggest->new();

isa_ok($suggest->ua, "LWP::UserAgent", "ua() returns LWP");

my @data = $suggest->complete("goog");
is($data[0], "google", "goog completes to google");
ok($data[0], "yandex has more than 0 results");
is_deeply( [ $suggest->complete("sdfsdgfskdg") ], [ ], "empty list" );

