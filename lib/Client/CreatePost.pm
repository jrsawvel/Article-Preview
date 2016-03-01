package CreatePost;

use strict;

use REST::Client;
use JSON::PP;
use HTML::Entities;
use Encode;

sub create_post {

    my $q = new CGI;
    my $submit_type     = $q->param("sb"); # Preview or Post 
    my $post_location   = $q->param("post_location"); # notes_stream or ?
    my $original_markup = $q->param("markup");

    my $markup = Encode::decode_utf8($original_markup);
    $markup = HTML::Entities::encode($markup,'^\n^\r\x20-\x25\x27-\x7e');

    my $api_url = Config::get_value_for("api_url");

    my $json_input;

    my $hash = {
        'submit_type' => $submit_type,
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
        if ( $submit_type eq "Preview" ) {
            my $t = Page->new("newpostform");
            my $html = $json->{html};
            $t->set_template_variable("previewingpost", 1);
            $t->set_template_variable("html", $html);
            $t->set_template_variable("title", $json->{title});
            $t->set_template_variable("author", $json->{author});
#            $t->set_template_variable("created_at", $json->{created_at});
            $t->set_template_variable("created_date", $json->{created_date});
            $t->set_template_variable("created_time", $json->{created_time});
            $t->set_template_variable("word_count", $json->{word_count});
            $t->set_template_variable("reading_time", $json->{reading_time});
            $t->set_template_variable("using_css", $json->{using_css});
            $t->set_template_variable("custom_css", $json->{custom_css});
            $t->set_template_variable("tint_header_image", $json->{tint_header_image});
            $t->set_template_variable("title_over_image", $json->{title_over_image});
            $t->set_template_variable("publish_info_at_top", $json->{publish_info_at_top});
            $t->set_template_variable("markup", $original_markup);
  
            if ( $json->{using_aside} ) {
                $t->set_template_variable("using_aside", 1);
                $t->set_template_variable("aside_text", $json->{aside_text});
            }

            if ( $json->{usinglargeimageheader} ) {
                $t->set_template_variable("largeimageheaderurl", $json->{largeimageheaderurl});
                $t->set_template_variable("usinglargeimageheader", 1);
            }

            if ( $json->{usingimageheader} ) {
                $t->set_template_variable("imageheaderurl", $json->{imageheaderurl});
                $t->set_template_variable("usingimageheader", 1);
            }
            $t->display_page("Previewing new post");
            exit;
        }
    } elsif ( $rc >= 400 and $rc < 500 ) {
         Page->report_error("user", $json->{description}, "$json->{user_message} $json->{system_message}");
    } else  {
        Page->report_error("user", "Unable to complete request. Invalid response code returned from API.", "$json->{user_message} $json->{system_message}");
    }
}

1;
