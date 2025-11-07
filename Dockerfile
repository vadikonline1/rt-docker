# Base image: Rocky Linux 9
FROM rockylinux:9

# Arguments from build
ARG RT_VERSION
ARG RT_PREFIX

ENV RT_VERSION=${RT_VERSION}
ENV RT_PREFIX=${RT_PREFIX}

# Install dependencies
RUN dnf -y update && dnf install -y \
    gcc gcc-c++ make autoconf patch tar curl \
    perl perl-core perl-App-cpanminus \
    libpq-devel \
    httpd mod_fcgid \
    gd-devel expat-devel openssl openssl-devel \
    graphviz w3m multiwatch gnupg \
    && dnf clean all

# Create RT directories
RUN mkdir -p ${RT_PREFIX}

# Download and extract RT
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz -o /tmp/rt.tar.gz \
    && mkdir /tmp/rt \
    && tar xzvf /tmp/rt.tar.gz --strip-components=1 -C /tmp/rt \
    && rm /tmp/rt.tar.gz

WORKDIR /tmp/rt

# Configure and install RT
RUN ./configure \
        --prefix=${RT_PREFIX} \
        --with-web-user=www-data \
        --with-web-group=www-data \
        --with-db-type=Pg \
        --with-attachment-dir=${RT_PREFIX}/var/attachments \
    && make dirs \
    && make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=${RT_PREFIX}/local" \
    && make install

# Copy SiteConfig
COPY RT_SiteConfig.pm ${RT_PREFIX}/etc/RT_SiteConfig.pm

# Script to initialize DB on first run
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE ${RT_WEB_PORT}

ENTRYPOINT ["/entrypoint.sh"]
