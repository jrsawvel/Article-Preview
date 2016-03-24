package CreatePost;

use strict;
use warnings;

use HTML::Entities;
#use URI::Escape::JavaScript qw(escape unescape);
use API::PostTitle;
use API::Format;

sub create_post {

    my $q = new CGI;

    my $json_text = $q->param('POSTDATA');

    my $hash_ref = JSON::decode_json $json_text;

    my $submit_type     = $hash_ref->{'submit_type'}; # Preview or Post 
    if ( $submit_type ne "Preview" and $submit_type ne "Post" ) {
        Error::report_error("400", "Unable to process post.", "Invalid submit type given.");
    } 

    my $original_markup = $hash_ref->{'markup'};

    my $markup = Utils::trim_spaces($original_markup);
    if ( !defined($markup) || length($markup) < 1 ) {
        Error::report_error("400", "Invalid post.", "You most enter text.");
    } 

    my $formtype = $hash_ref->{'form_type'};
    if ( $formtype eq "ajax" ) {
#        $markup = URI::Escape::JavaScript::unescape($markup);
#        $markup = HTML::Entities::encode($markup, '^\n\x20-\x25\x27-\x7e');
    } else {
#        $markup = Encode::decode_utf8($markup);
    }
#    $markup = HTML::Entities::encode($markup, '^\n\x20-\x25\x27-\x7e');

    my $o = PostTitle->new();
    $o->process_title($markup);
    if ( $o->is_error() ) {
        Error::report_error("400", "Error creating post.", $o->get_error_string());
    } 
    my $title           = $o->get_post_title();
    my $post_type       = $o->get_content_type(); # article or note
    my $slug            = $o->get_slug();
    # my $html            = Format::markup_to_html($markup, $o->get_markup_type(), $slug);
    my $page_data       = Format::extract_css($o->get_after_title_markup());
#    my $html            = Format::markup_to_html($o->get_after_title_markup(), $o->get_markup_type(), $slug);
    my $html            = Format::markup_to_html($page_data->{markup}, $o->get_markup_type(), $slug);

    $html = Format::create_heading_list($html, $slug) if Format::get_power_command_on_off_setting_for("headings_as_links", $markup, 0);
        

    my $hash_ref;

    if ( $submit_type eq "Preview" ) {

        my $tmp_post = $html;
        $tmp_post =~ s|<more />|\[more\]|;
        $tmp_post =~ s|<h1 class="headingtext">|\[h1\]|;
        $tmp_post =~ s|</h1>|\[/h1\]|;

        $tmp_post           = Utils::remove_html($tmp_post);
        my $post_stats      = Format::calc_reading_time_and_word_count($tmp_post); #returns a hash ref
        my $more_text_info  = Format::get_more_text_info($tmp_post, $slug, $title); #returns a hash ref
        my @tags            = Format::create_tag_array($markup);
#        my $created_at      = Utils::create_datetime_stamp();
        my $dt_hash_ref     = Utils::create_datetime_stamp();

        if ( $markup =~ m|^aside[\s]*=[\s]*(.+)|im ) {
            $hash_ref->{using_aside} = 1;
            $hash_ref->{aside_text}      = Utils::trim_spaces($1);
        }

        if ( $markup =~ m|^imageheader[\s]*=[\s]*(.+)|im ) {
            $hash_ref->{usingimageheader} = 1;
            $hash_ref->{imageheaderurl}   = Utils::trim_spaces($1);
        }

        if ( $markup =~ m|^largeimageheader[\s]*=[\s]*(.+)|im ) {
            $hash_ref->{usinglargeimageheader} = 1;
            $hash_ref->{largeimageheaderurl}   = Utils::trim_spaces($1);
        }

        $hash_ref->{html}                   = $html;
        $hash_ref->{title}                  = $title;
        $hash_ref->{post_type}              = $post_type;
        $hash_ref->{'text_intro'}           = $more_text_info->{'text_intro'};
        $hash_ref->{'more_text_exists'}     = $more_text_info->{'more_text_exists'};
        $hash_ref->{'tags'}                 =  \@tags;
        $hash_ref->{'author'}               = "Nick Adams";
#        $hash_ref->{'created_at'}        = $created_at;
        $hash_ref->{'created_date'}         = $dt_hash_ref->{date};
        $hash_ref->{'created_time'}         = $dt_hash_ref->{time};
        $hash_ref->{'reading_time'}         = $post_stats->{'reading_time'};
        $hash_ref->{'word_count'}           = $post_stats->{'word_count'};
        $hash_ref->{'using_css'}            = Format::get_power_command_on_off_setting_for("using_css", $markup, 1);
        $hash_ref->{'tint_header_image'}    = Format::get_power_command_on_off_setting_for("tint_header_image", $markup, 0);
        $hash_ref->{'title_over_image'}     = Format::get_power_command_on_off_setting_for("title_over_image", $markup, 0);
        $hash_ref->{'publish_info_at_top'}  = Format::get_power_command_on_off_setting_for("publish_info_at_top", $markup, 0);
        $hash_ref->{'toc'}                  = Format::get_power_command_on_off_setting_for("toc", $markup, 0);
        $hash_ref->{'custom_css'}           = $page_data->{custom_css};

        $hash_ref->{status}      = 200;
        $hash_ref->{description} = "OK";
        my $json_str = JSON::encode_json $hash_ref;
        print CGI::header('application/json', '200 Accepted');
        print $json_str;
        exit;
    }

}

1;

