FROM jenkins/jenkins:lts-jdk11
RUN jenkins-plugin-cli --plugins ${plugins}