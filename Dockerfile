FROM chef/inspec:4.18.51

RUN mkdir -p /etc/chef/accepted_licenses
COPY inspec-accepted-license /etc/chef/accepted_licenses/inspec

RUN apk add --no-cache build-base bash git && \
    gem install train-kubernetes && \
    inspec plugin install train-kubernetes && \
    sed -ie 's#"= 0#"0#g' /root/.inspec/plugins.json && \
    apk del build-base
