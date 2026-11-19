app [main] {
	pf: platform "https://github.com/lukewilliamboswell/roc-signals/releases/download/0.7.0-rc1/EWXzR62Lkva6BKW4qbvpkHHEsR6ZswDBXi2sef7Sf9Mk.tar.zst",
}

import pf.Engine
import Home

entries = Engine.entries({ fallback: Some("/") }, [{ path: "/", route: Home }])

main = Engine.program_startup({}, entries, |_| Engine.state(Home.initial, Home.view))
	.with_ports(Home.registrations)

mounted : U64
mounted = Engine.mounts(main)
