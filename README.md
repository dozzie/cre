== cre, regexp match colourizer ==

cre is a simple text colourizer. It prints all it gets on STDIN (or in files
provided as arguments), but for every regexp passed with `-e` option cre makes
the match coloured.

cre is similar to `ack --passthrough` or an abuse of grep,
`grep -E --color '^|pattern'`, but cre is a little simpler to use and it
colours every pattern passed with `-e` with different colour (up to
6 patterns are supported).

cre uses PCRE syntax, or exactly, Perl's regexp syntax.

cre requires Perl 5.10 to run.

== Usage examples ==

    # find all "root" occurrences and mark them with red
    cre root /etc/passwd

    # find "/bin/zsh" shell and "/var/*" homes; shell will be red, home will
    # be green
    cre -e /bin/zsh -e '/var/[^:]*' /etc/passwd

== Contact ==

cre was written by Stanislaw Klekot `<dozzie at jarowit.net>`.
The primary distribution point is <http://dozzie.jarowit.net/git/cre.git>,
with a secondary address on GitHub <https://github.com/dozzie/cre>.

cre is distributed under 3-clause BSD license.
