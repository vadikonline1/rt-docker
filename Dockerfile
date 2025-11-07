FROM debian:bookworm-slim

LABEL maintainer="vadikonline <you@example.com>"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    apache2 \
    libapache2-mod-fcgid \
    libdbd-pg-perl \
    libwww-perl \
    libcrypt-ssleay-perl \
    libtext-template-perl \
    postgresql-client \
    make \
    gcc \
    perl \
    cpanminus \
    git \
    cron \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/rt6

# Descărcare și instalare RT
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-6.0.2.tar.gz -o rt.tar.gz \
    && tar xzvf rt.tar.gz --strip-components=1 \
    && rm rt.tar.gz \
    && make dirs \
    && make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=/opt/rt6/local" \
    && make install

# Copiere configurări și entrypoint
COPY RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN make fixperms \
    && a2enmod fcgid rewrite mpm_prefork \
    && mkdir -p /var/run/apache2

EXPOSE 80
VOLUME ["/opt/rt6/var", "/var/log/apache2"]

ENTRYPOINT ["/entrypoint.sh"]
