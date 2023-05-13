# Use the official Elixir image as our base image
FROM elixir:1.14

# Set the working directory
WORKDIR /app

# Production environment
ENV MIX_ENV=prod

# Install Hex and Rebar
RUN mix local.hex --force \
    && mix local.rebar --force

# Copy the application's mix.exs and mix.lock files
COPY mix.exs mix.lock ./

# Install the application's dependencies
RUN mix deps.get --only prod

# Copy the application's source code
COPY . .

# Compile the application
RUN mix compile

# Compile the assets
RUN mix assets.deploy

# Expose the port your application is running on
EXPOSE 4000

# Set the entrypoint to start the application
ENTRYPOINT ["mix", "phx.server"]
