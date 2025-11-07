# Base image
FROM rockylinux:9

# Build args
ARG RT_VERSION
ARG RT_DB_TYPE
ENV RT_VERSION=${RT_VERSION} \
    RT_DB_TYPE=${RT_DB_TYPE}

# Install dependencies
RUN dnf -y install epel-release && \
    dnf -y install patch tar which gcc gcc-c++ perl-core perl-App-cpanminus \
    graphviz expat-devel gd-devel multiwatch openssl openssl-devel w3m \
    nginx sudo && \
    dnf -y module enable postgresql:15 && \
    dnf -y install postgresql-server postgresql-devel && \
    dnf clean all

# Disable SELinux
RUN sed -i~ '/^SELINUX=/ c SELINUX=disabled' /etc/selinux/config && \
    setenforce 0 || true

# Add RT user/group
RUN groupadd --system rt && \
    useradd --system --home-dir=/opt/rt6/var --gid=rt rt

# Initialize PostgreSQL data directory
RUN mkdir -p /var/lib/pgsql/data && \
    chown -R postgres:postgres /var/lib/pgsql && \
    sudo -u postgres /usr/bin/initdb -D /var/lib/pgsql/data

# Download and build RT
WORKDIR /tmp
RUN curl -O https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz && \
    tar -xf rt-${RT_VERSION}.tar.gz && \
    cd rt-${RT_VERSION} && \
    PERL="/usr/bin/env -S perl -I/opt/rt6/local/lib/perl5" ./configure \
        --prefix=/opt/rt6 \
        --with-db-type=${RT_DB_TYPE} \
        --with-web-user=rt \
        --with-web-group=rt \
        --with-attachment-store=disk \
        --enable-externalauth \
        --enable-gd \
        --enable-graphviz \
        --enable-gpg \
        --enable-smime && \
    make dirs && \
    make fixdeps RT_FIX_DEPS_CMD="cpanm --sudo --local-lib-contained=/opt/rt6/local" && \
    make install && \
    cd /tmp && rm -rf rt-${RT_VERSION}*

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE ${RT_WEB_PORT}

ENTRYPOINT ["/entrypoint.sh"]
