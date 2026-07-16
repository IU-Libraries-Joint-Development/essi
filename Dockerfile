# system dependency image
FROM buildpack-deps:bookworm AS ruby-278-bookworm

# skip installing gem documentation with `gem install`/`gem update`
RUN set -eux; \
        mkdir -p /usr/local/etc; \
        echo 'gem: --no-document' >> /usr/local/etc/gemrc

ENV LANG=C.UTF-8

# Ruby 2.7.8 (note: this version is EOL)
ENV RUBY_VERSION=2.7.8 \
    RUBY_DOWNLOAD_URL=https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.xz \
    RUBY_DOWNLOAD_SHA256=f22f662da504d49ce2080e446e4bea7008cee11d5ec4858fc69000d0e5b1d7fb

# OpenSSL 1.1.1 compatibility version for Ruby 2.7.8
ENV OPENSSL_VERSION=1.1.1w \
    OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source/openssl-1.1.1w.tar.gz \
    OPENSSL_DOWNLOAD_SHA256=cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8 \
    SSL_CERT_DIR=/etc/ssl/certs \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN set -eux; \
        # Compile OpenSSL 1.1.1 from source
        wget -O openssl.tar.gz "$OPENSSL_DOWNLOAD_URL"; \
        echo "$OPENSSL_DOWNLOAD_SHA256 *openssl.tar.gz" | sha256sum --check --strict; \
        mkdir -p /usr/src/openssl; \
        tar -xzf openssl.tar.gz -C /usr/src/openssl --strip-components=1; \
        rm openssl.tar.gz; \
        cd /usr/src/openssl; \
        ./config --prefix=/usr/local/openssl-1.1.1 shared zlib; \
        make -j "$(nproc)"; \
        make install_sw; \
        cd /; \
        \
        # Download Ruby
        wget -O ruby.tar.xz "$RUBY_DOWNLOAD_URL"; \
        echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
        \
        mkdir -p /usr/src/ruby; \
        tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
        rm ruby.tar.xz; \
        \
        cd /usr/src/ruby; \
        \
        # Export environment variables for build
        export rb_cv_wide_so_suffix=yes; \
        export rb_cv_binary_compile_options=yes; \
        \
        autoconf; \
        gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
        ./configure \
                --build="$gnuArch" \
                --disable-install-doc \
                --enable-shared \
                --with-openssl-dir=/usr/local/openssl-1.1.1 \
        ; \
        \
        make -j "$(nproc)"; \
        make install; \
        \
        # Create symlinks for OpenSSL libraries to ensure Ruby can find them at runtime
        ln -sf /usr/local/openssl-1.1.1/lib/libssl.so.1.1 /usr/lib/; \
        ln -sf /usr/local/openssl-1.1.1/lib/libcrypto.so.1.1 /usr/lib/; \
        \
        rm -rf /var/lib/apt/lists/*; \
        \
        cd /; \
        rm -r /usr/src/ruby; \
        rm -r /usr/src/openssl; \
        # verify we have no "ruby" packages installed
        [ "$(command -v ruby)" = '/usr/local/bin/ruby' ]; \
        # rough smoke test
        ruby --version; \
        gem --version; \
        bundle --version

# don't create ".bundle" in all our apps
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$GEM_HOME/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/openssl-1.1.1/lib:$LD_LIBRARY_PATH

RUN set -eux; \
        mkdir -p "$GEM_HOME"; \
        # adjust permissions of GEM_HOME for running "gem install" as an arbitrary user
        chmod 1777 "$GEM_HOME"

CMD [ "irb" ]


FROM ruby-278-bookworm AS essi-sys-deps

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} essi && \
    useradd -m -l -g essi -u ${USER_ID} essi && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential default-jre-headless libpq-dev nodejs \
      libreoffice-writer libreoffice-impress poppler-utils unzip ghostscript \
      libtesseract-dev libleptonica-dev tesseract-ocr \
      libpng-dev libtiff-dev librsvg2-dev libpango1.0-dev \
      yarn libopenjp2-tools libjemalloc2 && \
    apt-get clean all && rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/lib/*-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so.2
RUN yarn && \
    yarn config set no-progress && \
    yarn config set silent
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-1.5.5.zip https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip && \
    cd /opt/fits && unzip fits-1.5.5.zip && rm fits-1.5.5.zip && chmod +X fits.sh && \
    sed -i 's/\(<tool.*TikaTool.*>\)/<!--\1-->/ ; s/\(<tool.*FFIdent.*>\)/<!--\1-->/' /opt/fits/xml/fits.xml && \
    sed -i "s/exiftool\/ImageWidth\[last()\]/substring-before(exiftool\/ImageSize, 'x')/ ; s/exiftool\/ImageHeight\[last()\]/substring-after(exiftool\/ImageSize, 'x')/" /opt/fits/xml/exiftool/exiftool_image_to_fits.xslt
ENV PATH=/opt/fits:$PATH \
    RUBY_THREAD_MACHINE_STACK_SIZE=16777216 \
    RUBY_THREAD_VM_STACK_SIZE=16777216 \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so.2 \
    NODE_OPTIONS=--openssl-legacy-provider

# Installs specific version of ImageMagick to work with iiif_print
RUN curl -s -L https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.2-27.tar.gz | tar xvz && \
    cd ImageMagick* && ./configure && make install && cd $OLDPWD && rm -rf ImageMagick* && \
    sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf' && ldconfig

###
# ruby dev image
FROM essi-sys-deps AS essi-dev

RUN mkdir /app && chown essi:essi /app && mkdir -p /run/secrets
WORKDIR /app

USER essi:essi
COPY --chown=essi:essi Gemfile Gemfile.lock ./

# DEV ONLY - REMOVE LATER
# COPY --chown=essi:essi vendor/engines/bulkrax /app/vendor/engines/bulkrax
# COPY --chown=essi:essi vendor/engines/allinson_flex /app/vendor/engines/allinson_flex
# hold back from bundler 2.5 onwards until ruby is updated
# RUN gem update bundler
RUN gem install bundler -v "~> 2.4.22"
RUN bundle install --retry=3

COPY --chown=essi:essi . .

RUN mkdir /app/tmp/cache

ENV RAILS_LOG_TO_STDOUT=true

###
# ruby dependencies image
FROM essi-sys-deps AS essi-deps

RUN mkdir /app && chown essi:essi /app
WORKDIR /app

USER essi:essi

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY --chown=essi:essi Gemfile Gemfile.lock ./
# DEV ONLY - REMOVE LATER
# COPY vendor/engines/allinson_flex vendor/engines/allinson_flex
# hold back from bundler 2.5 onwards until ruby is updated
# RUN gem update bundler && \
RUN gem install bundler -v "~> 2.4.22" && \
    bundle install --retry=3 --deployment --without development

COPY --chown=essi:essi . .

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_ENV=production \
    SKIP_IIIF_PRINT_BULKRAX_VERSION_REQUIREMENT=true

ENTRYPOINT ["bundle", "exec"]

###
# sidekiq image
FROM essi-deps AS essi-sidekiq
USER essi:essi
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
CMD sidekiq

###
# webserver image
FROM essi-deps AS essi-web
USER essi:essi
RUN bundle exec rake assets:precompile
EXPOSE 3000
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
CMD puma -b tcp://0.0.0.0:3000
