#!/usr/bin/groovy
def POD_LABEL = "puppet-syncope-${UUID.randomUUID().toString()}"
pipeline {
    agent {
        kubernetes {
            label POD_LABEL
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                    - name: ruby
                      image: ruby
                      command:
                      - cat
                      tty: true
            '''
        }
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
    }
    stages {
        stage('Install') {
            steps {
                container('ruby') {
                    script {
                        sh """
                        bundle install --path=vendor/bundler --without=development
                        """
                    }
                }
            }
        }

        /*stage('Check') {
            steps {
                container('ruby') {
                    script {
                        sh """
                        bundle exec rake lint # Run puppet-lint
                        bundle exec rake syntax # Syntax check Puppet manifests and templates
                        """
                    }
                }
            }
        }*/

        stage('Test') {
            steps {
                container('ruby') {
                    script {
                        sh """
                        bundle exec kitchen test --concurrency=5 --destroy=always
                        bundle exec rake spec # Run spec tests in a clean fixtures directory
                        bundle exec rake acceptance # Run acceptance tests
                        """
                    }
                }
            }
        }
    }
}
