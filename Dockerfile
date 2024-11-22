FROM debian:bookworm-slim

# Update and upgrade packages
RUN apt-get update && apt-get upgrade

# Install JDK and any needed utilities
RUN apt-get install -y openjdk-17-jre-headless \
                       unzip curl procps vim net-tools \
                       npm iputils-ping

# We will put everything in the /app directory
WORKDIR /app

# Download and unzip client portal gateway
RUN mkdir gateway && cd gateway && \
    curl -O https://download2.interactivebrokers.com/portal/clientportal.gw.zip && \
    unzip clientportal.gw.zip && rm clientportal.gw.zip

    
# Copy our config so that the gateway will use it
COPY conf.yaml gateway/root/conf.yaml
COPY start.sh /app
COPY env.list /app
# Copy source code
ADD src/ webapp/src/
ADD angular.json package.json package-lock.json server.ts tsconfig.json tsconfig.spec.json tsconfig.app.json webapp/
    
# Install Angular CLI
RUN cd webapp && npm install -g @angular/cli@17 && npm install
# RUN npm install

# Commented out for now, some commands that are helpful if you want to install your own SSL certificate
# RUN keytool -genkey -keyalg RSA -alias selfsigned -keystore cacert.jks -storepass abc123 -validity 730 -keysize 2048 -dname CN=localhost
# RUN keytool -importkeystore -srckeystore cacert.jks -destkeystore cacert.p12 -srcstoretype jks -deststoretype pkcs12 -srcstorepass abc123 -deststorepass abc123
# RUN openssl pkcs12 -in cacert.p12 -out cacert.pem -passin pass:abc123 -passout pass:abc123
# RUN cp cacert.pem gateway/root/cacert.pem
# RUN cp cacert.jks gateway/root/cacert.jks
# RUN cp cacert.pem webapp/cacert.pem

# Expose the port so we can connect
EXPOSE 5055 5056

# Run the gateway
CMD sh ./start.sh