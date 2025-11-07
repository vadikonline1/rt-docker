# Use official Ubuntu as base
FROM ubuntu:22.04

# Arguments for build-time variables
ARG RT_VERSION
ARG RT_PREFIX
ARG RT_WEB_USER
ARG RT_WEB_GROUP
ARG RT_DB_USER
ARG RT_DB_PASSWORD
ARG RT_DB_NAME
ARG RT_DB_HOST

# Set environment variables (optional)
ENV RT_VERSION=${RT_VERSION}
ENV RT_PREFIX=${RT_PREFIX}
ENV RT_WEB_USER=${RT_WEB_USER}
ENV RT_WEB_GROUP=${RT_WEB_GROUP}

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl gcc g++ make autoconf \
    perl libperl-dev cpanminus \
    libapache2-mod-fcgid apache2 \
    libdbd-pg-perl libdbi-perl \
    libssl-dev libexpat1-dev libgd-dev libz-dev \
    patch tar graphviz w3m multiwatch gnupg \
    && rm -rf /var/lib/apt/lists/*

# Download and extract RT
RUN mkdir -p /tmp/rt \
    && curl -L https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz -o /tmp/rt/rt.tar.gz \
    && tar xzvf /tmp/rt/rt.tar.gz --strip-components=1 -C /tmp/rt \
    && rm /tmp/rt/rt.tar.gz

# Configure and install RT
WORKDIR /tmp/rt
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

# Expose default port
EXPOSE 5000

# Default command to run RT server
CMD ["sh", "-c", "${RT_PREFIX}/sbin/rt-server --port 5000"]
