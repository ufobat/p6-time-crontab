NAME
====

Time::Crontab for perl6

SYNOPSIS
========

	use Time::Crontab;
	my $crontab = "* * * * *";
	my $tc = Time::Crontab.new(:$crontab);
	if $tc.match(DateTime.now, :truncate(True)) { ..... }

