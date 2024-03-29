FROM julia:latest

WORKDIR /usr/src/app


COPY . .
RUN julia --project=@. -e 'using Pkg; Pkg.instantiate()'

CMD julia --project=@. main.jl