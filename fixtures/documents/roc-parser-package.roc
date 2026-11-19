app [] {
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/6.0.0-rc.5/822J9njyNR1vgyX1KG4ck496dBx3AnLfvn2zHXn15Ksw.tar.zst",
}

# %% id=number
out_number = U64.from_str("12345")

# %% id=names
import parser.CSV

Planet : { name : Str, moons : U64 }
decode : Str -> Try(List(Planet), [InvalidCsv(CSV.Error)])
decode = |input| CSV.decode_str(input, {})

planets = decode("name,moons\nEarth,1\nMars,2\n")
out_names = planets.map_ok(|rows| rows.map(|row| row.name))

# %% id=moons
out_moons = planets.map_ok(|rows| rows.map(|row| row.moons).sum())
