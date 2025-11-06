FROM debian:bookworm-slim

# Instalează pachete necesare
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  libapache2-mod-fcgid \
  apache2 \
  libdbd-pg-perl \
  libdatetime-perl \
  libencode-locale-perl \
  libfile-which-perl \
  libio-stringy-perl \
  liblocale-codes-perl \
  libmime-types-perl \
  libregexp-common-perl \
  libtext-iconv-perl \
  libtext-template-perl \
  liburi-perl \
  libjson-xs-perl \
  libtext-csv-perl \
  liblocale-maketext-lexicon-perl \
  libemail-date-format-perl \
  libemail-sender-perl \
  libemail-mime-perl \
  libemail-mime-modifier-perl \
  libmime-tools-perl \
  postgresql-client \
  cron \
  make \
  gcc \
  perl \
  cpanminus \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/rt6

# Descărcare RT (RT 6.0.2)
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-6.0.2.tar.gz -o rt.tar.gz \
    && tar xzvf rt.tar.gz --strip-components=1 \
    && rm rt.tar.gz

# Instalare dependințe CPAN suplimentare (dacă e nevoie)
RUN cpanm --notest DateTime Email::MIME JSON::XS Text::CSV

# Configurare și testare dependințe
RUN perl ./configure --with-web-user=www-data --with-web-group=www-data --with-db-type=Pg \
    && make testdeps \
    && make install

# Copiază fișierul de configurare
COPY RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm

# Enable mod_fcgid și rewrite
RUN a2enmod fcgid rewrite \
    && mkdir -p /var/run/apache2

# Volum pentru date persistente
VOLUME ["/opt/rt6/var", "/var/log/apache2"]

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
