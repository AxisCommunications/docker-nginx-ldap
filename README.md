# nginx-ldap

The official Nginx [Docker image][1] with the [kvspb/nginx-auth-ldap][2]
module included, in order to add the functionality of authenticating users
via an LDAP server.

If you are not building this directly yourself you may find information about
available tags over on [Docker Hub][6].

## Usage
The LDAP module is added in such a way that everything else inside the container
is exactly as it is inside the [official Nginx image][1]. This means that how
to use this image is basically identical to the parent, but with this you also
have the ability to authenticate users via LDAP if you want to.

However, if you intend to overwrite the `/etc/nginx/nginx.conf` file, inside
the image, you must include the following line at the top of your custom one:

```
load_module modules/ngx_http_auth_ldap_module.so;
```

otherwise the [dynamic][5] LDAP module will not be loaded.

The LDAP server(s) then needs to be added to the `http` block of the
configuration, before it is used inside the `server` blocks.

#### Example
```
http {
    ldap_server test1 {
        url ldaps://192.168.0.1:3269/DC=test,DC=local?sAMAccountName?sub?(objectClass=person);

        binddn "TEST\\LDAPUSER";
        binddn_passwd LDAPPASSWORD;

        require valid_user;
        satisfy all;

        max_down_retries_count 3;
    }

    server {
        listen       8080;
        server_name  localhost;

        auth_ldap "Forbidden";
        auth_ldap_servers test1;

        location / {
            root   html;
            index  index.html index.htm;
        }
    }
}
```

More details about all possible configuration options are available in the
[kvspb/nginx-auth-ldap][2] repository.

> NOTE: Nginx loads files from the `conf.d/` folder in [alphabetical order][4],
        so to split the above configuration into two files the one containing
        the LDAP settings should be named similar to "`00-ldap.conf`".


## Acknowledgments and Thanks
Inspiration for this project has been collected from the following sources:

- https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081
- https://stackoverflow.com/questions/57739560/what-do-i-need-to-change-in-nginx-official-dockers-image-to-have-the-set-misc-n
- https://github.com/liminaab/infra-hub/tree/master/nginx-ldap

and the GitHub Actions configurations have been reused from the original
author's personal project:

- https://github.com/JonasAlfredsson/docker-nginx-certbot






[1]: https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
[2]: https://github.com/kvspb/nginx-auth-ldap
[3]: https://hub.docker.com/_/nginx
[4]: https://serverfault.com/a/361163
[5]: https://docs.nginx.com/nginx/admin-guide/dynamic-modules/dynamic-modules/
[6]: https://hub.docker.com/repository/docker/axistools/nginx-ldap
