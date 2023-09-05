    #!/bin/bash

    # Function to install Node.js
    install_nodejs() {
        apt-get install -y nodejs
        apt-get install -y npm
    }

    # Function to create a new user
    create_user() {
        adduser --disabled-password --gecos "" $1 &> /dev/null
    }

    # Function to get IP address
    get_ip() {
        ip_regex="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
        ip=$(ifconfig lo | grep -Eo $ip_regex | awk '{if(NR==1) {print $1}}')
        echo $ip
    }

    #function to git the repo cloned
    git_repo(){
            rm -rf pern-stack-example
            git clone https://github.com/omarmohsen/pern-stack-example.git
    }
    # Function to run UI tests
    run_ui_tests() {
        cd ~helmy/pern-stack-example/
        cd ui
        npm run test &
    }

    # Function to build UI
    build_ui() {
        cd ~helmy/pern-stack-example/
        cd ui
        npm install
        npm run build
    }

    # Function to create backend environment
    create_backend_env() {
        cd ~helmy/pern-stack-example/api
            sed -i "26a\
    if (environment === 'demo') {\n\
    ENVIRONMENT_VARIABLES = {\n\
        'process.env.HOST' : JSON.stringify('$ip'),\n\
        'process.env.USER' : JSON.stringify('helmy'),\n\
        'process.env.DB' : JSON.stringify('helmy'),\n\
        'process.env.DIALECT' : JSON.stringify('helmy'),\n\
        'process.env.PORT' : JSON.stringify('3080'),\n\
        'process.env.PG_CONNECTION_STR' : JSON.stringify('"postgres://helmy:'0000'@$ip:5432/helmy"')\n\
    };\n\
    }" webpack.config.js
            npm install
            ENVIRONMENT=demo npm run build

    }

    # Function to package and start the application
    package_start_app() {
        cd ~helmy/pern-stack-example/
        cp -r api/dist/* .
        cp api/swagger.css .
        npm install pg
        node api.bundle.js
    }

    # Main script
    main() {
        install_nodejs
        ip=$(get_ip)
        create_user "node"
        git_repo
        run_ui_tests
        build_ui
        create_backend_env $ip
        package_start_app
    }

    main