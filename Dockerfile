# system dependency image
FROM ruby:2.7.8-bullseye AS essi-sys-deps

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} essi && \
    useradd -m -l -g essi -u ${USER_ID} essi && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential default-jre-headless libpq-dev nodejs \
      libreoffice-writer libreoffice-impress poppler-utils unzip ghostscript \
      libtesseract-dev libleptonica-dev liblept5 tesseract-ocr \
      yarn libopenjp2-tools libjemalloc2 && \
    apt-get clean all && rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/lib/*-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so.2
RUN yarn && \
    yarn config set no-progress && \
    yarn config set silent
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-1.5.5.zip https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip && \
    cd /opt/fits && unzip fits-1.5.5.zip && rm fits-1.5.5.zip && chmod +X fits.sh && \
    sed -i 's/\(<tool.*TikaTool.*>\)/<!--\1-->/ ; s/\(<tool.*FFIdent.*>\)/<!--\1-->/' /opt/fits/xml/fits.xml
ENV PATH /opt/fits:$PATH
ENV RUBY_THREAD_MACHINE_STACK_SIZE 16777216
ENV RUBY_THREAD_VM_STACK_SIZE 16777216
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# Installs specific version of ImageMagick to work with iiif_print
RUN wget https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.0-57.tar.gz && \
    tar xf 7.1.0-57.tar.gz && apt-get install -y libpng-dev libtiff-dev librsvg2-dev && \
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
RUN bundle install -j 2 --retry=3

COPY --chown=essi:essi . .

RUN mkdir /app/tmp/cache

ENV RAILS_LOG_TO_STDOUT true

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
    bundle install -j 2 --retry=3 --deployment --without development

COPY --chown=essi:essi . .

ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENV production
ENV SKIP_IIIF_PRINT_BULKRAX_VERSION_REQUIREMENT true

ENTRYPOINT ["bundle", "exec"]

###
# sidekiq image
FROM essi-deps as essi-sidekiq
USER essi:essi
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT $SOURCE_COMMIT
CMD sidekiq

###
# webserver image
FROM essi-deps as essi-web
USER essi:essi
RUN bundle exec rake assets:precompile
EXPOSE 3000
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT $SOURCE_COMMIT
CMD puma -b tcp://0.0.0.0:3000
