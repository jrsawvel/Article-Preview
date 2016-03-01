package Format;

use strict;
use warnings;

use Text::TextileArticle;
use Text::MultiMarkdownArticle;
use LWP::Simple;
use HTML::TokeParser;

# hashtag suport sub
# my @tags     = Utils::create_tag_array($markup);
#    'tags'              =>  \@tags,
sub create_tag_array {
    my $str = shift; # using the markup code content

    my $tag_list_str = "";

    $str = " " . $str . " "; # hack to make regex work
    my @tags = ();
    my @unique_tags = (); 
    if ( (@tags = $str =~ m|\s#(\w+)|gsi) ) {
        $tag_list_str = "|";
            foreach (@tags) {
               my $tmp_tag = $_;
               # next if  Utils::is_numeric($tmp_tag); 
               if ( $tag_list_str !~ m|$tmp_tag| ) {
                   $tag_list_str .= "$tmp_tag|";
                   push(@unique_tags, $tmp_tag); 
               }
           }
    }
    return @unique_tags;
}

sub hashtag_to_link {
    my $str = shift;

    $str = " " . $str . " "; # hack to make regex work

    my @tags = ();
    my $tagsearchstr = "";
    my $tagsearchurl = "/tag/";
    if ( (@tags = $str =~ m|\s#(\w+)|gsi) ) {
            foreach (@tags) {
                next if  Utils::is_numeric($_); 
                $tagsearchstr = " <a href=\"$tagsearchurl$_\">#$_</a>";
                $str =~ s|\s#$_|$tagsearchstr|is;
        }
    }
    $str = Utils::trim_spaces($str);
    return $str;
}


sub remove_aside_command {
    my $str = shift;

    while ( $str =~ m|^aside[\s]*=[\s]*(.+)|im ) {
        my $aside = $1;
        $str =~ s|^aside[\s]*=[\s]*$aside||im;
    }

    return $str;
}


sub remove_image_header_commands {
    my $str = shift;
    while ( $str =~ m|^imageheader[\s]*=[\s]*(.+)|im ) {
        my $url = $1;
        $str =~ s|^imageheader[\s]*=[\s]*$url||im;
    }
    while ( $str =~ m|^largeimageheader[\s]*=[\s]*(.+)|im ) {
        my $url = $1;
        $str =~ s|^largeimageheader[\s]*=[\s]*$url||im;
    }
    return $str;
}

sub remove_power_commands {
    my $str = shift;

    # toc=yes|no    (table of contents for the article)
    # using_css=yes|no    
    # tint_image_header=yes|no    
    # title_over_image=yes|no
    # publish_info_at_top=yes|no
    # url_to_link=yes|no
    # hashtag_to_link=yes|no
    # markdown=yes|no - needed because the default markup for a note is textile. this overrides it.
    # newline_to_br=yes|no

    $str =~ s|^toc[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^using_css[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^tint_header_image[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^title_over_image[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^publish_info_at_top[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^url_to_link[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^hashtag_to_link[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^markdown[\s]*=[\s]*[noNOyesYES]+||mig;
    $str =~ s|^newline_to_br[\s]*=[\s]*[noNOyesYES]+||mig;

    return $str;
}

sub extract_css {
    my $str = shift;

    my $return_data; 

    $str =~ s/^css[.][.]/<\/css>/igm;
    $str =~ s/^css[.]/<css>/igm;

    if ( $str =~ m/^(.*?)<css>(.*?)<\/css>(.*?)$/is ) {
        $return_data->{markup} = $1 . $3;
        $return_data->{custom_css}    = $2;
    } else {
        $return_data->{markup} = $str;
        $return_data->{custom_css} = "";
    }

    return $return_data;
}

sub get_power_command_on_off_setting_for {
    my ($command, $str, $default_value) = @_;

    my $binary_value = $default_value;   # default value should come from config file
    
    if ( $str =~ m|^$command[\s]*=[\s]*(.*?)$|mi ) {
        my $string_value = Utils::trim_spaces(lc($1));
        if ( $string_value eq "no" ) {
            $binary_value = 0;
        } elsif ( $string_value eq "yes" ) {
            $binary_value = 1;
        }
    }
    return $binary_value;
}

sub custom_commands {
    my $formattedcontent = shift;
    my $postid = shift;

    # q. and q..
    # br.
    # hr.
    # more.
    # fence. and fence..
    # pq. and pq..

#    $formattedcontent =~ s/^q[.][.]/\n<\/div>/igm;
#    $formattedcontent =~ s/^q[.]/<div class="highlighted" markdown="1">/igm;

    $formattedcontent =~ s/^q[.][.]/\n<\/blockquote>/igm;
    $formattedcontent =~ s/^q[.]/<blockquote class="highlighted" markdown="1">\n/igm;

    $formattedcontent =~ s/^hr[.]/<hr class="shortgrey" \/>/igm;

    $formattedcontent =~ s/^br[.]/<br \/>/igm;

    $formattedcontent =~ s/^more[.]/<more \/>/igm;

    $formattedcontent =~ s/^fence[.][.]/<\/code><\/pre><\/div>/igm;
    $formattedcontent =~ s/^fence[.]/<div class="fenceClass"><pre><code>/igm;

    $formattedcontent =~ s/^code[.][.]/<\/code><\/pre><\/div>/igm;
    $formattedcontent =~ s/^code[.]/<div class="codeClass"><pre><code>/igm;

    $formattedcontent =~ s/pq[.][.]/<\/em><\/big><\/center>/igm;
    $formattedcontent =~ s/^pq[.]/<center><big><em>/igm;

    return $formattedcontent;
}

sub markup_to_html {
    my $markup      = shift;
    my $markup_type = shift;
    my $slug        = shift;

    if ( get_power_command_on_off_setting_for("markdown", $markup, 0) ) {
        $markup_type = "markdown";
    }


    my $html = remove_power_commands($markup);

    $html = remove_image_header_commands($html); 

    $html = remove_aside_command($html); 

    my $newline_to_br = 1;
    $newline_to_br    = 0 if !get_power_command_on_off_setting_for("newline_to_br", $markup, 1);

    $html = process_custom_code_block_encode($html);

    $html = process_embedded_media($html);

    $html = Utils::url_to_link($html) if get_power_command_on_off_setting_for("url_to_link", $markup, 1);

    $html = custom_commands($html); 

    $html = hashtag_to_link($html)  if get_power_command_on_off_setting_for("hashtag_to_link", $markup, 1);

    if ( $markup_type eq "textile" ) {
        my $textile = new Text::TextileArticle;
        $html = $textile->process($html);
    } else {
        my $md   = Text::MultiMarkdownArticle->new;
        $html = $md->markdown($html, {newline_to_br => $newline_to_br, heading_ids => 0}  );
        # $html = $md->markdown($html, {heading_ids => 0} );
    }

    $html = process_custom_code_block_decode($html);

    # why do this?
    $html =~ s/&#39;/'/sg;

#    $html = _create_heading_list($html, $slug);

    return $html;
}

sub calc_reading_time_and_word_count {
    my $post = shift; # html already removed
    my $hash_ref;
    my @tmp_arr                 = split(/\s+/s, $post);
    $hash_ref->{'word_count'}   = scalar (@tmp_arr);
    $hash_ref->{'reading_time'} = 0; #minutes
    $hash_ref->{'reading_time'} = int($hash_ref->{'word_count'} / 180) if $hash_ref->{'word_count'} >= 180;
    return $hash_ref;
}

sub get_more_text_info {
    my $tmp_post   = shift;
    my $slug       = shift;
    my $title      = shift;

    my $text_intro;

    my $more_text_exists = 0; #false

    if ( $tmp_post =~ m|^(.*?)\[more\](.*?)$|is ) { 
        $text_intro = $1;
        my $tmp_extended = Utils::trim_spaces($2);
        if ( length($tmp_extended) > 0 ) {
            $more_text_exists = 1;
        }
        if ( length($text_intro) > 300 ) {
            $text_intro = substr $text_intro, 0, 300;
            $text_intro .= " ...";
        }
    } elsif ( $tmp_post =~ m|^intro[\s]*=[\s]*(.*?)$|mi ) {
        $text_intro = $1;
        $more_text_exists = 1;
        if ( length($text_intro) > 300 ) {
            $text_intro = substr $text_intro, 0, 300;
            $text_intro .= " ...";
        }
        $text_intro = "<span class=\"streamtitle\"><a href=\"/$slug\">$title</a></span> - " . $text_intro;
    } elsif ( length($tmp_post) > 300 ) {
        $text_intro = substr $tmp_post, 0, 300;
        $text_intro .= " ...";
        $more_text_exists = 1;
    } else {
        $text_intro = $tmp_post;
    }

# don't need this anymore.
    $text_intro =~ s|\[h1\]|<span class="streamtitle"><a href="/$slug">|;
    $text_intro =~ s|\[/h1\]|</a></span> - |;

    $text_intro = Utils::remove_newline($text_intro);

#    if ( !$more_text_exists ) {
#        $text_intro = Utils::url_to_link($text_intro);
#        $text_intro = hashtag_to_link($text_intro);
#    }

    $text_intro = Utils::url_to_link($text_intro);
    $text_intro = hashtag_to_link($text_intro);

    return { 'more_text_exists' => $more_text_exists, 'text_intro' => $text_intro };
}

sub _create_heading_list {
    my $str  = shift;
    my $slug = shift;

    my @headers = ();
    my $header_list = "";

    if ( @headers = $str =~ m{\s+<h([1-6]).*?>(.*?)</h[1-6]>}igs ) {
        my $len = @headers;
        for (my $i=0; $i<$len; $i+=2) { 
            my $heading_text = Utils::remove_html($headers[$i+1]); 
            my $heading_url  = Utils::clean_title($heading_text);
            my $oldstr = "<h$headers[$i]>$headers[$i+1]</h$headers[$i]>";
            my $newstr = "<a name=\"$heading_url\"></a>\n<h$headers[$i] class=\"headingtext\"><a href=\"#$heading_url\">$headers[$i+1]</a></h$headers[$i]>";
            $str =~ s/\Q$oldstr/$newstr/i;
            $header_list .= "<!-- header:$headers[$i]:$heading_text -->\n";   
        } 
    }

    if ( $str =~ m{^<h1.*?>(.*?)</h1>}igs ) {
        my $orig_heading_text = $1;
        my $heading_text = Utils::remove_html($orig_heading_text); 
        my $heading_url  = Utils::clean_title($heading_text);
        my $oldstr = "<h1>$orig_heading_text</h1>";
        my $newstr = "<a name=\"$heading_url\"></a>\n<h1 class=\"headingtext\"><a href=\"/$slug\">$orig_heading_text</a></h1>";
        $str =~ s/\Q$oldstr/$newstr/i;
    }

    $str .= "\n$header_list";  

    return $str; 
}


# insta=url to instagram page that contains photo to embed
sub process_embedded_media {
    my $str = shift;

    my $cmd = "";
    my $url = "";


    while ( $str =~ m|^(insta[\s]*=[\s]*)(.*?)$|mi ) {
        $cmd=$1;
        $url        = Utils::trim_spaces($2);

        my $width  = 320;
        my $height = 320;
        my $insta;
        my @parts = split(/\s+/, $url);
        # $#parts returns the last element number of the array. if two elements, then the number one is returned.
        if ( $#parts ) { 
            my @size = split(/[xX]/, $parts[1]);
            if ( $#size ) {
                $width  = $size[0];
                $height = $size[1];
                my $img_url = _get_instagram_image_url($parts[0]);
                $insta = qq(<img src="$img_url" width="$width" height="$height"></img> <a href="$img_url">link</a>);
            }
           
        } else {
            my $img_url = _get_instagram_image_url($url);
            $insta = qq(<img src="$img_url" width="$width" height="$height"></img> <a href="$img_url">link</a>);
        }

        $str =~ s|\Q$cmd$url|$insta|;    
    }

    return $str;
}

sub _get_instagram_image_url {
    my $source_url = shift;

    my $img_url = "";

    my $source_content = get($source_url);
 
    my $p = HTML::TokeParser->new(\$source_content);

    # my $d = $p->get_tag('meta');
    # $d->[1]{name});  == author
    # $d->[1]{content}); == barney
    # Data Dumper: VAR1 = [ 'meta', { '/' => '/', 'content' => 'barney', 'name' => 'author' }, [ 'name', 'content', '/' ], '' ];

    while ( my $meta_tag = $p->get_tag('meta') ) {
        if ( $meta_tag->[1]{property} eq "og:image" ) {
            $img_url = $meta_tag->[1]{content}; 
        }
    }

    return $img_url;
}

sub process_custom_code_block_encode {
    my $str = shift;

    # code. and code.. custom block

    while ( $str =~ m/(.*?)code\.(.*?)code\.\.(.*)/is ) {
        my $start = $1;
        my $code  = $2;
        my $end   = $3;
        $code =~ s/</\[lt;/gs;
        $code =~ s/>/gt;\]/gs;
        $str = $start . "ccooddee." . $code . "ccooddee.." . $end;
    } 
    $str =~ s/ccooddee/code/igs;
 
    return $str;
}

sub process_custom_code_block_decode {
    my $str = shift;

    $str =~ s/\[lt;/&lt;/gs;
    $str =~ s/gt;\]/&gt;/gs;

    return $str;
}

1;

