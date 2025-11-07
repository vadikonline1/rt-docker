FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PERL_LOCAL_LIB_ROOT=/opt/rt6/local
ENV PERL_MB_OPT="--install_base /opt/rt6/local"
ENV PERL_MM_OPT="INSTALL_BASE=/opt/rt6/local"
ENV PATH=/opt/rt6/local/bin:$PATH

# 1. Pre-requisites
RUN apt-get update && apt-get install -y \
    build-essential curl gcc g++ make \
    perl perl-modules perl-dev cpanminus \
    libapache2-mod-fcgid apache2 \
    libdbd-pg-perl libdbi-perl \
    libssl-dev libexpat1-dev libgd-dev \
    patch tar graphviz w3m \
    && rm -rf /var/lib/apt/lists/*

# 2. RT 6.0.2
WORKDIR /opt/rt6
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-6.0.2.tar.gz -o rt.tar.gz \
    && tar xzvf rt.tar.gz --strip-components=1 \
    && rm rt.tar.gz

# 3. Configure RT
RUN ./configure \
      --with-web-user=www-data \
      --with-web-group=www-data \
      --with-db-type=Pg \
      --prefix=/opt/rt6 \
      --with-attachment-dir=/opt/rt6/var/attachments \
      --enable-graphviz \
      --enable-gd

# 4. Make dirs, install Perl dependencies and RT
RUN make dirs \
    && make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=/opt/rt6/local" \
    && make install

# 5. Copy RT_SiteConfig template
COPY RT_SiteConfig.pm.template /opt/rt6/etc/RT_SiteConfig.pm.template

# 6. Inject .env values into RT_SiteConfig.pm at runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
