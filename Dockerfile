# Folosim Rocky Linux 9 ca bază
FROM rockylinux:9

# Setăm variabile de mediu
ENV RT_VERSION=6.0.2
ENV RT_PREFIX=/opt/rt6
ENV RT_USER=rt
ENV RT_GROUP=rt
ENV PERL_LOCAL_LIB=$RT_PREFIX/local

# Instalăm pachete de bază și dependințe Perl
RUN dnf -y update && dnf install -y \
    epel-release \
    patch tar which gcc gcc-c++ make perl perl-App-cpanminus \
    graphviz expat-devel gd-devel multiwatch openssl openssl-devel \
    w3m curl bzip2 bzip2-devel xz-devel libuuid-devel \
    postgresql-devel libicu-devel libxml2-devel zlib-devel \
    sudo && \
    dnf clean all

# Dezactivare SELinux temporar
RUN setenforce 0 || true

# Creăm user și grup RT
RUN groupadd --system $RT_GROUP && \
    useradd --system --gid $RT_GROUP --home-dir $RT_PREFIX $RT_USER && \
    mkdir -p $RT_PREFIX && \
    chown -R $RT_USER:$RT_GROUP $RT_PREFIX

WORKDIR $RT_PREFIX

# Descărcăm și instalăm RT
USER $RT_USER
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz -o rt.tar.gz && \
    tar xzvf rt.tar.gz --strip-components=1 && \
    rm rt.tar.gz && \
    ./configure \
        --prefix=$RT_PREFIX \
        --with-db-type=Pg \
        --with-web-user=$RT_USER \
        --with-web-group=$RT_GROUP \
        --with-attachment-store=disk \
        --enable-externalauth \
        --enable-gd \
        --enable-graphviz \
        --enable-gpg \
        --enable-smime && \
    make dirs && \
    make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=$PERL_LOCAL_LIB" && \
    make install

# Setăm permisiuni
RUN sudo make fixperms

# Expunem portul 80 pentru RT
EXPOSE 80

# Comanda implicită
CMD ["/opt/rt6/sbin/rt-server", "--port", "80"]
