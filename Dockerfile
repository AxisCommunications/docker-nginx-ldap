FROM nginx:1.25.0-alpine AS base

# Create a builder image.
FROM base AS builder

# Make our shell more strict during the build phase.
SHELL ["/bin/sh", "-exo", "pipefail", "-c"]

# Install the same build dependencies as the official image.
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
# Add dependencies specific for building the LDAP module.
    openldap-dev

# Download source files for the current Nginx and the LDAP module, and then
# unpack them to separate folders.
RUN mkdir -p /tmp/src/nginx \
    && curl -fsSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar vxz --strip=1 -C /tmp/src/nginx \
    && curl -fsSL https://github.com/kvspb/nginx-auth-ldap/archive/master.zip -o /tmp/nginx-auth-ldap-master.zip \
    && unzip -d /tmp/src /tmp/nginx-auth-ldap-master.zip

# Navigate to Nignx's source folder, and then build the LDAP module with the
# same compilation flags as the currently active Nginx installation in order to
# guarantee that it is compatible.
# https://github.com/openresty/docker-openresty/issues/114
RUN cd /tmp/src/nginx && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') && \
    sh -c "./configure --with-compat ${CONFARGS} --add-dynamic-module=/tmp/src/nginx-auth-ldap-master" && \
    make modules



# Create the final image.
FROM base

# Copy the compiled module from the builder image.
COPY --from=builder /tmp/src/nginx/objs/*_module.so /etc/nginx/modules/

RUN \
# Install dependencies.
    apk add --no-cache openldap-dev && \
# Edit nginx.conf to make sure the module is imported by Nginx at start.
    sed -i '1s&^&load_module modules/ngx_http_auth_ldap_module.so;\n&' /etc/nginx/nginx.conf && \
# As a final step we validate the config for good measure.
    nginx -t
