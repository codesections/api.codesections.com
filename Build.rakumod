use lib 'lib';
use Codesections::API;
use Cro::HTTP::Router;
constant \Handler = $App.handlers[0].WHAT;
my (\Header, \Query, \Auth, \Cookie) = Cro::HTTP::Router::<Header Query Auth Cookie>;
unit class Build;

#| All info we need to print API docs for a Cro route
class ApiInfo { has (Str $.method, @.routes, Str $.description, @.headers, @.queries) }

#| Extract ApiInfo from a Cro::Http::Router::RouteSet::RouteHandler
sub ApiInfo(Handler $_ (:$method, :$routes=.prefix, *%) --> ApiInfo) {
    ApiInfo.new: |.signature.params.classify(
        {   when Header {'headers'}; when Cookie {'cookies'}; when Auth {'auths'}
            when .named {'queries'}
            default     {'routes' } },
        as => { (do { 
            when Header        { .usage-name }
            when Cookie|Auth   { !!! 'cookie/auth NYI' }
            when Query|.named  { “{.usage-name}={.type.^name}” }
            default #`(route)  { .name ?? .name !! .gist.subst: <">, :g }})
                   #  trim "quotes" from _literal_ routes ^^^^
            ==> -> $el { $el but (role {method optional(--> True) {}} if .optional) }() },
        into => %(:$method, :$routes, description => gist .implementation.WHY //'')
    ).Map }

#| Format ApiInfo into text that looks like
#|     GET    route/to/endpoint?query=Str&other=Int
#|       headers: authorization
#|     Any description from the Cro handler 
#| Missing fields (e.g., headers) are skipped; optional segments are [bracketed]
sub fmt-api-docs(ApiInfo $_ (:$method, :$description,
        :&bracket-optional = {.?optional ?? "[$_]" !! $_};
        :$route  = .routes.map(&bracket-optional).join: '/';
        :$query  = .queries.map(&bracket-optional).join: '&';
        :$header = .headers.map(&bracket-optional).join: ', ') --> Str) {
    Lines: [ #`(ln1) $method.fmt: “%-6s $route$("?$query" if $query)”;
             #`(ln2) "  headers: $header" if $header;
             #`(ln3) $description if $description ].join: "\n" }

#| Replace demarcated api documentation, returning a new set of docs
proto update-api-docs(:$ ($*start-tag = '<!-- start api-docs -->';
                          $*end-tag   = '<!-- end api-docs -->'), |) {{*}}
multi update-api-docs(Str $new-api-docs, :old-docs($_)
      where m[ $*start-tag $<old-api-docs>=[.*] $*end-tag ] --> Str) {
    $<old-api-docs>.replace-with: "\n\n$new-api-docs\n\n" }
multi update-api-docs(Str, :$old-docs) { die "'$*start-tag' or '$*end-tag' missing" }

method build($directory, :$ ($path = "$directory/README.md")) { 
    PRE {readme_can_be_edited: $path.IO ~~ :e & :f & :rw } 
    $App.handlers
        .map(&ApiInfo)
        .map(&fmt-api-docs)
        .join("\n\n")
     ==> update-api-docs :old-docs(slurp $path)
     ==> spurt $path }











  
    # (with slurp "$dir/README.md" {
    #     S:s[ '<!-- start api-docs -->' 
    #           <( $<docs-to-replace>=[.*] )>
    #          '<!-- end api-docs -->' 
    #        ] = $api-docs}).say;

            # for <Header Query Auth Cookie> -> $role {
            #     when Cro::HTTP::Router::{$role} { $role.lc }};

  
            #:$ ($query = (if @queries {"?@queries.join('&')"}) )) {
            #:$ ($query = (if @queries {'?' ~join '&', @queries}) )) { 
            #:$ ($query = do if @queries {'?' ~@queries.join: '&'} )) { 
            #:$ ($query = ('?' ~@queries.join('&') if @queries) )) { 
            #:$ ($query = do if @queries ->$_ {'?' ~.join('&')}  )) {

    #{ die X::Post(&start-tag.gist ~' must match :old-docs') unless $<end-tag>; True};

    #`{

            say ::OUTER::.keys;
            say ::MY.keys;
            say &::("OUTER")::<start-tag end-tag>:p;
            say OUTER::<&start-tag &end-tag>:p;
            for <start-tag end-tag> {
                say $/{$_};
                say OUTERS::{'&'~$_};
            }

            note "========\n";
            say OUR::<&start-tag &end-tag>:p;
            say ::PARENT.keys;
            say ::MY.keys;
            say ::PARENT.keys;
            say &?ROUTINE;
            note "========\n";
            say &?ROUTINE.signature.params;
        

            fail X::Post(.^name)
    } 

# #| Replace demarcated api documentation, returning a new set of docs
# sub replace-api-docs(Str $new-api-docs, Str :old-docs($_),
#                  :$ ($start-tag = rx/'<!-- start api-docs -->'/;
#                      $end-tag   = rx/'<!-- end api-docs -->'  /) --> Str) {
#     POST {#`[= :old-docs must match] m/<$start-tag>/ }
#     POST {#`[= :old-docs must match] m/<$end-tag>  / }
#     S:s[ <$start-tag> $<docs-to-replace> = [<(.* )>] <$end-tag> ] = $new-api-docs 
#         # when !$/ {die "Old API docs did not have <!-- start api-docs -->"
#         #           ~" and <!-- end api-docs --> comments" }

# #| Extract the method (eg, GET), route (eg, /home/blog), queries (eg, ?s=term)
# #| headers, cookies, authentication info, and descriptive documentation from a
# #| Cro::Http::Router::RouteSet::RouteHandler
# sub extract-api-info(Handler
#    $_ (:$method, :@routes=[.prefix], *%) --> ApiInfo) {
#     ApiInfo.new: |%(.signature.params.classify: { 
#             when Header {'headers'}; when Cookie {'cookies'}; when Auth {'auths'}
#             when .named {'queries'}
#             default     {'routes' }},
#         as => {(do { when Header          { .usage-name }
#                      when Cookie|Auth     { !!! 'cookie/auth NYI' }
#                      when Query|.named    { “{.usage-name}={.type.^name}” }
#                      when :name #`(route) { .name }
#                      default              { .gist.subst: <">, :g }})
#                      # ^^ literal route; gist has "quotes" that need trimming
#                ==> -> $el { $el but (role Optional {} if .optional) }() },
#         into => %(:$method, :@routes, docs => .implementation.WHY //''))} 



# #| Format a api docs based on info in a Map.  The resulting output will look like:
# #|     GET    route/to/endpoint?query=Str&other=Int
# #|       headers: authorization
# #|     Any docs from the Cro handler 
# #| Missing fields (eg, headers) are skipped; optional segments are [bracketed]
# sub fmt-api-docs(ApiInfo $_ (:$method, :$docs, :@routes, :@headers, :@queries),
#          :$ (&bracket-optional = {$_ ~~ Optional ?? "[$_]" !! $_};
#              $route   = @routes.map( &bracket-optional).join: '/'; 
#              $query   = @queries.map(&bracket-optional).join: '&';
#              $header  = @headers.map(&bracket-optional).join: ', ') --> Str) {
#     Lines: [ #`(ln1) $method.fmt: “%-6s $route$("?$query" if $query)”;
#              #`(ln2) "  headers: $header" if $header;
#              #`(ln3) "$docs" if $docs ]
#            .join("\n") ~"\n\n" }
