# Releasing passkeys-rails

There're no hard rules about when to release passkeys-rails. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
bundle exec rake
```

Change "Next" in [CHANGELOG.md](CHANGELOG.md) to the current date.

```
### 0.2.2 (2024/12/25)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for release 0.2.2"
git push origin main
```

Release.

```
$ bundle exec rake release

passkeys-rails 0.2.2 built to pkg/passkeys-rails-0.2.2.gem.
Tagged v0.2.2.
Pushed git commits and tags.
Pushed passkeys-rails 0.2.2 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 0.2.3 (Next)

- Your contribution here.
```

Increment the third version number in [lib/passkeys_rails/version.rb](lib/passkeys_rails/version.rb).

Commit your changes.

```
git add CHANGELOG.md lib/passkeys_rails/version.rb
git commit -m "Preparing for next development iteration - 0.2.3"
git push origin main
```
