# signals.roc, from roc-signals 0.7.0-rc1: create, serve, build and test a
# roc-signals app. Keep it beside the app's main.roc and run it with Roc:
#
#     roc signals.roc init my-app    create an app in my-app/
#     roc signals.roc serve          serve it, reloading the page on a change
#     roc signals.roc build          build it for deployment, into dist/
#     roc signals.roc test           run its specs
#
# To move to another release, download that release's signals.roc over
# this one and change the platform in main.roc to match.
app [main!] {
	cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.28.1/7brgwR8YUqfeGrkdfF1V4GPPN7DnP7ftqub9KcrTEZtr.tar.zst",
	signals: "https://github.com/lukewilliamboswell/roc-signals/releases/download/0.7.0-rc1/signals-7L8uzC1ULY1LeXtH3RRJT6Shj93Ad3LQ4khhVS9tBFeh.tar.zst",
}

import signals.Signals

main! = |args| Signals.run!(args)
