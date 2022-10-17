FROM php:8.1-apache

LABEL maintainer="Steven Sil"

# Copie des dossiers/fichiers sur le conteneur
COPY .docker/php/php.ini /usr/local/etc/php/
COPY .docker/apache/000-default.conf /etc/apache2/sites-available/
COPY . /var/www/html

# Mise à jour de apt-get
RUN apt-get update

# Installation extensions PDO pour MySQL et zip
RUN apt-get install -y libxml2-dev libonig-dev libzip-dev \
    && docker-php-ext-install dom xml mbstring pdo_mysql zip

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer

# Installation de Node.js & NPM
ENV NODE_VERSION=16.13.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node -v
RUN npm -v

# Installation de Git + configuration
RUN apt-get install -y git \
    && git config --global user.name "Steven Sil" \
    && git config --global user.email "steven.sil@oclock.io"

# Installation ZSH et OhMyZSH (en option)
RUN apt-get -y install zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Activation de la réécriture d'URL sur le serveur Apache
RUN a2enmod rewrite

# Edit .zshrc
RUN echo 'alias artisan="php artisan"' >> ~/.zshrc
