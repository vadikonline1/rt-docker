FROM debian:bookworm-slim

# --- Etapa 1: instalare pachete sistem ---
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    apache2 \
    libapache2-mod-fcgid \
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

# --- Etapa 2: Descărcare RT ---
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-6.0.2.tar.gz -o rt.tar.gz \
    && tar xzvf rt.tar.gz --strip-components=1 \
    && rm rt.tar.gz

# --- Etapa 3: Instalare module Perl lipsă ---
RUN cpanm --notest \
    HTML::Mason \
    HTML::Mason::PSGIHandler \
    Plack::Handler::FCGI \
    CSS::Minifier::XS \
    JavaScript::Minifier::XS \
    Text::Password::Pronounceable \
    Regexp::Common \
    Date::Extract \
    DBIx::SearchBuilder \
    File::ShareDir \
    Role::Basic \
    Module::Refresh \
    Text::Wrapper \
    Locale::Maketext::Fuzzy \
    DateTime::TimeZone \
    DateTime::Locale \
    Email::Address::XS \
    Encode::Detect::Detector \
    Encode::Locale \
    MIME::Types \
    && rm -rf ~/.cpanm

# --- Etapa 4: Configurare și instalare RT ---
RUN perl ./configure \
      --with-web-user=www-data \
      --with-web-group=www-data \
      --with-db-type=Pg \
      --with-attachment-dir=/opt/rt6/var/attachments \
      --prefix=/opt/rt6 \
    && make testdeps \
    && make install

# --- Etapa 5: Configurare Apache ---
COPY RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm

RUN a2enmod fcgid rewrite \
    && mkdir -p /var/run/apache2

VOLUME ["/opt/rt6/var", "/var/log/apache2"]

EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
