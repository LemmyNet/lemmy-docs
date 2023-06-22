# Using Caddy as reverse proxy example

If you prefer to use Caddy instead of Nginx - you could use this template to fit into your needs:

```
lemmy-site.com {
        import caddy-common
        reverse_proxy   http://lemmy_lemmy-ui_1:1234

        @lemmy {
                path    /api/*
                path    /pictrs/*
                path    /feeds/*
                path    /nodeinfo/*
                path    /.well-known/*
        }

        @lemmy-hdr {
                header Accept application/*
        }

        handle @lemmy {
                reverse_proxy   http://lemmy_lemmy_1:8536
        }

        handle @lemmy-hdr {
                reverse_proxy   http://lemmy_lemmy_1:8536
        }

        @lemmy-post {
                method POST
        }

        handle @lemmy-post {
                reverse_proxy   http://lemmy_lemmy_1:8536
        }
}
```
