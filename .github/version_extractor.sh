# This is a small helper script used to extract the Nginx version numbers used
# for tagging the final Docker container. This script expects one input
# argument, and that is the path to the Dockerfile of interest.

if [ ! -f "${1}" ]; then
    echo "File '${1}' was not found"
    exit 1
fi

nginx_major=$(sed -n -r -e 's/^FROM nginx:([1-9])\.[0-9]+\.[0-9]+-alpine.*$/\1/p' "${1}")
nginx_minor=$(sed -n -r -e 's/^FROM nginx:[1-9]\.([0-9]+)\.[0-9]+-alpine.*$/\1/p' "${1}")
nginx_patch=$(sed -n -r -e 's/^FROM nginx:[1-9]\.[0-9]+\.([0-9]+)-alpine.*$/\1/p' "${1}")

if [ -n "${nginx_major}" -a -n "${nginx_minor}" -a -n "${nginx_patch}" ]; then
    echo "NGINX_MAJOR=${nginx_major}"
    echo "NGINX_MINOR=${nginx_minor}"
    echo "NGINX_PATCH=${nginx_patch}"
else
    >&2 echo "Could not extract all expected values: v${nginx_major}.${nginx_minor}.${nginx_patch}"
    exit 1
fi
