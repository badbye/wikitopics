#!/usr/bin/env perl

use List::Util 'shuffle';
use URI::Escape;

$date = "2011-05-02";
$lang = "en";
$year = substr $date, 0, 4;
$wikitopics_path = $ENV{'WIKITOPICS'};
$topic_path = "$wikitopics_path/data/topics/$lang/$year/$date.topics";
$articles_path = "$wikitopics_path/data/articles/$lang/$year/$date";

$no_articles = 10;

for ($i=0; $i<$no_articles; $i++) {
	print "article$i,trending_score$i,lead_section$i";
	if ($i < $no_articles-1) {
		print ",";
	}
}
print "\n";

@articles = ();

sub escape_for_csv {
	chomp;
	s/,/&#44;/g;
	s/&/&amp;/g;
	s/^>/&gt;/g;
	s/^</&lt;/g;
	s/"/&quot;/g;
	s/'/&#39;/g;
	return $_;
}

sub print_articles {
	@articles = shuffle(@articles);
	while ($#articles >= 0) {
		for ($i=0; $i<$no_articles && $#articles>=0; $i++) {
			$_ = shift @articles;
			/([^ ]+) .+/;
			$file = uri_escape($1, "^A-Za-z0-9\-\. _~\%");
			$article_path = "$articles_path/$file.article";
			$tags_path = "$articles_path/$file.tags";
			$title = escape_for_csv($_);
			$title =~ s/ /,/;
			$title =~ s/_/ /g;
			print "$title,";
			
			if ((-f "$article_path") && (-f "$tags_path")) {
				open ARTICLE_FILE, "<$article_path";
				open TAG_FILE, "<$tags_path";
				while (<ARTICLE_FILE>) {
					chomp;
					$sentence = escape_for_csv($_);
					$tag = <TAG_FILE>;
					chomp $tag;
					if ($tag eq "Sentence" || $tag eq "LastSentence") {
						print "$sentence";
						if ($tag eq "LastSentence") {
							break;
						} else {
							print " ";
						}
					}
				}
				close TAG_FILE;
				close ARTICLE_FILE;
			}
			if ($i < $no_articles-1) {
				print ",";
			}
		}
		print "\n";
	}
}

open TOPIC_FILE, "<$topic_path";
while (<TOPIC_FILE>) {
	push @articles, $_;
}
close TOPIC_FILE;

@articles = shuffle(@articles);
print_articles;
