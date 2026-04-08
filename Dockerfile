# Step 1: Use a Flutter image to build the app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Enable web support
RUN flutter config --enable-web

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Get dependencies and build the web app
RUN flutter pub get
RUN flutter build web --release

# Step 2: Use a light web server to host the built files
FROM nginx:alpine

# Copy the custom nginx configuration as a template for envsubst
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copy the built web files from the build-env stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port (Railway will provide this)
EXPOSE 80

# Start nginx with environment substitution for dynamic PORT
CMD ["nginx", "-g", "daemon off;"]
