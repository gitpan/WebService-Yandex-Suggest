package WebService::Yandex::Suggest;

use strict;
use vars qw($VERSION);
$VERSION = '1.00';

use Carp;
use LWP::UserAgent;
use URI::Escape;

use vars qw($CompleteURL);
$CompleteURL = "http://suggest.yandex.ru/suggest-ya.cgi?ct=text/html&v=2&part=";

sub new {
	my $class = shift;
	my $ua = LWP::UserAgent->new();
	$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
	bless { ua => $ua }, $class;
}

sub ua { $_[0]->{ua} }

sub complete {
	my ($self, $query) = @_;
	my $url = $CompleteURL.uri_escape(str2utf8($query));

	my $response = $self->ua->get($url);
	$response->is_success or croak "Yandex returns HTTP error: ".$response->status_line;
	my $content = $response->content();

	$content = ($content =~ /apply\((.*?)\)$/sig)[0];
	$content =~ s/^"$query",\s*//;				# skip head
	$content =~ s/,\s*{[^}]}$//;				# skip tale
	if ($content =~ /^\[(.*?)\]/){
		$content = $1;
		$content =~ s/\[[^\]]*\]//g;			# skip inner arrays
		return map { s/^"\s*(.*?)\s*"$/$1/; $_ } split /\s*,\s*/, $content;
	} else {
		croak "Yandex returns unrecognized format: $content";
	}
}

sub str2utf8{
	my $in_str = shift();
	my @chars = split (//, $in_str);

	my $str = '';
	my $rus_abc = "àáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß";
	my $rus_abc_utf8 = "Ð°Ð±Ð²Ð³Ð´ÐµÑ‘Ð¶Ð·Ð¸Ð¹ÐºÐ»Ð¼Ð½Ð¾Ð¿Ñ€ÑÑ‚ÑƒÑ„Ñ…Ñ†Ñ‡ÑˆÑ‰ÑŠÑ‹ÑŒÑÑŽÑÐÐ‘Ð’Ð“Ð”Ð•ÐÐ–Ð—Ð˜Ð™ÐšÐ›ÐœÐÐžÐŸÐ Ð¡Ð¢Ð£Ð¤Ð¥Ð¦Ð§Ð¨Ð©ÐªÐ«Ð¬Ð­Ð®Ð¯";

	foreach (@chars) {
		my $pos = index($rus_abc, $_);
		if ($pos > -1){
			$str .= substr($rus_abc_utf8, $pos*2, 2);
		} else {
			$str .= $_;
		}
	}

	return $str;
}

1;
__END__

=head1 NAME

WebService::Yandex::Suggest - Yandex Suggest as an API

=head1 SYNOPSIS

  use WebService::Yandex::Suggest;

  my $suggest = WebService::Yandex::Suggest->new();
  my @suggestions = $suggest->complete("ÿíäå");
  for my $suggestion (@suggestions) {
      print "$suggestion\n";
  }

=head1 DESCRIPTION

WebService::Yandex::Suggest is simple pure-perl implementation which allows you to use Yandex Suggest as a Web Service API to retrieve completions to your search query or partial query.

=head1 METHODS

=over 4

=item new

  $suggest = WebService::Yandex::Suggest->new();

Creates new WebService::Yandex::Suggest object.

=item complete

  @suggestions = $suggest->complete($query);

Sends your C<$query> to Yandex web server and fetches suggestions for
the query. Suggestions are in a list

=item ua

  $ua = $suggest->ua;

Returns underlying LWP::UserAgent object. It allows you to change
User-Agent (Windows IE by default), timeout seconds and various
properties.

=back

=head1 AUTHOR

Oleg Nikitin E<lt>olegn@stratek.ruE<gt>, module initially based on Tatsuhiko Miyagawa's E<lt>miyagawa@bulknews.netE<gt> WebService::Google::Suggest

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

This module gives you B<NO WARRANTY>.

=cut
