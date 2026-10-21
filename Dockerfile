# Use the official Ruby image
# -------------------------------------------------------------------------------------------------
FROM ruby:3.4.5

# Install dependencies
# -------------------------------------------------------------------------------------------------
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  nodejs
  # Set the working directory
  # -------------------------------------------------------------------------------------------------
  WORKDIR /home/galaxy_game
  
  # Install Bundler
  # -------------------------------------------------------------------------------------------------
  RUN gem install bundler
  
  # Copy the Gemfile and Gemfile.lock into the container
  # -------------------------------------------------------------------------------------------------
  COPY ./galaxy-game-ui/Gemfile ./galaxy-game-ui/Gemfile.lock /home/galaxy_game/
  
  # Install gems
  # -------------------------------------------------------------------------------------------------
  RUN bundle install
  
  # Copy the rest of the application code into the container
  # -------------------------------------------------------------------------------------------------
  ADD ./galaxy-game-ui /home/galaxy_game

  # Expose port 3000 to the Docker host
  EXPOSE 3000
