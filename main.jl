using Plots
using MonteCarloMeasurements
using StatsPlots
using Oxygen
using HTTP
using JSON3

d = Particles(Int64(2e4), Uniform(0, 1))
a = Particles(Int64(2e4), Uniform(1, 2))

function createDensity(rune1, rune2)
    io = IOBuffer()
    Plots.svg(density(rune1 * d + rune2 * a, fill=true, opacity=0.5, normalize=true, xlims=(0, 15), ylims=(0, 1)), io)
    take!(io) |> String
end

@get "/" function ()
    read("index.html") |> String
end

@post "/plot" function (req::HTTP.Request)
    j = JSON3.read(req.body)
    rune1 = parse(Int64, j["rune1"])
    rune2 = parse(Int64, j["rune2"])

    io = IOBuffer()
    p = density(rune1 * d + rune2 * a, fill=true, opacity=0.5, normalize=true, xlims=(0, 16), ylims=(0, 1), label="current", xticks=0:16, yticks=0:0.1:1)
    if haskey(j, "option1")
        density!((rune1 + 1) * d + rune2 * a, fill=true, opacity=0.5, normalize=true, label="0/1 +1", color=:green)

        density!((rune1 - 1) * d + rune2 * a, fill=true, opacity=0.5, normalize=true, label="0/1 -1", color=:red)
    end

    if haskey(j, "option2")
        density!(rune1 * d + (rune2 + 1) * a, fill=true, opacity=0.5, normalize=true, label="1/2 +1", color=:purple)
        density!(rune1 * d + (rune2 - 1) * a, fill=true, opacity=0.5, normalize=true, label="1/2 -1", color=:brown)
    end

    if haskey(j, "targetValue") && j["targetValue"] != ""
        targetValue = parse(Int64, j["targetValue"])
        vline!([targetValue], color=:orange, label="probability of success")
        annotate!(targetValue + 1, 0.5, "$(@prob rune1 * d + rune2 * a >= targetValue)")
    end

    Plots.svg(p, io)
    take!(io) |> String
end

serve()