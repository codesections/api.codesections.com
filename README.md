## Codesections::API

This is a simple Cro API server for my personal site.  It's free
software, so you're welcome to make whatever use of it you'd like.
But I'm not attempting to address any use case other than my own very
simple one.

## API Docs

<!-- start api-docs -->

    GET    v1/health
    Check that api.codesections.com is functioning normally

    POST   v1/zola/build
      headers: authorization
    Build the www.codesections.com static site from latest git source

<!-- end api-docs -->

## Other
