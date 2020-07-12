FROM jupyter/base-notebook
USER root


# envs
ENV TZ=Asia/Tokyo \
    LC_CTYPE=C.UTF-8

# Install Golang and Gophernotes
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
RUN set -exu; \ 
    \
    apt-get update -y; \
    apt-get install -y --no-install-recommends wget git build-essential cmake curl; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*; \
    \
    wget -O go.tgz "https://golang.org/dl/go1.14.4.linux-amd64.tar.gz" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"; \
    \
    go get -v github.com/gopherdata/gophernotes; \
    mkdir -p ~/.local/share/jupyter/kernels/gophernotes; \
    cd ~/.local/share/jupyter/kernels/gophernotes; \
    cp /go/src/github.com/gopherdata/gophernotes/kernel/* .; \
    chmod +w ./kernel.json; \
    sed "s|gophernotes|/go/bin/gophernotes|" <kernel.json.in >kernel.json; \
    chmod a+rwx -R ~/.local/share/jupyter/


# Install Rust and Evcxr
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN set -exu; \
    \
    curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y --no-modify-path; \
    \
    rustc --version; \
    cargo --version; \
    rustup --version; \
    \
    cargo install evcxr_jupyter; \
    evcxr_jupyter --install


# Install Node.js and ITypescript
ENV N_PREFIX=$HOME/.n 
ENV PATH=$N_PREFIX/bin:$PATH

RUN set -exu; \
    curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n; \
    bash ./n 12.18.1; \
    rm ./n; \
    \
    npm config set unsafe-perm true; \
    npm install -g ijavascript itypescript; \
    \
    ijsinstall --install=global; \
    its --install=global; 


# Install Ruby and IRuby
RUN set -exu; \
    curl -sSL https://get.rvm.io | bash -s stable --ruby; \
    \
    apt-get update -y; \
    apt-get install -y --no-install-recommends libzmq3-dev libczmq-dev; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*; \
    \
    /bin/bash -l -c ". /etc/profile.d/rvm.sh"; \
    /bin/bash -l -c "gem install ffi-rzmq"; \
    /bin/bash -l -c "gem install iruby --pre"; \
    /bin/bash -l -c "iruby register --force";

# Install Python lib
RUN set -exu; \
    pip3 install numpy matplotlib;

EXPOSE 8888
ENTRYPOINT ["/bin/bash", "-l", "-c"]

CMD ["chmod a+rw /code && start.sh jupyter lab /code"]

