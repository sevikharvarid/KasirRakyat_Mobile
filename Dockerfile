# --- Stage 1: Build APK ---
FROM ghcr.io/cirruslabs/flutter:3.32.8 AS builder

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build apk --release


# --- Stage 2: Keep APK ---
FROM alpine:3.18

WORKDIR /output

COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk .
CMD ["cat", "/output/app-release.apk"]