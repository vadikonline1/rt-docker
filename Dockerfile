# Base image: Rocky Linux 9
FROM rockylinux:9

ARG RT_VERSION
ARG RT_PREFIX=/opt/rt6
ARG RT_WEB_USER=www-data
ARG RT_WEB_GROUP=www-data

# Pre-requisites
RUN dnf -y update && \
    dnf -y install \
        gcc gcc-c++ make curl perl perl-App-cpanminus \
        postgresql postgresql-devel \
        httpd mod_fcgid graphviz gd-devel expat-devel \
        w3m tar patch openssl openssl-devel && \
    dnf clean all

# Create RT user/group
RUN groupadd -r ${RT_WEB_GROUP} && \
    useradd -r -g ${RT_WEB_GROUP} -d ${RT_PREFIX} ${RT_WEB_USER} && \
    mkdir -p ${RT_PREFIX}

# Download and extract RT
RUN curl -L https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz -o /tmp/rt.tar.gz && \
    tar xzvf /tmp/rt.tar.gz --strip-components=1 -C ${RT_PREFIX} && \
    rm /tmp/rt.tar.gz

WORKDIR ${RT_PREFIX}

# Configure & install RT
RUN ./configure \
      --prefix=${RT_PREFIX} \
      --with-web-user=${RT_WEB_USER} \
      --with-web-group=${RT_WEB_GROUP} \
      --with-db-type=Pg && \
    make dirs && \
    make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=${RT_PREFIX}/local" && \
    make install

EXPOSE 80 443
CMD ["/opt/rt6/sbin/rt-server", "--port", "80"]
