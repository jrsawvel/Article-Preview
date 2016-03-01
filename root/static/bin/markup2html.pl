#!/usr/bin/perl -wT

use strict;
$|++;


use lib '../../lib/CPAN';

use REST::Client;
use JSON::PP;
use HTML::Entities;
use Encode;
use Data::Dumper;

require '/home/article/Article/root/static/modules/Page.pm';

my $text_dir = "/home/article/Article/root/static/txt/";

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUsage: markup2html.pl markup-input html-output\n";
    exit;
}
 
my $text_file = $ARGV[0];

my $original_markup;

open(my $fh, "<", $text_file) or die "cannot open $text_file for read: $!";
while ( <$fh> ) {
#    chomp;
    $original_markup .= $_; 
}
close($fh) or warn "close failed: $!";


    my $markup = Encode::decode_utf8($original_markup);
    $markup = HTML::Entities::encode($markup,'^\n^\r\x20-\x25\x27-\x7e');

    my $api_url = "http://article.soupmode.com/api/v1";

    my $hash = {
        'submit_type' => "Preview",
        'markup'      => $markup,
    };

    my $json_input = encode_json $hash;

    my $headers = {
        'Content-type' => 'application/json'
    };

    my $rest = REST::Client->new( {
        host => $api_url,
    } );

    $rest->POST( "/posts" , $json_input , $headers );

    my $rc = $rest->responseCode();

    my $json = decode_json $rest->responseContent();

    if ( $rc >= 200 and $rc < 300 ) {
            my $t = Page->new("articlehtml");
            if ($t->is_error) {
                print $t->get_error_message();
            } 

            my $html = $json->{html};
            $t->set_template_variable("html", $html);
            $t->set_template_variable("title", $json->{title});
            # $t->set_template_variable("author", $json->{author});
            $t->set_template_variable("author", "Static");
            $t->set_template_variable("created_date_top", modify_date($json->{created_date}));
            $t->set_template_variable("created_date", $json->{created_date});
            $t->set_template_variable("created_time", $json->{created_time});
            $t->set_template_variable("word_count", $json->{word_count});
            $t->set_template_variable("reading_time", $json->{reading_time});
  
            if ( $json->{using_aside} ) {
                $t->set_template_variable("using_aside", 1);
                $t->set_template_variable("aside_text", $json->{aside_text});
            }

            $t->display_page($json->{title});
    } elsif ( $rc >= 400 and $rc < 500 ) {
         die "$json->{description} $json->{user_message} $json->{system_message}";
    } else  {
         die "Unable to complete request. Invalid response code returned from API. $json->{user_message} $json->{system_message}";
    }


sub modify_date {
    my $date_str = shift; # Mon, 22 Feb 2016

    my @arr = split / /, $date_str;

    return "$arr[2] $arr[1], $arr[3]";

}

__END__

    my $original_markup = <<MARKUP;
# Test Post
para one
para two
MARKUP

