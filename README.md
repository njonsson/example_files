# example_files

[![Travis CI build status]][Travis-CI-build-status]
[![Hex release]           ][Hex-release]

**See what’s changed lately by reading the [project history][project-history].**

## What is an example file?

Many projects contain files which serve as templates or examples for other files.
The examples are not themselves operative, but serve to demonstrate the content
of an operative file, such as developer-specific configuration.

To illustrate: your project may contain a version-controlled file named
_config/config.exs.example_. You apply the example configuration by copying
_config/config.exs.example_ to _config/config.exs_, and in the process you may
decide to alter the content, such as tweaking defaults.

The Mix tasks provided here find, copy, and check the freshness of example files
and your copies of them.

## Installation

Use *example_files* by adding it to a Mix `deps` declaration.

```elixir
# mix.exs

# ...
defp deps do
  [{:example_files, "~> 0.2", only: [:dev, :test]}]
end
# ...
```

## Usage

The *example_files* commands are exposed as Mix tasks. Get help on them through
Mix itself, with `mix help | grep example_files` and `mix help example_files`.

* `mix example_files` – lists example files in your project and shows the status
of each
* `mix example_files.pull` — pulls into effect example files in your project by
  making copies of them using a file name that lacks the “example” nomenclature
* `mix example_files.clean` — cleans example files in your project by deleting
  your copies of them

## Contributing

To submit a patch to the project:

1. [Fork][fork-project] the official repository.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. [Create][compare-project-branches] a new pull request.

After cloning the repository, `mix deps.get` to install dependencies. Then
`mix espec` to run the tests. You can also `iex` to get an interactive prompt
that will allow you to experiment. To build this package, `mix hex.build`.

To release a new version:

1. Update [the “Installation” section](#installation) of this readme to reference
   the new version, and commit.
2. Update the project history in _History.md_, and commit.
3. Update the version number in _mix.exs_, and commit.
4. Tag the commit and push commits and tags.
5. Build and publish the package on [Hex](Hex-release) with `mix hex.publish`.

## License

Released under the [MIT License][MIT-License].

[Travis CI build status]: https://secure.travis-ci.org/njonsson/example_files.svg?branch=master
[Hex release]:            https://img.shields.io/hexpm/v/example_files.svg

[Travis-CI-build-status]:   http://travis-ci.org/njonsson/example_files                      "Travis CI build status for ‘example_files’"
[Hex-release]:              https://hex.pm/packages/example_files                            "Hex release of ‘example_files’"
[project-history]:          https://github.com/njonsson/example_files/blob/master/History.md "‘example_files’ project history"
[fork-project]:             https://github.com/njonsson/example_files/fork                   "Fork the official repository of ‘example_files’"
[compare-project-branches]: https://github.com/njonsson/example_files/compare                "Compare branches of ‘example_files’ repositories"
[MIT-License]:              http://github.com/njonsson/example_files/blob/master/License.md  "MIT License claim for ‘example_files’"
