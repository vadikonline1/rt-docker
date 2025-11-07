# Base image: Rocky Linux 9
FROM rockylinux:9

# Arguments
ARG RT_VERSION
ARG RT_PREFIX
ARG RT_WEB_USER
ARG RT_WEB_GROUP
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB
ARG POSTGRES_HOST

ENV RT_VERSION=${RT_VERSION}
ENV RT_PREFIX=${RT_PREFIX}
ENV RT_WEB_USER=${RT_WEB_USER}
ENV RT_WEB_GROUP=${RT_WEB_GROUP}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_HOST=${POSTGRES_HOST}

# Install dependencies
RUN dnf -y update && dnf install -y \
    gcc gcc-c++ make autoconf patch tar curl \
    perl perl-core perl-App-cpanminus \
    libpq-devel \
    libapache2-mod-fcgid httpd \
    gd-devel expat-devel openssl openssl-devel \
    graphviz w3m multiwatch gnupg \
    && dnf clean all

# Create RT install dir
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
        --with-web-user=${RT_WEB_USER} \
        --with-web-group=${RT_WEB_GROUP} \
        --with-db-type=Pg \
        --with-attachment-dir=${RT_PREFIX}/var/attachments \
    && make dirs \
    && make fixdeps RT_FIX_DEPS_CMD="cpanm --notest --local-lib-contained=${RT_PREFIX}/local" \
    && make install

# Cleanup
RUN rm -rf /tmp/rt

# Expose RT port
EXPOSE ${RT_WEB_PORT}

# Default command
CMD ["sh", "-c", "${RT_PREFIX}/sbin/rt-server --port ${RT_WEB_PORT}"]
