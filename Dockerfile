# Use the official Elixir image as our base image
FROM elixir:1.14

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y build-essential git curl libcairo2-dev libpango1.0-dev libreadline-dev libwxgtk3.0-gtk3-dev libgd-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of gnuplot (5.4.4)
RUN curl -L https://github.com/gnuplot/gnuplot/archive/refs/tags/5.4.4.tar.gz -o gnuplot-5.4.4.tar.gz \
    && tar -xzf gnuplot-5.4.4.tar.gz \
    && cd gnuplot-5.4.4 \
    && ./prepare \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf gnuplot-5.4.4.tar.gz gnuplot-5.4.4

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
