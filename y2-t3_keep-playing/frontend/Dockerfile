# Stage 1: Build Flutter web app
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (Flutter refuses to run as root)
RUN useradd -ms /bin/bash flutter
ENV FLUTTER_VERSION=3.41.2
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git /flutter \
    && chown -R flutter:flutter /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

USER flutter
RUN flutter config --enable-web --no-analytics
RUN flutter precache --web

WORKDIR /app
COPY --chown=flutter:flutter . .

RUN flutter pub get
RUN flutter build web --release

# Phone frame: rename Flutter's index.html to app.html, create wrapper
RUN mv build/web/index.html build/web/app.html
COPY --chown=flutter:flutter phone-frame.html build/web/index.html

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
