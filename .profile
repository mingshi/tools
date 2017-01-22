
# MacPorts Installer addition on 2013-04-30_at_23:38:29: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.
export PATH="$(brew --prefix php54)/bin:$PATH"
export DBI_USER="root"
export DBI_PASSWORD=''
export GGXT_MODE="development"
export MOJO_REACTOR=Mojo::Reactor::Poll
